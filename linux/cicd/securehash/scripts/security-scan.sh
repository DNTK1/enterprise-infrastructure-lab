#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
mkdir -p reports

COMMON_ARGS=(--exit-code 1 --ignore-unfixed --severity HIGH,CRITICAL)

echo "[1/3] Kod, zaleznosci, sekrety i konfiguracja"
trivy fs \
  --scanners vuln,misconfig,secret \
  "${COMMON_ARGS[@]}" \
  . | tee reports/trivy-filesystem.txt

echo "[2/3] Obraz backendu"
trivy image \
  --scanners vuln,secret \
  "${COMMON_ARGS[@]}" \
  securehash-backend:local | tee reports/trivy-backend-image.txt

echo "[3/3] Obraz frontendu"
trivy image \
  --scanners vuln,secret \
  "${COMMON_ARGS[@]}" \
  securehash-frontend:local | tee reports/trivy-frontend-image.txt

echo "SECURITY REPORT: utworzony w katalogu reports/"
