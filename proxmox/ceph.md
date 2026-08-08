# Ceph RBD

Ceph jest wspólnym storage dla maszyn wirtualnych. Dzięki temu dysk VM jest
dostępny z każdego noda i nie trzeba go kopiować przy migracji.

## Konfiguracja

| Element | Ustawienie |
|---|---|
| Ceph | 19.2.3 Squid |
| MON | 5, po jednym na node |
| MGR | 1 aktywny i 1 zapasowy |
| OSD | 5, po jednym na node |
| pula VM | `RBD-POOL` |
| replikacja | `size=3`, `min_size=2` |
| PG | 128, autoscaler włączony |
| sieć | osobny switch, MTU 9000 |

`size=3` oznacza trzy kopie danych. Przy `min_size=2` pula może dalej
obsługiwać zapis, kiedy dostępne są przynajmniej dwie kopie.

## Pojemność

Łączna surowa pojemność pięciu OSD wynosi około **2,3 TiB**.
