#!/usr/bin/env bash
# One-time setup: creates the backend venv, installs dependencies, copies .env.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v node >/dev/null || { echo "node is required (v18+)"; exit 1; }
PY="${PYTHON:-}"
if [ -z "$PY" ]; then
  for c in python3.12 python3.11 python3.10 python3; do command -v "$c" >/dev/null && PY="$c" && break; done
fi
echo "Using $($PY --version)  (3.10-3.12 recommended for the live watsonx.ai SDK)"

[ -f .env ] || { cp .env.example .env; echo "Created .env from .env.example (DEMO_MODE=mock)"; }

"$PY" -m venv backend/.venv
backend/.venv/bin/pip install -q -r backend/requirements.txt
(cd frontend && npm install --no-audit --no-fund)
echo "Setup complete. Run:  backend: cd backend && .venv/bin/uvicorn main:app --port 8000"
echo "                      frontend: cd frontend && npm run dev"
