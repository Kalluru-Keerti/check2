#!/usr/bin/env bash
# Build + boot smoke test. Exits non-zero on any failure.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BE_PORT="${BE_PORT:-8010}"; FE_PORT="${FE_PORT:-5180}"
PIDS=()
cleanup() { for p in "${PIDS[@]:-}"; do kill "$p" 2>/dev/null || true; done; }
trap cleanup EXIT
ok() { echo "  PASS  $1"; }

echo "== Backend =="
cd "$ROOT/backend"
[ -d .venv ] || python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt
.venv/bin/uvicorn main:app --port "$BE_PORT" >/tmp/verify-be.log 2>&1 & PIDS+=($!)
for _ in $(seq 1 20); do curl -fsS "localhost:$BE_PORT/api/health" >/dev/null 2>&1 && break; sleep 0.5; done
B="localhost:$BE_PORT/api"
curl -fsS "$B/health" | grep -q '"status":"ok"' && ok "/api/health"
curl -fsS "$B/data/categories" >/dev/null && ok "/api/data/categories"
curl -fsS "$B/data/roles" | grep -q "ROLE-025" && ok "/api/data/roles (25 roles)"
curl -fsS "$B/data/samples" >/dev/null && ok "/api/data/samples"
curl -fsS "$B/ai/models" >/dev/null && ok "/api/ai/models"
curl -fsS "$B/demo/config" >/dev/null && ok "/api/demo/config"
curl -fsS -F role_id=ROLE-003 -F sample_id=SAMPLE-A "$B/ai/analyze" | grep -q '"verdict":"Suitable"' && ok "POST /api/ai/analyze (sample, mock mode)"

echo "== Frontend =="
cd "$ROOT/frontend"
{ npm ci --no-audit --no-fund || npm install --no-audit --no-fund; } >/tmp/verify-npm.log 2>&1
npm run build >/tmp/verify-build.log 2>&1 && ok "npm run build"
BACKEND_URL="http://localhost:$BE_PORT" npx vite --port "$FE_PORT" --strictPort >/tmp/verify-fe.log 2>&1 & PIDS+=($!)
for _ in $(seq 1 20); do curl -fsS "localhost:$FE_PORT/" >/dev/null 2>&1 && break; sleep 0.5; done
curl -fsS "localhost:$FE_PORT/" | grep -q 'id="root"' && ok "dev server serves /"
curl -fsS "localhost:$FE_PORT/api/health" | grep -q ok && ok "dev proxy -> backend"
echo "All smoke checks passed."
