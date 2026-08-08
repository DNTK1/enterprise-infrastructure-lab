# Przełączanie profilu Windows i CI/CD

Lab ma za mało RAM, żeby utrzymywać wszystkie maszyny włączone.
Cztery krótkie skrypty zmieniają stan VM w Proxmox HA.

## Listy VM

| Zestaw | Maszyny |
|---|---|
| `always` | 100 DC1, 101 DC2, 104 Zabbix, 106 CloudSync, 150 VPN |
| `windows` | 102 SQL, 103 SCCM, 107 PKI-ISS, 109 PKI-WEB |
| `cicd` | 105 Ansible, 130 GitLab, 131 Jenkins, 132 build, 133–135 K3s |
| `offline` | 108 PKI-ROOT, nie jest uruchamiana przez skrypt |

## Dodanie VM do HA

Wszystkie VM z pierwszych trzech zestawów muszą być dodane w:

```text
Datacenter → HA → Resources
```

Można je dodać również z terminala:

```bash
for id in 100 101 104 106 150; do
    ha-manager add "vm:$id" --state started --failback 1
done

for id in 102 103 105 107 109 130 131 132 133 134 135; do
    ha-manager add "vm:$id" --state stopped --failback 1
done
```

## Użycie

```bash
# pokaż stan
/mnt/pve/ProxmoxStorage/scripts/profil-status.sh

# włącz Windows
/mnt/pve/ProxmoxStorage/scripts/profil-windows.sh

# włącz CI/CD
/mnt/pve/ProxmoxStorage/scripts/profil-cicd.sh
```

Profil Windows najpierw wyłącza VM CI/CD, czeka na ich zatrzymanie, a później
uruchamia `always` i `windows`. Profil CI/CD robi to samo w drugą stronę.

Jeśli którejś VM nie dodano do HA, skrypt wypisze jej VMID i zakończy
działanie przed zmianą profilu.
