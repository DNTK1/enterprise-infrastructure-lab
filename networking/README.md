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

Problem z VLANami opisany w [troubleshooting/vlan-nested-virtualization.md](/troubleshooting/vlan-nested-virtualization.md).
VLANy są już dodane i działają poprawnie, natomiast przez ten problem cała sieć od poczatku była tworzona na głównym nieotagowanym lanie (10).
W przyszłości do poprawy, na ten moment tak zostaje, ponieważ zmiana adresacji nie jest tak prosta i może spowodować dużo różnych losowych problemów.

| VLAN | Nazwa zakresu DHCP | Podsieć | Pula DHCP |
|---:|---|---|---|
| 10 | `DefaultVLAN10` | `10.10.0.0/24` | `10.10.0.120–220` |
| 20 | `ServersVLAN20` | `10.20.0.0/24` | `10.20.0.100–200` |
| 30 | `ClientsVLAN30` | `10.30.0.0/24` | `10.30.0.100–250` |
| 40 | `WIFIVLAN40` | `10.40.0.0/24` | `10.40.0.100–250` |
| 50 | `VPNVLAN50` | `10.50.0.0/24` | `10.50.0.100–250` |

VLAN 10 jest siecią native/untagged na moście `vmbr0`. Pozostałe sieci są
przenoszone jako tagowane VLAN-y. Routing między nimi, NAT oraz reguły dostępu
realizuje OPNsense.

## Sieć Ceph

Ceph ma własne interfejsy i osobny switch. Komputer Ryzen (`Lab1` `Lab2` `Lab3`) jest podłączony
przez 10 GbE, a `Lab4` i `Lab5` przez 2.5 GbE. Na całej ścieżce ustawione jest
MTU 9000.

## Zdalny dostęp

Tailscale działa na VM `RockyVPN`. Użytkownicy z lokalnego Active Directory są
synchronizowani do Entra ID i tym samym kontem logują się do Tailscale.
