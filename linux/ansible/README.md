# Ansible

Playbooki są uruchamiane z maszyny `RockyGUIAnsible`. Służą do zwykłych prac
na serwerach Rocky Linux oraz do instalacji elementów platformy CI/CD.

## Playbooki

| Playbook | Co robi |
|---|---|
| `playbooks/dnfupdate.yml` | aktualizuje pakiety |
| `playbooks/dnfinstalltools.yml` | instaluje narzędzia administracyjne |
| `playbooks/firewallportopen.yml` | otwiera wybrane porty w firewalld |
| `playbooks/firewallportclose.yml` | zamyka te same porty |
| `playbooks/Zabbixclientinstall.yml` | instaluje agenta i konfiguruje go razem z firewallem |

Przykład:

```bash
ansible-playbook Zabbixclientinstall.yml
```