# Development Patterns & Best Practices

> **Personal Preferences & Standards** established through 20+ projects
>
> **Precedence**: Based on most recent repos (last 2 months) showing matured practices

---

## 🏗️ PROJECT STRUCTURE PATTERNS

### Full-Stack Application (Preferred Pattern)
**Source**: devops-maturity-model (Oct 2025)

```
project-name/
├── backend/
│   ├── app/
│   │   ├── api/              # API endpoints
│   │   ├── core/             # Business logic
│   │   ├── models.py         # Database models
│   │   ├── schemas.py        # Pydantic schemas
│   │   └── main.py           # App entry point
│   ├── alembic/              # Database migrations
│   ├── tests/                # Backend tests
│   ├── pyproject.toml        # Poetry dependencies
│   ├── poetry.lock           # MUST commit
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   ├── services/         # API client
│   │   └── types/            # TypeScript types
│   ├── package.json
│   ├── package-lock.json     # MUST commit
│   └── Dockerfile
├── docs/
│   ├── lessons-learned.md    # Track mistakes
│   ├── progress-tracker.md   # Development progress
│   └── TESTING-SESSION-PROMPT.md
├── tests/
│   ├── scripts/              # Automated test scripts
│   └── manual/               # Manual test guides
├── docker-compose.yml
├── CLAUDE.md                 # AI assistant guide
└── README.md                 # User documentation
```

### Python CLI/Tool Pattern
**Source**: pmeaze_scraper (Aug 2025)

```
tool-name/
├── src/
│   └── tool_name/
│       ├── __init__.py
│       └── main.py
├── tests/
├── build_and_deploy.sh
├── requirements.txt
├── INSTRUCTIONS.md           # Comprehensive guide
└── README.md
```

### MCP Server Pattern
**Source**: spira-mcp-connection (Oct 2025)

```
mcp-server-name/
├── src/
│   └── mcp_server_name/
│       ├── features/         # Feature modules
│       │   ├── feature1/
│       │   │   ├── __init__.py
│       │   │   ├── common.py
│       │   │   └── tools/
│       │   └── feature2/
│       ├── utils/
│       └── server.py
├── tests/
├── docs/                     # API documentation
├── pyproject.toml
├── uv.lock                   # MUST commit
├── CLAUDE.md
└── README.md
```

---

## 🐳 DOCKER PATTERNS

### Docker Compose Standard
**Source**: devops-maturity-model, stinkin-park-site

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    container_name: project-backend
    volumes:
      - ./backend:/app
      - /app/.venv              # Prevent host override
    environment:
      DATABASE_URL: postgresql://user:pass@db:5432/dbname
      SECRET_KEY: ${SECRET_KEY}
    depends_on:
      - db
    command: uvicorn app.main:app --host 0.0.0.0 --reload

  frontend:
    build: ./frontend
    container_name: project-frontend
    volumes:
      - ./frontend:/app
      - /app/node_modules       # Prevent host override
    environment:
      VITE_API_URL: http://localhost:8000
    depends_on:
      - backend
    command: npm run dev -- --host

  db:
    image: postgres:15
    container_name: project-db
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: dbname
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

### Dockerfile Pattern - Python Backend

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Copy application
COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Dockerfile Pattern - Node Frontend

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application
COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host"]
```

---

## 📦 DEPENDENCY MANAGEMENT

### Python - Poetry (Preferred)
**Source**: devops-maturity-model, spira-mcp-connection

```toml
# pyproject.toml
[tool.poetry]
name = "project-name"
version = "0.1.0"
description = ""
package-mode = false  # For applications, not libraries

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.115.0"  # Specific versions for known compatibility
pydantic = "^2.6"
uvicorn = "^0.30.0"
sqlalchemy = "^2.0"
alembic = "^1.13"
psycopg2-binary = "^2.9"
python-jose = {extras = ["cryptography"], version = "^3.3"}
passlib = {extras = ["bcrypt"], version = "^1.7"}
bcrypt = "^4.0.0"  # Pin to 4.x for passlib compatibility

[tool.poetry.group.dev.dependencies]
pytest = "^7.4"
black = "^23.12"
ruff = "^0.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**Commands**:
```bash
# Setup
poetry install

# Add dependency
poetry add <package>

# Add dev dependency
poetry add --group dev <package>

# Update dependencies
poetry update

# ALWAYS commit poetry.lock after changes
git add poetry.lock
```

### Node - npm with Lock File (Required)
**Source**: devops-maturity-model

