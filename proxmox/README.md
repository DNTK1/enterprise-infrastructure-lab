# Proxmox VE

Główny klaster składa się z pięciu nodów Proxmox VE. Trzy działają jako
maszyny VMware na komputerze AMD, a dwa pozostałe na fizycznych komputerach
Intel.

| Plik | Zawartość |
|---|---|
| [cluster.md](cluster.md) | nody, storage, sieć i migracje |
| [ceph.md](ceph.md) | podstawowa konfiguracja Ceph RBD |
| [ha.md](ha.md) | maszyny dodane do HA i podział na profile |
| [profile-switching.md](profile-switching.md) | uruchamianie profilu Windows lub CI/CD |
| [nested-virtualization.md](nested-virtualization.md) | Proxmox uruchomiony wewnątrz VMware |
| [scripts/profiles/](scripts/profiles/) | skrypty profili i statusu |

W klastrze działa Corosync, Ceph RBD, HA i migracja maszyn. Każdy node ma
jeden MON i jeden OSD, a ruch Ceph korzysta z osobnej sieci z MTU 9000.
