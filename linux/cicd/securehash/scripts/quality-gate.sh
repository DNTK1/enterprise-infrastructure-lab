#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/4] Walidacja Docker Compose"
docker compose config --quiet

echo "[2/4] Testy, coverage i lint backendu"
docker build --target test --tag securehash-backend:test ./backend

echo "[3/4] Lint i produkcyjny build frontendu"
docker build --tag securehash-frontend:quality ./frontend

echo "[4/4] Produkcyjne obrazy Compose"
docker compose build

echo "QUALITY GATE: OK"
