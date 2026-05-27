# 02 — Tooling Setup

> **Phase 2 of the mission.** Install and configure the analyzer suite, then run it. Save raw output to `/reports/raw/`.

All tooling is open-source and runs locally. No code leaves the environment. No accounts or purchases required.

---

## Tool Inventory

| Tool | Purpose | Why |
|------|---------|-----|
| `ruff` | Lint + format + import-sort | Fast; replaces flake8/isort/pyupgrade/pydocstyle |
| `mypy` | Static type checking | Surfaces hidden contract violations; tells you how typed the code is |
| `bandit` | Python security linter | Catches SQL injection, hardcoded creds, insecure deserialization, unsafe `eval`, weak crypto |
| `pip-audit` | Dependency CVE scan | Cross-references installed deps against PyPI advisory database |
| `detect-secrets` | Secret scanning | Catches credentials in code with low false-positive rate |
| `radon` | Complexity metrics | Cyclomatic complexity, maintainability index, raw LOC |
| `vulture` | Dead code detection | Identifies unused functions, classes, variables |
| `pipdeptree` | Dependency graph | Shows transitive deps and version conflicts |
| `pip-licenses` | License inventory | Flags GPL/AGPL/unknown licenses |
| `pytest` + `pytest-cov` | Test runner + coverage | Establishes coverage baseline |
| `semgrep` | Pattern-based SAST | Optional but powerful for custom rule packs (Flask, Python security) |

## Installation

Create a `tooling/` directory and a separate virtualenv for the analyzers — **do not install these into the application's environment**. The application may have version constraints (especially around `arcgis`) that conflict.

```bash
# From repo root
mkdir -p tooling reports/raw
python -m venv tooling/.venv
# On Windows:
# tooling\.venv\Scripts\activate
# On Mac/Linux:
source tooling/.venv/bin/activate

pip install --upgrade pip
pip install \
    ruff==0.6.9 \
    mypy==1.11.2 \
    bandit==1.7.10 \
    pip-audit==2.7.3 \
    detect-secrets==1.5.0 \
    radon==6.0.1 \
    vulture==2.13 \
    pipdeptree==2.23.4 \
    pip-licenses==5.0.0 \
    pytest==8.3.3 \
    pytest-cov==5.0.0 \
    semgrep==1.86.0
```

If pinned versions fail to resolve in your environment, drop the pins, install latest, and record the resolved versions in `tooling/installed_versions.txt` via `pip freeze > tooling/installed_versions.txt`.

## Configuration Files

Create these at the repo root:

### `pyproject.toml` (tool configuration block)

If `pyproject.toml` already exists, append the `[tool.*]` sections. If not, create the file with just these sections:

```toml
[tool.ruff]
line-length = 100
target-version = "py311"
extend-exclude = ["migrations", "tooling/.venv"]

[tool.ruff.lint]
select = [
    "E", "F", "W",        # pycodestyle + pyflakes
    "I",                  # isort
    "B",                  # bugbear (likely bugs)
    "C90",                # mccabe complexity
    "N",                  # pep8-naming
    "UP",                 # pyupgrade
    "S",                  # bandit-equivalent security checks
    "BLE",                # blind exception
    "A",                  # builtins shadowing
    "C4",                 # comprehensions
    "DTZ",                # datetime timezone
    "T20",                # print statements
    "SIM",                # simplification
    "ARG",                # unused arguments
    "PTH",                # pathlib
    "ERA",                # commented-out code
    "PL",                 # pylint subset
    "RUF",                # ruff-specific
]
ignore = ["S101"]  # allow asserts in test files

[tool.ruff.lint.mccabe]
max-complexity = 10

[tool.mypy]
python_version = "3.11"
ignore_missing_imports = true   # arcpy/arcgis have weak stubs
warn_return_any = true
warn_unused_ignores = true
show_error_codes = true

[tool.bandit]
exclude_dirs = ["tooling", "tests", ".venv"]

[tool.pytest.ini_options]
addopts = "--cov=. --cov-report=term-missing --cov-report=html:reports/raw/coverage_html --cov-report=xml:reports/raw/coverage.xml"
testpaths = ["tests"]
```

### `.secrets.baseline` (detect-secrets baseline)

```bash
detect-secrets scan --all-files --exclude-files 'tooling/.venv|\.git|reports/raw' > .secrets.baseline
```

## Makefile

Create at repo root. This is the single entry point for re-running the analysis.

