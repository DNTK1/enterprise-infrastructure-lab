# Ansible

Playbooki są uruchamiane z maszyny `RockyGUIAnsible`. Służą do zwykłych prac
na serwerach Rocky Linux oraz do instalacji elementów platformy CI/CD.

## Proste playbooki

| Playbook | Co robi |
|---|---|
| `playbooks/dnfupdate.yml` | aktualizuje pakiety |
| `playbooks/dnfinstalltools.yml` | instaluje narzędzia administracyjne |
| `playbooks/firewallportopen.yml` | otwiera wybrane porty w firewalld |
| `playbooks/firewallportclose.yml` | zamyka te same porty |

Przykład:

```bash
ansible-playbook -i inventory.ini playbooks/dnfupdate.yml
```

## Zabbix Agent 2

Playbook `zabbix/Zabbixclientinstall.yml` instaluje agenta, wpisuje adres serwera
Zabbix, ustawia nazwę hosta, otwiera port `10050/tcp` i uruchamia usługę.