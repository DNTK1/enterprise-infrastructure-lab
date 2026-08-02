# Windows Server

Warstwa Windows odwzorowuje podstawowe usługi katalogowe, sieciowe,
certyfikatowe i zarządzania urządzeniami.

| Dokument | Zakres |
|---|---|
| [active-directory.md](active-directory.md) | AD DS, DNS, DHCP failover, GPO i NPS/RADIUS |
| [configuration-manager.md](configuration-manager.md) | SQL Server, Configuration Manager i WSUS |
| [identity-sync.md](identity-sync.md) | Entra Connect Sync i Tailscale |
| [pki.md](pki.md) | offline Root CA, Issuing CA, AIA/CDP i TLS Proxmox |
| [powershell/](powershell/) | Skrypty PowerShell |

## Role

| VM | Główne role |
|---|---|
| `DC1WinGUI`, `DC2WinGUI` | AD DS, AD-integrated DNS, DHCP failover, NPS/RADIUS |
| `SQLWinGUI` | SQL Server 2022 dla Configuration Manager |
| `SCCMWinGUI` | Microsoft Configuration Manager 2509 i WSUS |
| `CloudSyncWinGUI` | Microsoft Entra Connect Sync |
| `PKI-ROOT01` | offline Root CA |
| `PKI-ISS01` | Enterprise Issuing CA |
| `PKI-WEB01` | publikacja AIA/CDP przez Nginx na Rocky Linux |