# Backup

TrueNAS SCALE działa na osobnym komputerze poza klastrem Proxmox. Ma dwa dyski 4 TB w mirrorze oraz osobny SSD systemowy.

Proxmox Backup Server działa jako kontener na hoście TrueNAS i jest dodany do klastra jako storage `ProxmoxBackup`. TrueNAS udostępnia też zasób `ProxmoxStorage` przez SMB dla obrazów cloud, skryptów i kluczy publicznych.

## Polityka wykonywania kopii

| Rodzaj kopii | Kiedy | Zakres |
|---|---|---|
| automatyczny backup VM | raz dziennie | wszystkie VM w głównym klastrze |
| dodatkowy backup ręczny | przed większą zmianą | zmieniana VM |
| snapshot etcd | co 6 godzin, 14 kopii | stan klastra K3s |

Backupy VM są zapisywane w PBS. Stan K3s ma dodatkowo snapshoty etcd.
