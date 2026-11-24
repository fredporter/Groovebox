#!/usr/bin/env bash
# run-groovebox-checks.sh — the validation entry point used by CI and by hand.
#
# Runs the Python API suite, the spool schema contract and the Vue build in one
# pass. Dependencies are installed only when they are missing, so a workstation
# with a working environment is not mutated.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Python API tests"
if ! python3 -c "import fastapi, httpx, pydantic, pytest" >/dev/null 2>&1; then
  echo "    installing Python dependencies from requirements.txt"
  python3 -m pip install --quiet --disable-pip-version-check -r requirements.txt
fi
python3 -m pytest -q

echo "==> Spool schema"
bash scripts/check-spool-schema.sh

echo "==> Vue build"
if [[ ! -d node_modules || ! -d groovebox-vue/node_modules ]]; then
  echo "    installing workspace dependencies with npm ci"
  npm ci --no-audit --no-fund
fi
npm run build

echo "==> Groovebox checks passed"