```json
{
  "name": "project-frontend",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.0",
    "@tanstack/react-query": "^5.17.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "eslint": "^8.0.0",
    "tailwindcss": "^3.4.0"
  }
}
```

**Commands**:
```bash
# Use npm ci for reproducible builds
npm ci  # Requires package-lock.json

# Only use npm install when changing dependencies
npm install <package>
npm install --save-dev <package>

# ALWAYS commit package-lock.json
git add package-lock.json
```

---

## 🗄️ DATABASE PATTERNS

### SQLAlchemy Models (Python)
**Source**: devops-maturity-model

```python
# models.py
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String)
    hashed_password = Column(String, nullable=False)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)

    # Relationships
    assessments = relationship("Assessment", back_populates="user")

class Assessment(Base):
    __tablename__ = "assessments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    status = Column(String, default="draft")
    created_at = Column(DateTime, default=datetime.utcnow)
    started_at = Column(DateTime, nullable=True)
    submitted_at = Column(DateTime, nullable=True)

    # Relationships
    user = relationship("User", back_populates="assessments")
    responses = relationship("GateResponse", back_populates="assessment")
```

### Alembic Migrations (PREFERRED METHOD)
**Source**: Lessons from devops-maturity-model

```bash
# Initialize Alembic (first time)
alembic init alembic

# Configure alembic.ini
# sqlalchemy.url = postgresql://user:pass@localhost/dbname

# Generate migration from models (PREFERRED)
alembic revision --autogenerate -m "descriptive message"

# ALWAYS review generated migration before applying
# Manual check: compare models to migration

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# See migration history
alembic history

# Check current revision
alembic current
```

**Migration File Pattern**:
```python
# alembic/versions/20251007_1600_initial_schema.py
"""Initial schema

Revision ID: abc123
Revises:
Create Date: 2025-10-07 16:00:00
"""
from alembic import op
import sqlalchemy as sa

revision = 'abc123'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('full_name', sa.String(), nullable=True),
        sa.Column('hashed_password', sa.String(), nullable=False),
        sa.Column('is_admin', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('last_login', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)

def downgrade() -> None:
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
```

---

## 🔐 AUTHENTICATION PATTERNS

### FastAPI JWT Authentication
**Source**: devops-maturity-model

```python
# core/security.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

SECRET_KEY = "your-secret-key"  # From environment
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user
```

### React Authentication Context
**Source**: devops-maturity-model

```typescript
// contexts/AuthContext.tsx
import React, { createContext, useState, useEffect, useContext } from 'react';
import { User } from '../types';
import * as api from '../services/api';

interface AuthContextType {
  user: User | null;
  login: (user: User) => void;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Load user on mount
    const token = localStorage.getItem('token');
    if (token) {
      api.getCurrentUser()
        .then(setUser)
        .catch(() => localStorage.removeItem('token'))
        .finally(() => setIsLoading(false));
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = (user: User) => {
    console.log('[AuthContext] Login called', { user });
    setUser(user);
  };

  const logout = () => {
    console.log('[AuthContext] Logout called');
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

---

## 🌐 API PATTERNS

### FastAPI Endpoint Pattern
**Source**: devops-maturity-model

```python
# api/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User
from ..schemas import LoginRequest, LoginResponse, UserResponse
from ..core.security import verify_password, create_access_token

