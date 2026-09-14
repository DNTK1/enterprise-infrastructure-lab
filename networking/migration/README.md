# Migracje

## 14.09.2026 — DC do VLAN20

Przeniesiono kontrolery domeny z nieotagowanego LAN-u do VLAN20.
AD, DNS i DHCP zostały na tych samych maszynach.

| Maszyna | Stary IP | Nowy IP |
|---|---|---|
| DC1WinGUI | `10.10.0.254` | `10.20.0.10` |
| DC2WinGUI | `10.10.0.253` | `10.20.0.11` |

Maska: `/24`, nowa brama: `10.20.0.1`.

Zrobione:
- eksport DHCP z dzierżawami przed zmianami
- najpierw przeniesienie DC2, potem DC1: zmiana IP w Windows i tagu VLAN w Proxmox
- na czas każdej zmiany pozostawienie zakresów DHCP na drugim DC, potem odtworzenie failover
- poprawienie starych adresów w DNS i ustawienie forwarderów `1.1.1.1`, `8.8.8.8`

Kontrola po migracji:

```powershell
repadmin /replsummary
dcdiag /test:dns /e
Get-DhcpServerInDC
Get-DhcpServerv4Failover -ComputerName dc1wingui.domena.lab
Get-DhcpServerv4Failover -ComputerName dc2wingui.domena.lab
```
