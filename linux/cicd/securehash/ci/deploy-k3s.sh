#!/usr/bin/env bash

set -Eeuo pipefail

: "${KUBECONFIG:?Brak zmiennej KUBECONFIG}"
: "${BACKEND_IMAGE:?Brak zmiennej BACKEND_IMAGE}"
: "${FRONTEND_IMAGE:?Brak zmiennej FRONTEND_IMAGE}"
: "${IMAGE_TAG:?Brak zmiennej IMAGE_TAG}"
: "${APP_FQDN:?Brak zmiennej APP_FQDN}"

K8S_NAMESPACE="${K8S_NAMESPACE:-securehash}"
BUILD_NUMBER="${BUILD_NUMBER:-manual}"
GIT_COMMIT="${GIT_COMMIT:-unknown}"

if [[ ! "$IMAGE_TAG" =~ ^[0-9a-f]{12}$ ]]; then
    echo "BLAD: IMAGE_TAG nie jest 12-znakowym skrotem SHA"
    exit 1
fi

NEW_BACKEND_IMAGE="${BACKEND_IMAGE}:${IMAGE_TAG}"
NEW_FRONTEND_IMAGE="${FRONTEND_IMAGE}:${IMAGE_TAG}"

KUBECTL=(
    kubectl
    --kubeconfig="${KUBECONFIG}"
    --namespace="${K8S_NAMESPACE}"
    --request-timeout=20s
)

echo "===== PARAMETRY WDROZENIA ====="
echo "Namespace:       ${K8S_NAMESPACE}"
echo "Tag obrazu:      ${IMAGE_TAG}"
echo "Backend:         ${NEW_BACKEND_IMAGE}"
echo "Frontend:        ${NEW_FRONTEND_IMAGE}"
echo "Jenkins build:   ${BUILD_NUMBER}"
echo "Git commit:      ${GIT_COMMIT}"

echo "===== KONTROLA POLACZENIA ====="

"${KUBECTL[@]}" get deployment backend >/dev/null
"${KUBECTL[@]}" get deployment frontend >/dev/null

echo "===== KONTROLA RBAC ====="

BACKEND_PERMISSION="$(
    "${KUBECTL[@]}" auth can-i patch deployment/backend
)"

FRONTEND_PERMISSION="$(
    "${KUBECTL[@]}" auth can-i patch deployment/frontend
)"

if [[ "$BACKEND_PERMISSION" != "yes" ]]; then
    echo "BLAD: Jenkins nie moze modyfikowac deployment/backend"
    exit 1
fi

if [[ "$FRONTEND_PERMISSION" != "yes" ]]; then
    echo "BLAD: Jenkins nie moze modyfikowac deployment/frontend"
    exit 1
fi

OLD_BACKEND_IMAGE="$(
    "${KUBECTL[@]}" \
        get deployment backend \
        -o jsonpath='{.spec.template.spec.containers[?(@.name=="backend")].image}'
)"

OLD_FRONTEND_IMAGE="$(
    "${KUBECTL[@]}" \
        get deployment frontend \
        -o jsonpath='{.spec.template.spec.containers[?(@.name=="frontend")].image}'
)"

if [[ -z "$OLD_BACKEND_IMAGE" ]]; then
    echo "BLAD: nie udalo sie odczytac poprzedniego obrazu backendu"
    exit 1
fi

if [[ -z "$OLD_FRONTEND_IMAGE" ]]; then
    echo "BLAD: nie udalo sie odczytac poprzedniego obrazu frontendu"
    exit 1
fi

echo "===== POPRZEDNIE OBRAZY ====="
echo "Backend:  ${OLD_BACKEND_IMAGE}"
echo "Frontend: ${OLD_FRONTEND_IMAGE}"

rollback() {
    local rollback_result=0

    echo "===== AUTOMATYCZNY ROLLBACK ====="

    "${KUBECTL[@]}" \
        set image deployment/backend \
        "backend=${OLD_BACKEND_IMAGE}" \
        || rollback_result=1

    "${KUBECTL[@]}" \
        set image deployment/frontend \
        "frontend=${OLD_FRONTEND_IMAGE}" \
        || rollback_result=1

    "${KUBECTL[@]}" \
        annotate deployment/backend \
        kubernetes.io/change-cause="Rollback po Jenkins build ${BUILD_NUMBER}" \
        --overwrite \
        || rollback_result=1

    "${KUBECTL[@]}" \
        annotate deployment/frontend \
        kubernetes.io/change-cause="Rollback po Jenkins build ${BUILD_NUMBER}" \
        --overwrite \
        || rollback_result=1

    "${KUBECTL[@]}" \
        rollout status deployment/backend \
        --timeout=300s \
        || rollback_result=1

    "${KUBECTL[@]}" \
        rollout status deployment/frontend \
        --timeout=300s \
        || rollback_result=1

    echo "===== STAN PO ROLLBACKU ====="

    "${KUBECTL[@]}" get deployments,pods -o wide \
        || rollback_result=1

    if [[ "$rollback_result" -eq 0 ]]; then
        echo "OK: poprzednie obrazy zostaly przywrocone"
    else
        echo "BLAD: rollback nie zakonczyl sie w pelni poprawnie"
    fi

    return "$rollback_result"
}

deploy() {
    echo "===== WDROZENIE BACKENDU ====="

    "${KUBECTL[@]}" \
        set image deployment/backend \
        "backend=${NEW_BACKEND_IMAGE}" \
        || return 1

    "${KUBECTL[@]}" \
        annotate deployment/backend \
        kubernetes.io/change-cause="Jenkins ${BUILD_NUMBER}, commit ${GIT_COMMIT}" \
        --overwrite \
        || return 1

    "${KUBECTL[@]}" \
        rollout status deployment/backend \
        --timeout=300s \
        || return 1

    echo "===== WDROZENIE FRONTENDU ====="

    "${KUBECTL[@]}" \
        set image deployment/frontend \
        "frontend=${NEW_FRONTEND_IMAGE}" \
        || return 1

    "${KUBECTL[@]}" \
        annotate deployment/frontend \
        kubernetes.io/change-cause="Jenkins ${BUILD_NUMBER}, commit ${GIT_COMMIT}" \
        --overwrite \
        || return 1

    "${KUBECTL[@]}" \
        rollout status deployment/frontend \
        --timeout=300s \
        || return 1

    echo "===== STAN WDROZENIA ====="

    "${KUBECTL[@]}" \
        get deployments,pods \
        -o wide \
        || return 1

    echo "===== TEST HTTPS FRONTENDU ====="

    local health_response

    health_response="$(
        curl \
            --fail \
            --silent \
            --show-error \
            --connect-timeout 5 \
            --max-time 15 \
            "https://${APP_FQDN}/healthz"
    )" || return 1

    if [[ "$health_response" != "ok" ]]; then
        echo "BLAD: /healthz zwrocil: ${health_response}"
        return 1
    fi

    echo "===== TEST BACKENDU PRZEZ PROXY ====="

    curl \
        --fail \
        --silent \
        --show-error \
        --connect-timeout 5 \
        --max-time 15 \
        "https://${APP_FQDN}/api/health" \
        >/dev/null \
        || return 1

    return 0
}

if deploy; then
    echo "OK: wdrozenie SecureHash zakonczylo sie powodzeniem"
else
    deployment_result=$?

    echo "BLAD: wdrozenie SecureHash nie powiodlo sie"

    if rollback; then
        echo "OK: automatyczny rollback zakonczony"
    else
        echo "BLAD: automatyczny rollback wymaga recznej kontroli"
    fi

    exit "$deployment_result"
fi
