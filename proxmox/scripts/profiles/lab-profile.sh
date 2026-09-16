#!/bin/bash

set -e

# VM zarzadzane przez HA
ALWAYS=(100 101 104 105 106 150 107)
WINDOWS=(102 109 103)
CICD=(133 134 135 130 132 131)
HYBRIDAPP=(200)

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
        '^(quorum|master|service vm:(100|101|102|103|104|105|106|107|109|130|131|132|133|134|135|150|200))'
}

case "$1" in
    windows)
        echo "Wylaczam profil CI/CD..."
        ustaw_stan stopped "${CICD[@]}"
        czekaj_na_wylaczenie "${CICD[@]}"
        
        echo "Wylaczam profil HYBRIDAPP..."
        ustaw_stan stopped "${HYBRIDAPP[@]}"
        czekaj_na_wylaczenie "${HYBRIDAPP[@]}"

        echo "Uruchamiam profil Windows..."
        ustaw_stan started "${ALWAYS[@]}"
        ustaw_stan started "${WINDOWS[@]}"
        ;;

    cicd)
        echo "Wylaczam profil Windows..."
        ustaw_stan stopped "${WINDOWS[@]}"
        czekaj_na_wylaczenie "${WINDOWS[@]}"
        
        echo "Wylaczam profil HYBRIDAPP..."
        ustaw_stan stopped "${HYBRIDAPP[@]}"
        czekaj_na_wylaczenie "${HYBRIDAPP[@]}"

        echo "Uruchamiam profil CI/CD..."
        ustaw_stan started "${ALWAYS[@]}"
        ustaw_stan started "${CICD[@]}"
        ;;
        
    hybridapp)
        echo "Wylaczam profil Windows..."
        ustaw_stan stopped "${WINDOWS[@]}"
        czekaj_na_wylaczenie "${WINDOWS[@]}"
        
        echo "Wylaczam profil CI/CD..."
        ustaw_stan stopped "${CICD[@]}"
        czekaj_na_wylaczenie "${CICD[@]}"

        echo "Uruchamiam profil HYBRIDAPP..."
        ustaw_stan started "${ALWAYS[@]}"
        ustaw_stan started "${HYBRIDAPP[@]}"
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
