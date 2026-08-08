# Klaster Proxmox VE

## Nody

- `Lab1`–`Lab3` działają w VMware Workstation na jednym komputerze AMD Ryzen;
- `Lab4` i `Lab5` to dwa osobne fizyczne komputery Intel.

| Node | Platforma | RAM | CPU |
|---|---|---:|---:|
| `Lab1` | VMware / AMD Ryzen 9800X3D | 16 GiB | 5 vCPU |
| `Lab2` | VMware / AMD Ryzen 9800X3D | 16 GiB | 5 vCPU |
| `Lab3` | VMware / AMD Ryzen 9800X3D | 16 GiB | 5 vCPU |
| `Lab4` | fizyczny Intel i5-7600 | 16 GiB | 4 rdzenie |
| `Lab5` | fizyczny Intel i5-7600 | 16 GiB | 4 rdzenie |

Taki układ pozwala ćwiczyć klaster pięciowęzłowy bez posiadania pięciu
osobnych serwerów.

## Storage

| Storage | Zastosowanie |
|---|---|
| `RBD-POOL` | dyski VM na Ceph RBD |
| `ProxmoxStorage` | zasób SMB z obrazami cloud, skryptami i kluczami |
| `ProxmoxBackup` | backupy w Proxmox Backup Server |

## Sieć Ceph

Ceph korzysta z osobnych interfejsów i osobnego switcha:

- 10 GbE po stronie komputera Ryzen;
- 2.5 GbE dla `Lab4` i `Lab5`;
- MTU 9000 na całej ścieżce.

## Migracje

Wszystkie VM używają modelu CPU `x86-64-v3`.

| Kierunek | Live migration | Cold migration |
|---|---|---|
| AMD nested → AMD nested | działa | działa |
| Intel → Intel | działa | działa |
| Intel → AMD nested | działa | działa |
| AMD nested → Intel | błąd Windows `MEMORY_MANAGEMENT` | działa |

Opis błędu znajduje się w
[`troubleshooting/live-migration-amd-intel.md`](../troubleshooting/live-migration-amd-intel.md).
