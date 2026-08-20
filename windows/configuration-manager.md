# SQL Server i Configuration Manager

## Maszyny

| VM | Konfiguracja | Rola |
|---|---|---|
| `SQLWinGUI` | 4 vCPU, 12 GB RAM | SQL Server 2022 i SQL Server Agent |
| `SCCMWinGUI` | 4 vCPU, 9 GB RAM | Configuration Manager 2509, WSUS i SMS Provider |

SQL działa na osobnej VM i przechowuje bazę Configuration Manager. Limit `max server memory` jest ustawiony na około 8 GB, żeby zostawić pamięć dla systemu Windows.

## Funkcje

```
- Configuration Manager
- SQL Server na osobnej maszynie
- WSUS
- klient SCCM na komputerach testowych
- discovery komputerów, użytkowników i grup z Active Directory
```