# Sieć

## Główne elementy

| Element | Zadanie |
|---|---|
| OPNsense | routing, NAT i firewall |
| `DC1WinGUI`, `DC2WinGUI` | DNS i DHCP failover |
| NPS/RADIUS | logowanie urządzeń przez konta Active Directory |
| `RockyVPN` | zdalny dostęp przez Tailscale |
| Microsoft Entra ID | logowanie użytkowników do Tailscale |
| osobna sieć Ceph | ruch storage pomiędzy nodami |
| ASUS AX3600 | Wi-Fi w sieci laboratoryjnej |

OPNsense działa jako VM na osobnym hoście `LabFirewall`, poza głównym
klastrem. DNS i DHCP działają na kontrolerach domeny Windows.

## VLAN

Przez wcześniejszy [problem z VLAN-ami w nested virtualization](../troubleshooting/vlan-nested-virtualization.md)
większość laba powstała w nieotagowanym LAN-ie `10.10.0.0/24`.
Problem jest rozwiązany i zacząłem migrować maszyny do nowego podziału sieci.
Kontrolery domeny są już w VLAN20, a pozostałe maszyny są przenoszone etapami.

| LAN / VLAN | Nazwa | Podsieć | Docelowe zastosowanie |
|---|---|---|---|
| 10 | MGMT | `10.10.0.0/24` | (untagged) hosty Proxmox, zarządzanie switchami, komputer admina |
| 20 | IDENTITY | `10.20.0.0/24` | kontrolery domeny, `CloudSyncWinGUI`, `PKI-ISS01` |
| 30 | SERVERS | `10.30.0.0/24` | pozostałe serwery, monitoring i istniejące środowisko CI/CD oraz K3s |
| 40 | BACKUP | `10.40.0.0/24` | Proxmox Backup Server |
| 50 | VPN | `10.50.0.0/24` | maszyny zapewniające dostęp przez VPN |
| 60 | CLIENTS | `10.60.0.0/24` | klienci testowi i Wi-Fi |
| 90 | HYBRIDAPP | `10.90.0.0/24` | nowe środowisko aplikacji hybrydowej |

LAN pozostaje nieotagowany, z bramą `10.10.0.1`. Nie zmieniam adresów hostów
Proxmox ani sieci Ceph. Pozostałe sieci używają tagów VLAN, a routing, NAT
i reguły dostępu realizuje OPNsense. Brama w każdej z tych podsieci ma adres `.1`.

## Sieć Ceph

Ceph ma własne interfejsy i osobny switch. Komputer Ryzen (`Lab1` `Lab2` `Lab3`) jest podłączony
przez 10 GbE, a `Lab4` i `Lab5` przez 2.5 GbE. Na całej ścieżce ustawione jest
MTU 9000.

## Zdalny dostęp

Tailscale działa na VM `RockyVPN`. Użytkownicy z lokalnego Active Directory są
synchronizowani do Entra ID i tym samym kontem logują się do Tailscale.
