# Live migration z nested AMD do Intel

## Objaw

Live migration VM Windows z `Lab1`–`Lab3` do `Lab4` lub `Lab5` kończy się
błędem Windowsa `MEMORY_MANAGEMENT`. Ta sama VM uruchamia się poprawnie po cold
migration.

## Potwierdzony zakres

| Kierunek | Wynik |
|---|---|
| AMD nested → AMD nested | działa online |
| Intel → Intel | działa online |
| Intel → AMD nested | działa online |
| AMD nested → Intel | crash Windowsa |
| AMD nested → Intel po wyłączeniu VM | działa |

VM używają wspólnego modelu CPU `x86-64-v3`. Próby zmiany modelu CPU nie
usunęły problemu.

## Wniosek

Nie ma wystarczających danych, aby przypisać błąd wyłącznie różnicy AMD/Intel lub nested virtualization.

## Fix

Jedyny fix to raczej upgrade infrastruktury i pozbycie się wirtualnych Proxmoxów.