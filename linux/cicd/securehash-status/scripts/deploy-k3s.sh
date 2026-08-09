#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="status-page"
DEPLOYMENT="securehash-status"

TEMPLATE="k8s/deployment.yaml.tpl"
RENDERED="k8s/deployment.rendered.yaml"
SERVICE="k8s/service.yaml"
INGRESS="k8s/ingress.yaml"

cleanup() {
    rm -f "${RENDERED}"
}

trap cleanup EXIT

echo "=== KONTROLA ZMIENNYCH ==="

test -n "${KUBECONFIG:-}"
test -n "${IMAGE_TAG:-}"
test -n "${GIT_COMMIT_FULL:-}"
test -n "${BUILD_NUMBER:-}"

echo "Image tag: ${IMAGE_TAG}"
echo "Git commit: ${GIT_COMMIT_FULL}"
echo "Build: ${BUILD_NUMBER}"

echo "=== GENEROWANIE MANIFESTU DEPLOYMENT ==="

python3 <<'PY'
import os
from pathlib import Path

template = Path("k8s/deployment.yaml.tpl").read_text()

for variable in (
    "IMAGE_TAG",
    "GIT_COMMIT_FULL",
    "BUILD_NUMBER",
):
    value = os.environ.get(variable)

    if not value:
        raise SystemExit(f"Brak zmiennej: {variable}")

    template = template.replace(
        "${" + variable + "}",
        value,
    )

Path("k8s/deployment.rendered.yaml").write_text(template)
PY

echo "=== WALIDACJA DOSTĘPU DO K3S ==="

kubectl auth can-i \
    create deployments \
    --namespace="${NAMESPACE}"

kubectl auth can-i \
    create services \
    --namespace="${NAMESPACE}"

kubectl auth can-i \
    create ingresses.networking.k8s.io \
    --namespace="${NAMESPACE}"

echo "=== DEPLOYMENT ==="

kubectl apply \
    -f "${RENDERED}"

kubectl apply \
    -f "${SERVICE}"

kubectl apply \
    -f "${INGRESS}"

echo "=== OCZEKIWANIE NA ROLLOUT ==="

kubectl rollout status \
    deployment/"${DEPLOYMENT}" \
    --namespace="${NAMESPACE}" \
    --timeout=120s

echo "=== STAN APLIKACJI ==="

kubectl get deployment,pods,service,ingress \
    --namespace="${NAMESPACE}" \
    -o wide

echo "=== WDROŻONY OBRAZ ==="

kubectl get deployment \
    "${DEPLOYMENT}" \
    --namespace="${NAMESPACE}" \
    -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

echo "=== DEPLOYMENT ZAKOŃCZONY POWODZENIEM ==="
