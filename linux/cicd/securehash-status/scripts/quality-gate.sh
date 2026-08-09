#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  pwd
)"

cd "$PROJECT_ROOT"

VENV_PATH="${PROJECT_ROOT}/.venv"
IMAGE_NAME="${IMAGE_NAME:-securehash-status:local}"
CONTAINER_NAME="securehash-status-quality-gate"
HOST_PORT="${HOST_PORT:-18081}"

cleanup() {
  docker rm \
    --force \
    "$CONTAINER_NAME" \
    >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "=== PRZYGOTOWANIE ŚRODOWISKA PYTHON ==="

if [[ ! -d "$VENV_PATH" ]]; then
  python3 -m venv "$VENV_PATH"
fi

source "${VENV_PATH}/bin/activate"

python -m pip install \
  --quiet \
  --requirement requirements.txt \
  --requirement requirements-dev.txt

echo "=== KONTROLA KODU ==="

ruff check app tests

echo "=== TESTY PYTEST ==="

python -m pytest -v

echo "=== BUDOWA OBRAZU ==="

docker build \
  --tag "$IMAGE_NAME" \
  .

echo "=== URUCHOMIENIE KONTENERA TESTOWEGO ==="

cleanup

docker run \
  --detach \
  --name "$CONTAINER_NAME" \
  --publish "127.0.0.1:${HOST_PORT}:8000" \
  --env APP_VERSION="quality-gate" \
  --env GIT_SHA="${GIT_SHA:-local}" \
  --env BUILD_NUMBER="${BUILD_NUMBER:-local}" \
  "$IMAGE_NAME"

echo "=== OCZEKIWANIE NA APLIKACJĘ ==="

APPLICATION_READY=false

for attempt in $(seq 1 30); do
  if curl \
    --connect-timeout 2 \
    --fail \
    --silent \
    "http://127.0.0.1:${HOST_PORT}/healthz" \
    >/dev/null; then

    APPLICATION_READY=true
    break
  fi

  sleep 1
done

if [[ "$APPLICATION_READY" != "true" ]]; then
  echo "BŁĄD: aplikacja nie osiągnęła gotowości"

  docker logs "$CONTAINER_NAME" || true
  exit 1
fi

echo "=== TEST ENDPOINTU STATUSU ==="

mkdir -p reports

curl \
  --connect-timeout 5 \
  --fail \
  --silent \
  "http://127.0.0.1:${HOST_PORT}/api/status" \
  > reports/status-response.json

python - <<'PY'
import json
from pathlib import Path

response_file = Path("reports/status-response.json")
body = json.loads(response_file.read_text(encoding="utf-8"))

assert body["application"] == "securehash-status"
assert body["status"] == "online"
assert body["version"] == "quality-gate"
assert "git_sha" in body
assert "build_number" in body
assert "checked_at" in body

print(json.dumps(body, indent=2))
PY

echo "=== QUALITY GATE ZAKOŃCZONY POWODZENIEM ==="