router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Authenticate user and return JWT token.
    """
    console.log('[API] Login request received', request.email)

    user = db.query(User).filter(User.email == request.email).first()
    if not user or not verify_password(request.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    token = create_access_token({"sub": user.id})
    user.last_login = datetime.utcnow()
    db.commit()

    console.log('[API] Login successful', user.id)
    return LoginResponse(access_token=token, token_type="bearer")

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """
    Get current authenticated user information.
    """
    return current_user
```

### Axios Client Pattern (TypeScript)
**Source**: devops-maturity-model

```typescript
// services/api.ts
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

console.log('[API] Using backend URL:', API_URL);

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - add auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  console.log('[API] Request:', config.method, config.url);
  return config;
});

// Response interceptor - handle errors
api.interceptors.response.use(
  (response) => {
    console.log('[API] Response:', response.status, response.config.url);
    return response;
  },
  (error) => {
    console.error('[API] Error:', error.response?.status, error.config?.url, error.response?.data);
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export async function login(email: string, password: string) {
  console.log('[API] Login attempt', { email });
  const response = await api.post('/api/auth/login', { email, password });
  const { access_token } = response.data;
  localStorage.setItem('token', access_token);
  return response.data;
}

export async function getCurrentUser() {
  console.log('[API] Fetching current user');
  const response = await api.get('/api/auth/me');
  return response.data;
}
```

---

## 🧪 TESTING PATTERNS

### Automated Test Script Pattern
**Source**: devops-maturity-model

```bash
#!/bin/bash
# tests/scripts/backend-api.sh

set -e  # Exit on error

echo "=== Backend API Tests ==="
echo ""

BASE_URL="http://localhost:8000"
RESULTS_DIR="tests/results"
mkdir -p "$RESULTS_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_count=0
pass_count=0

function test_endpoint() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local expected_status="$5"

    test_count=$((test_count + 1))
    echo -n "Test $test_count: $name... "

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$BASE_URL$endpoint")
    fi

    status=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}FAIL${NC} (Expected $expected_status, got $status)"
        echo "$body"
    fi
}

# Run tests
test_endpoint "Health check" "GET" "/health" "" "200"
test_endpoint "Login" "POST" "/api/auth/login" \
    '{"email":"admin@example.com","password":"admin123"}' "200"

echo ""
echo "=== Results ==="
echo "Passed: $pass_count/$test_count"

if [ $pass_count -eq $test_count ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
```

### Python Test Pattern (pytest)
**Source**: spira-mcp-connection

```python
# tests/test_feature.py
import pytest
import os
import sys

# Setup test environment
os.environ['INFLECTRA_SPIRA_BASE_URL'] = 'https://test.spiraservice.net/'
os.environ['INFLECTRA_SPIRA_USERNAME'] = 'testuser'
os.environ['INFLECTRA_SPIRA_API_KEY'] = 'test-key'

sys.path.insert(0, 'src')

from mcp_server_spira.utils.spira_client import get_client

def test_feature_creation():
    """Test creating a new feature."""
    client = get_client()

    # Create test data
    data = {
        "Name": "Test Feature",
        "Description": "Test description"
    }

    # Execute
    result = client.create_feature(data)

    # Assert
    assert result is not None
    assert result['Name'] == "Test Feature"

    # Cleanup
    client.delete_feature(result['Id'])

def test_error_handling():
    """Test error handling for invalid input."""
    client = get_client()

    with pytest.raises(ValueError):
        client.create_feature({})  # Missing required fields
```

---

## 📝 DOCUMENTATION PATTERNS

### CLAUDE.md Template
**Source**: spira-mcp-connection, devops-maturity-model

```markdown
# Project Name

## Project Context
Brief description of what this project does and tech stack.

## Pre-Commit Protocol

**Before EVERY commit:**
1. Read and update `docs/lessons-learned.md` if issues encountered
2. Test in actual environment (browser/API/actual usage)
3. Run tests: `./run-tests.sh`

**Commit message format:**
```
<type>: <subject>

<body with what/why>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Critical Rules - NON-NEGOTIABLE
- NEVER mark features complete without actual testing
- NEVER use system-wide Docker commands
- ALWAYS commit lock files
- See `docs/lessons-learned.md` for mistakes to avoid

## Development Environment
- Container-based development preferred
- Virtual environments required for Python
- Network access: [local IPs if applicable]

## Testing Requirements
- Test in browser with DevTools open (frontend)
- Test with actual API calls (backend)
- Check logs for expected behavior
- Run automated test suite

## API Integration Guidelines (if applicable)
- Field naming conventions
- Required vs optional fields
- Error handling patterns

## Git Workflow
- ALWAYS create feature branch
- Never commit directly to main
- Include test results in commit messages
```

### README.md Template
**Source**: devops-maturity-model, stinkin-park-site

```markdown
# Project Name

Brief one-line description.

![Status Badge](badge-url)

## Quick Start

### Prerequisites
- Docker Desktop
- Git

### Setup & Run

```bash
# Clone and start
git clone <repo-url>
cd project-name
docker-compose up -d

# Access
open http://localhost:8080
```

## Features
- Feature 1
- Feature 2
- Feature 3

## Technology Stack
**Backend:**
- Framework and version
- Database and version
- Key libraries

**Frontend:**
- Framework and version
- Key libraries

**Infrastructure:**
- Docker + Docker Compose

## Project Structure
```
project/
├── backend/
├── frontend/
├── docs/
└── docker-compose.yml
```

## Development

### Backend Development
```bash
docker-compose exec backend bash
pytest
```

### Frontend Development
```bash
docker-compose exec frontend sh
npm test
```

## Testing
```bash
./tests/run-all-tests.sh
```

## Troubleshooting
Common issues and solutions.

## Documentation
- Link to detailed docs
- Link to API docs
- Link to guides
```

---

## 🎨 CODE STYLE PREFERENCES

### Python Style
**Source**: spira-mcp-connection

```python
# Use type hints
def function_name(param: str, count: int) -> dict:
    """
    Google-style docstring.

    Args:
        param: Description
        count: Description

    Returns:
        Description
    """
    pass

# PEP 8 conventions
# Line length: 79 characters
# Import order: stdlib → third-party → local

# Small, focused functions
# Descriptive variable names
# Comprehensive error handling
```

### TypeScript Style
**Source**: devops-maturity-model

```typescript
// Interfaces for type safety
interface User {
  id: number;
  email: string;
  fullName: string;
}

// Functional components with hooks
function Component({ prop }: { prop: string }) {
  const [state, setState] = useState<string>('');

  useEffect(() => {
    console.log('[Component] Mounted');
    return () => console.log('[Component] Unmounted');
  }, []);

  return <div>{prop}</div>;
}

// Async/await for promises
async function fetchData() {
  try {
    const response = await api.get('/endpoint');
    return response.data;
  } catch (error) {
    console.error('[Component] Error:', error);
    throw error;
  }
}
```

### JavaScript Style
**Source**: claudeAssistant

```javascript
// camelCase for functions
function processData() {}

// camelCase for variables
const localState = {};

// UPPERCASE for constants
const MAX_RETRIES = 3;

// Function declarations preferred
function handleClick() {
  // Implementation
}

// Consistent error handling
function operation() {
  try {
    // Logic
  } catch (error) {
    console.error('Error:', error);
    return { success: false, error: error.message };
  }
}
```

---

## 🔧 ENVIRONMENT & CONFIGURATION

### Environment Variables Pattern
**Source**: devops-maturity-model

```bash
# .env.example (committed)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
SECRET_KEY=your-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
VITE_API_URL=http://localhost:8000

# .env (gitignored - actual values)
DATABASE_URL=postgresql://realuser:realpass@db:5432/realdb
SECRET_KEY=actual-secret-key-32-chars-min
ACCESS_TOKEN_EXPIRE_MINUTES=30
VITE_API_URL=http://localhost:8000
```

### .gitignore Pattern

```gitignore
# Secrets & Environment
.env
.env.local
.env.*.local
local.properties
**/credentials.*
**/*_credentials.*

# Virtual Environments (CRITICAL)
venv/
.venv/
test_env/
env/
ENV/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
dist/
*.egg-info/

# Node
node_modules/
npm-debug.log*
package-lock.json  # Only if not committing
dist/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs & Debug
*.log
*_diagnostics.*
*.dump

# Docker
*.log

# Database
*.db
*.sqlite
*.sqlite3

# Testing
.pytest_cache/
coverage/
htmlcov/
.coverage
```

---

## 🚀 DEPLOYMENT PATTERNS

### Deployment Script Pattern
**Source**: stinkin-park-site

```bash
#!/bin/bash
# deploy.sh

set -e

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

echo "=== Deployment Script ==="
echo "Dry run: $DRY_RUN"
echo ""

# Pre-deployment checks
echo "Running tests..."
./tests/run-all-tests.sh

echo "Building production..."
docker-compose -f docker-compose.prod.yml build

if [ "$DRY_RUN" = true ]; then
    echo "Dry run complete - would deploy now"
    exit 0
fi

# Actual deployment
echo "Deploying to production..."
# rsync, scp, or deployment commands here

echo "Deployment complete!"
```

### Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SECRET_KEY=${SECRET_KEY}
    restart: always
    command: gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    restart: always

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
```

---

## 📊 LOGGING PATTERNS

### Backend Logging (Python)
**Source**: devops-maturity-model, stinkin-park-site

```python
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# Usage
logger.info(f"[API] User {user_id} logged in")
logger.warning(f"[API] Failed login attempt for {email}")
logger.error(f"[Database] Connection failed: {error}")
```

### Frontend Logging (TypeScript)
**Source**: devops-maturity-model

```typescript
// Comprehensive logging for MVP/development
console.log('[ComponentName] Action description', { data });
console.error('[ComponentName] Error description', error);

// API logging
console.log('[API] Request:', { method, url, data });
console.log('[API] Response:', { status, data });

// State changes
console.log('[AuthContext] Login called', { user });
console.log('[Navigation] Navigating to:', route);
```

---

*Last Updated: Based on analysis through October 2025*
*Represents matured patterns from 20+ repositories over 6+ months*
