# Linux

Serwery Linux działają głównie na Rocky Linux 10. Do ich tworzenia i konfiguracji używam prostego skryptu Bash, cloud-init oraz Ansible.

| Katalog | Co zawiera |
|---|---|
| [ansible/](ansible/) | proste playbooki administracyjne i Zabbix Agent 2 |
| [cicd/](cicd/) | GitLab, Jenkins, K3s i testowa aplikacja SecureHash |

## Maszyny Linux

| VM | Rola |
|---|---|
| `RockyGUIAnsible` | maszyna administracyjna z Ansible |
| `RockyZabbix` | Zabbix Server, PostgreSQL i panel webowy |
| `RockyVPN` | Tailscale |
| `gitlab01` | GitLab CE i Container Registry |
| `jenkins01` | Jenkins Controller |
| `build01` | Jenkins Agent, Docker, Trivy i kubectl |
| `k3s01`–`k3s03` | trzy serwery K3s z embedded etcd |