```makefile
.PHONY: help audit security lint types complexity deps tests report clean

VENV := tooling/.venv/bin
RAW := reports/raw

help:
	@echo "Targets:"
	@echo "  make audit       - Run full analysis suite"
	@echo "  make lint        - Ruff linting"
	@echo "  make types       - mypy type checking"
	@echo "  make security    - bandit + pip-audit + detect-secrets + semgrep"
	@echo "  make complexity  - radon + vulture"
	@echo "  make deps        - pipdeptree + pip-licenses"
	@echo "  make tests       - pytest with coverage"
	@echo "  make clean       - Remove raw outputs"

audit: lint types security complexity deps tests
	@echo "Analysis complete. See $(RAW)/ for outputs."

lint:
	mkdir -p $(RAW)
	$(VENV)/ruff check . --output-format=json > $(RAW)/ruff.json || true
	$(VENV)/ruff check . > $(RAW)/ruff.txt || true

types:
	mkdir -p $(RAW)
	$(VENV)/mypy . --ignore-missing-imports > $(RAW)/mypy.txt || true

security:
	mkdir -p $(RAW)
	$(VENV)/bandit -r . -x ./tooling,./tests -f json -o $(RAW)/bandit.json || true
	$(VENV)/bandit -r . -x ./tooling,./tests > $(RAW)/bandit.txt || true
	$(VENV)/pip-audit -r requirements.txt --format json > $(RAW)/pip_audit.json 2>/dev/null || \
	  $(VENV)/pip-audit --format json > $(RAW)/pip_audit.json || true
	$(VENV)/detect-secrets scan --baseline .secrets.baseline > $(RAW)/secrets_scan.txt 2>&1 || true
	$(VENV)/semgrep --config=p/python --config=p/flask --config=p/security-audit \
	  --json --output=$(RAW)/semgrep.json . || true

complexity:
	mkdir -p $(RAW)
	$(VENV)/radon cc . -s -j > $(RAW)/radon_cc.json || true
	$(VENV)/radon cc . -s -a > $(RAW)/radon_cc.txt || true
	$(VENV)/radon mi . -s > $(RAW)/radon_mi.txt || true
	$(VENV)/radon raw . -s > $(RAW)/radon_raw.txt || true
	$(VENV)/vulture . --min-confidence 80 > $(RAW)/vulture.txt || true

deps:
	mkdir -p $(RAW)
	$(VENV)/pipdeptree > $(RAW)/pipdeptree.txt || true
	$(VENV)/pipdeptree --json-tree > $(RAW)/pipdeptree.json || true
	$(VENV)/pip-licenses --format=markdown > $(RAW)/licenses.md || true
	$(VENV)/pip-licenses --format=json > $(RAW)/licenses.json || true

tests:
	mkdir -p $(RAW)
	$(VENV)/pytest 2>&1 > $(RAW)/pytest.txt || true

clean:
	rm -rf $(RAW)/*
```

On Windows without `make`, save the equivalent as `audit.ps1` or `audit.bat`. The simplest fallback is a `tooling/run_audit.py` script that calls each tool via `subprocess.run` and writes outputs to `reports/raw/`.

## Execution

```bash
make audit
```

Then inspect `reports/raw/` and verify each file has content. Empty files usually mean the tool errored — check stderr, fix, re-run.

## What to Look For in Each Output

When you read the analysis later for report drafting, here's what each tool tells you:

| Tool | Look for | In which report |
|------|----------|-----------------|
| `ruff.json` | Total violations, top rules triggered, count by severity | SDLC Audit (Implementation Quality) |
| `mypy.txt` | Untyped function count, type errors, `Any` returns | SDLC Audit (Implementation Quality) |
| `bandit.json` | HIGH and MEDIUM severity findings with CWE IDs | Security Findings (primary source) |
| `pip_audit.json` | CVE ID, package, fixed-version, severity | Security Findings (Dependency Vulnerabilities) |
| `secrets_scan.txt` | Any secret types detected (location only, not value) | Security Findings (Secrets Management) |
| `semgrep.json` | Flask-specific issues: missing CSRF, debug=True, SSTI, open redirects | Security Findings |
| `radon_cc.json` | Functions with complexity ≥ 10 (refactor candidates); ≥ 30 = critical | Refactoring Roadmap |
| `radon_mi.txt` | Files with maintainability index < 20 (high effort to change) | Refactoring Roadmap |
| `vulture.txt` | Dead code that can be deleted | Refactoring Roadmap (quick wins) |
| `pipdeptree.txt` | Diamond dependencies, unused top-level packages | SDLC Audit (Architecture) |
| `licenses.md` | GPL/AGPL/unknown licenses | SDLC Audit (Compliance) |
| `pytest.txt` | Total coverage %, missing-line coverage by file | SDLC Audit (Testing) |

## Manual Reviews That No Tool Catches

After running the suite, do these by hand:

1. **Read every Flask route handler.** Note: auth requirement, input validation, output sanitization, exception handling.
2. **Read every `arcpy`/`arcgis` call site.** Note: where the input came from (user-controlled?), error handling, resource cleanup (cursors, layers).
3. **Read every place credentials are loaded.** Note: hardcoded? env var? config file? secret manager?
4. **Read the `.gitignore`.** Note what is and isn't excluded. `.env` and `*.gdb` should be excluded.
5. **Read the README (if any).** Note what it says about deployment, configuration, and dependencies — compare to reality.

Capture these in `reports/raw/manual_review_notes.md`.

Once all of this is complete, proceed to Phase 3 (`03_ARCGIS_SECURITY_CHECKLIST.md`).
