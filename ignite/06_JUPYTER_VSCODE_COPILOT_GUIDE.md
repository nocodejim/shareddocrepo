# 06 — Accessing a Jupyter Notebook in VS Code with GitHub Copilot

> **Bonus artifact.** Use this if you need to bring the original `.ipynb` file into the same workspace as the Flask app for cross-referencing. The Flask app is the primary analysis target; the notebook is useful context for understanding business intent.

This guide assumes you're on a corporate Windows machine (common for ArcGIS shops) but calls out Mac/Linux differences where relevant.

---

## Why Open the Notebook?

The Flask code is what runs in production, but the original notebook often contains:

- Markdown cells explaining *why* the code does what it does (business intent that didn't survive conversion)
- Exploratory cells showing what data shapes were expected
- Sample outputs that document expected behavior
- Comments from the original authors about assumptions and edge cases

For the SDLC assessment, the notebook is supporting evidence for the "Requirements & Documentation" and "Maintenance" sections. You don't need to run it — just read it.

---

## Prerequisites

You need:

- **VS Code** (latest stable). Download: https://code.visualstudio.com/
- **Python 3.11** installed on the machine (matches ArcGIS Pro 3.x bundled Python; lower risk of version surprises)
- **GitHub Copilot subscription** active on your GitHub account, with your account signed into VS Code
- The `.ipynb` file in a location you can open (in the repo, or copied alongside it)

You do NOT need ArcGIS Pro installed to *read* the notebook. You would need it to *execute* cells that use `arcpy`.

---

## Step 1: Install the Required VS Code Extensions

Open VS Code. Press `Ctrl+Shift+X` (Cmd+Shift+X on Mac) to open the Extensions panel. Install these:

| Extension | Publisher | Why |
|-----------|-----------|-----|
| Python | Microsoft | Python language support |
| Jupyter | Microsoft | Notebook rendering and kernel management |
| Pylance | Microsoft | Fast Python language server (usually auto-installs with Python) |
| GitHub Copilot | GitHub | AI completions inline |
| GitHub Copilot Chat | GitHub | The chat panel where you talk to Opus/Claude/GPT |

After installing, restart VS Code so the extensions activate cleanly.

## Step 2: Sign In to GitHub Copilot

1. Click the account icon in the bottom-left of VS Code (silhouette).
2. Choose "Sign in with GitHub to use GitHub Copilot".
3. A browser opens; complete the OAuth flow.
4. Return to VS Code. You should see a Copilot icon in the status bar (bottom-right) — it indicates Copilot is active.

If the icon shows a warning, click it for the diagnostic; most issues are corporate proxy / firewall related. Contact your IT support if Copilot endpoints are blocked.

## Step 3: Open the Workspace

Two options depending on how you've organized the files:

**Option A — Notebook lives in the same repo as the Flask app (preferred):**
```
File → Open Folder → [select repo root]
```

**Option B — Notebook is separate:**
```
File → Open Folder → [select the folder containing both]
```

Or open the repo and drag the `.ipynb` file into the Explorer panel to add it.

If your corporate environment requires "trusting" the folder, accept the prompt only if the folder is from a known source.

## Step 4: Open the Notebook

Click the `.ipynb` file in the Explorer panel. VS Code opens it in the notebook editor — cells render directly with markdown formatted, code highlighted, and previously-saved outputs visible.

**You do not need to run any cells.** For the assessment, reading is sufficient.

## Step 5: Select a Python Interpreter (Only If You Want to Run Cells)

In the top-right of the notebook, click "Select Kernel" → "Python Environments" → pick a Python 3.11 install.

If you only want to read, skip this. If you do want to run cells:

- For cells that use only standard libraries: any Python 3.11 works
- For cells that use `arcgis` (the REST API library): create a virtualenv and `pip install arcgis`
- For cells that use `arcpy`: you must select the Python interpreter bundled with ArcGIS Pro, typically at `C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe`. `arcpy` cannot be pip-installed.

For the assessment, **do not run cells against production credentials.** If the notebook contains `GIS("https://...", "user", "pass")` calls, treat those credentials as already-compromised per the Security Findings work.

## Step 6: Open Copilot Chat and Pick a Model

1. Press `Ctrl+Alt+I` (or `Cmd+Alt+I` on Mac) to open the Copilot Chat panel. (You can also use the chat icon in the sidebar.)
2. At the bottom of the chat panel, you'll see a model picker — usually a dropdown showing the current model name.
3. Click the model picker. Available models typically include:

| Model Family | Strengths | Notes |
|--------------|-----------|-------|
| **Claude Opus** (currently the most capable Claude in Copilot) | Long-context reasoning, code review, structured analysis, large-document synthesis | Best fit for this SDLC assessment work |
| **Claude Sonnet** | Faster, cheaper, very capable for most tasks | Good for iterative work where speed matters |
| **GPT-5** / GPT-4.1 | Strong general-purpose, good code generation | Reasonable alternative |
| **Gemini Pro** | Long context, strong on certain reasoning tasks | Useful for second opinions |
| **o3-mini / o1** (OpenAI reasoning models) | Step-by-step reasoning | Slower but careful |

**Availability changes.** GitHub adds and removes models periodically. If a specific model isn't listed, it may require an enterprise plan or may have been deprecated. Pick the most capable Claude available for the assessment work; for this engagement, that's Opus.

4. Select the model. The selection persists for new chats until you change it.

## Step 7: Use the Right Mode for the Right Task

GitHub Copilot Chat has several modes — the buttons or dropdown near the chat input. The relevant ones:

- **Ask** — Single questions, quick lookups. Good for "what does this code do?"
- **Edit** — Multi-file edits with diff preview. Good for "refactor this function across these files."
- **Agent** — Multi-step autonomous work. The right mode for executing the SDLC assessment because Opus needs to read multiple files, run shell commands, and write reports.

For the SDLC assessment, **use Agent mode**. It lets Opus:

- Read files in the workspace without you pasting them in
- Run commands (`make audit`, etc.) via the integrated terminal
- Create new files (the reports under `/reports/`)
- Iterate across phases without you re-prompting at each step

To start: switch to Agent mode, then paste:

> *"Read `00_MISSION_BRIEF.md` in this workspace and execute the engagement as described. The handoff package is in the `handoff/` directory. Begin with Phase 0."*

Opus will read the brief and proceed.

## Step 8: Add the Notebook to Chat Context (If Relevant)

If you want Opus to read the `.ipynb` directly during the assessment:

1. In Copilot Chat, click the paperclip/attach icon.
2. Choose "Files in workspace" and select the notebook.
3. Or type `#` in the chat to reference a file: `#YourNotebook.ipynb`.

Opus can read `.ipynb` files directly — it understands the JSON structure. You don't need to convert it first.

If you want to convert anyway (sometimes useful for grep), from the integrated terminal:

```bash
jupyter nbconvert --to script YourNotebook.ipynb
# Produces YourNotebook.py alongside the original
```

Requires `jupyter` installed: `pip install jupyter nbconvert`.

## Step 9: Make Long Sessions Reliable

A few hygiene items that make agentic sessions go better:

- **Use a `CLAUDE.md` at the repo root.** This file is read by Copilot at session start (when using Claude models) and gives the agent persistent context. The Mission Brief recommends creating one — do it before the first real working session.
- **Don't dump the whole repo into chat.** Let the agent navigate the file tree. Pasting everything wastes context.
- **Re-anchor periodically.** In long sessions, periodically remind: *"You are executing the engagement described in `00_MISSION_BRIEF.md`. We are in Phase [N]. The next step is [X]."*
- **Check the terminal.** Agent mode runs commands in the integrated terminal — watch what runs. Cancel anything that looks wrong with `Ctrl+C` and the chat's stop button.
- **Save chats.** The chat panel has a save/export option. For an audit trail of how the reports were produced, save the chat alongside the reports.

## Step 10: Switching Models Mid-Engagement

You may want to switch models partway through — for example, use Opus for analysis and synthesis but Sonnet for quick file reads. To switch:

1. Open the model picker at the bottom of the chat panel
2. Choose a different model
3. The new model gets the recent chat history as context (within its own context window)

**Caveat:** Some agentic operations don't transfer perfectly across models. If you're mid-task, finish the current step before switching. If switching mid-engagement, paste a brief recap: *"Continuing from where the previous model left off. So far we have completed Phases 0-2 and produced [files]. Next is Phase 3."*

## Step 11: Reading the Notebook Effectively

When reading the notebook for the assessment, look for:

- **Markdown cells at the top** — usually the closest thing to a design document
- **Markdown cells between code blocks** — narrative explaining what the next cells do and why
- **Comments in code cells** — assumptions, TODOs, "this is a hack because…"
- **Outputs of cells** — sample data shapes, error messages, intermediate results
- **Cells with `# %% [markdown]` or `# %% [code]`** if it was authored in Jupytext format
- **Bottom cells** — often contain "main" execution that maps roughly to what's in the Flask routes now

For the SDLC Audit's "Requirements & Documentation" section, the notebook's markdown narrative is direct evidence. Quote it (with citation) when it explains business intent.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Copilot icon shows error | Not signed in / proxy blocking | Re-sign in; check corporate proxy whitelist for `copilot-proxy.githubusercontent.com` |
| Notebook cells render but show "No kernel" | No Python interpreter selected | Click "Select Kernel"; only needed if you'll execute cells |
| Model picker is missing | Older Copilot version | Update GitHub Copilot Chat extension |
| Opus is missing from the list | Plan-tier limitation, or temporary unavailability | Pick best available Claude (Sonnet) and proceed; the engagement still works |
| Agent mode can't run terminal commands | Terminal permission not granted | Click "Allow" when prompted; some corporate VS Code policies block this |
| `.ipynb` opens as raw JSON instead of notebook | Jupyter extension not installed or activated | Install extension, restart VS Code |
| Cells take minutes to render | Notebook has very large embedded outputs | Use "Clear All Outputs" or convert to `.py` via `jupyter nbconvert` |
| Copilot suggests installing packages without asking | Agent mode autonomy is high | Review the proposed command before approving; deny if unexpected |

## A Note on Sensitive Code

If the notebook contains real credentials, real customer data, or proprietary algorithms:

- Don't paste it into public ChatGPT or Claude.ai — use GitHub Copilot in your enterprise account, which is covered by your company's GitHub Enterprise agreement.
- Confirm with your security team what the data-handling terms are for Copilot. Most enterprises have a "Copilot for Business" or "Copilot Enterprise" plan that does not retain prompts for training.
- If in doubt, redact secrets in a working copy of the file before opening it in any AI-assisted tool.

## When You're Done

The notebook was a means to an end — to give the assessment richer context. After the SDLC reports are written, you don't need to keep the notebook open. Close it; the analysis lives in `/reports/` and is self-contained.
