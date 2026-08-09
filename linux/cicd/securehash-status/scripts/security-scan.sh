#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  pwd
)"

cd "$PROJECT_ROOT"

VENV_PATH="${PROJECT_ROOT}/.venv"
REPORTS_DIR="${PROJECT_ROOT}/reports"

mkdir -p "$REPORTS_DIR"

echo "=== PRZYGOTOWANIE ŚRODOWISKA ==="

if [[ ! -d "$VENV_PATH" ]]; then
  python3 -m venv "$VENV_PATH"
fi

source "${VENV_PATH}/bin/activate"

python -m pip install \
  --quiet \
  --requirement requirements.txt \
  --requirement requirements-dev.txt

echo "=== SKAN PODATNOŚCI ZALEŻNOŚCI ==="

pip-audit \
  --requirement requirements.txt \
  | tee "${REPORTS_DIR}/pip-audit.txt"

echo "=== ANALIZA BEZPIECZEŃSTWA KODU PYTHON ==="

bandit \
  --recursive \
  app \
  --format txt \
  --output "${REPORTS_DIR}/bandit.txt"

cat "${REPORTS_DIR}/bandit.txt"

echo "=== SKANOWANIE ZAKOŃCZONE POWODZENIEM ==="
