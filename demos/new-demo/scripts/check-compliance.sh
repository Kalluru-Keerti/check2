#!/usr/bin/env bash
# Compliance gate. Exits non-zero on any HARD FAIL.
cd "$(dirname "$0")/.."
FAIL=0; WARN=0
pass(){ echo "  PASS  $1"; }
fail(){ echo "  FAIL  $1"; FAIL=1; }
warn(){ echo "  WARN  $1"; WARN=1; }
SRC="frontend/src backend/routers backend/services backend/main.py backend/config.py"

echo "== Docs =="
for f in README.md ARCHITECTURE.md PILOT_PLAN.md DEMO_SCRIPT.md .env.example; do
  [ -f "$f" ] && pass "$f present" || fail "$f missing"
done

[ -f .gitignore ] && pass ".gitignore present" || warn ".gitignore missing - add one excluding .env, .venv, node_modules, dist"
echo "== Secrets & data =="
git ls-files --error-unmatch .env >/dev/null 2>&1 && fail ".env is tracked by git" || pass ".env not tracked"
grep -qE '^WATSONX_API_KEY=$' .env.example && pass ".env.example has empty API key" || fail ".env.example API key not empty"
grep -rEn "(apikey|api_key)\s*[:=]\s*['\"][A-Za-z0-9_-]{20,}" $SRC 2>/dev/null && fail "possible hardcoded key" || pass "no hardcoded keys"
grep -rEn "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}" $SRC backend/data 2>/dev/null | grep -vE "@example\.com|@demo\.ibm\.com" | grep -vE "@(carbon|vitejs)/" | grep -q . && fail "non-example email found" || pass "emails are @example.com only"

echo "== Code safety =="
grep -rEn "\beval\(|dangerouslySetInnerHTML|new Function\(" frontend/src backend 2>/dev/null | grep -v ".venv" | grep -q . && fail "eval/dangerouslySetInnerHTML found" || pass "no eval / unsafe HTML"
grep -q "@carbon/react" frontend/package.json && pass "@carbon/react in deps" || fail "@carbon/react missing"
grep -rq "Demonstration Environment" frontend/src && grep -rq "All data is synthetic" frontend/src && pass "DemoBanner disclaimer present" || fail "DemoBanner disclaimer missing"
grep -rq "Built with IBM watsonx" frontend/src && pass "'Built with IBM watsonx' branding" || fail "branding missing"
grep -rqi "powered by watson" frontend/src README.md 2>/dev/null && fail "'Powered by Watson' used" || pass "no 'Powered by Watson'"
grep -q "Advisory only" backend/config.py && pass "advisory-only governance note" || fail "advisory note missing"

echo "== Containers =="
DF=$(ls Dockerfile* 2>/dev/null)
if [ -z "$DF" ]; then
  pass "no Dockerfiles yet (local-first workflow; containerize when ready)"
else
  for f in $DF; do
    T=$(grep -m1 '^# DEPLOY_TARGET:' "$f" | awk '{print $3}'); A=$(grep -m1 '^# BUILD_ARCH:' "$f" | awk '{print $3}')
    [ -z "$T" ] && { fail "$f missing DEPLOY_TARGET header"; continue; }
    [ "$T" = openshift ] && { grep '^FROM' "$f" | grep -vq 'ubi9/' && fail "$f: non-UBI9 base on openshift" || pass "$f UBI9"; }
    [ "$T" != local ] && [ "$A" = arm64 ] && { grep -q 'platform=linux/amd64' "$f" && pass "$f pinned amd64" || fail "$f not pinned to linux/amd64"; }
  done
fi
echo; [ $FAIL -eq 0 ] && echo "COMPLIANCE: PASS" || { echo "COMPLIANCE: FAIL"; exit 1; }
