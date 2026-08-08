#!/bin/bash

set -e

# VM zarzadzane przez HA
ALWAYS=(100 101 104 106 150)
WINDOWS=(102 107 109 103)
CICD=(133 134 135 130 132 105 131)

sprawdz_zasoby_ha() {
    config=$(ha-manager config)
    brakujace=()

    for vmid in "${ALWAYS[@]}" "${WINDOWS[@]}" "${CICD[@]}"; do
        grep -q "^vm:$vmid$" <<< "$config" || brakujace+=("$vmid")
    done

    if ((${#brakujace[@]})); then
        echo "Blad: tych VM nie dodano do HA: ${brakujace[*]}"
        echo "Najpierw dodaj je w Datacenter -> HA -> Resources."
        exit 1
    fi
}

ustaw_stan() {
    stan=$1
    shift

    for vmid in "$@"; do
        echo "vm:$vmid -> $stan"
        ha-manager set "vm:$vmid" --state "$stan"
    done
}

jest_zatrzymana() {
    ha-manager status | grep -q "service vm:$1 .*stopped)"
}

czekaj_na_wylaczenie() {
    for vmid in "$@"; do
        echo "Czekam na wylaczenie vm:$vmid..."

        for _ in {1..60}; do
            jest_zatrzymana "$vmid" && break
            sleep 5
        done

        if ! jest_zatrzymana "$vmid"; then
            echo "Blad: vm:$vmid nie wylaczyla sie w ciagu 5 minut."
            exit 1
        fi
    done
}

pokaz_status() {
    ha-manager status | grep -E \
        '^(quorum|master|service vm:(100|101|102|103|104|105|106|107|109|130|131|132|133|134|135|150))'
}

case "$1" in
    windows)
        sprawdz_zasoby_ha

        echo "Wylaczam profil CI/CD..."
        ustaw_stan stopped "${CICD[@]}"
        czekaj_na_wylaczenie "${CICD[@]}"

        echo "Uruchamiam profil Windows..."
        ustaw_stan started "${ALWAYS[@]}"
        ustaw_stan started "${WINDOWS[@]}"
        ;;

    cicd)
        sprawdz_zasoby_ha

        echo "Wylaczam profil Windows..."
        ustaw_stan stopped "${WINDOWS[@]}"
        czekaj_na_wylaczenie "${WINDOWS[@]}"

        echo "Uruchamiam profil CI/CD..."
        ustaw_stan started "${ALWAYS[@]}"
        ustaw_stan started "${CICD[@]}"
        ;;

    status)
        pokaz_status
        exit 0
        ;;

    *)
        echo "Uzycie: $0 {windows|cicd|status}"
        exit 1
        ;;
esac

echo
echo "Zlecenia zostaly przekazane do HA. Aktualny status:"
pokaz_status
