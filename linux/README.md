# Linux

Serwery Linux działają głównie na Rocky Linux 10. Do ich tworzenia i konfiguracji używam prostego skryptu Bash, cloud-init oraz Ansible.

| Katalog | Co zawiera |
|---|---|
| [deploy_rocky.sh](deploy_rocky.sh) | skrypt tworzący nową VM Rocky Linux |
| [ansible/](ansible/) | proste playbooki administracyjne i Zabbix Agent 2 |
| [cicd/](cicd/) | GitLab, Jenkins, K3s i testowa aplikacja SecureHash |

## Tworzenie VM Rocky Linux

Skrypt ustawia RAM, CPU, dysk, sieć, cloud-init, klucze SSH i QEMU Guest Agent, a na końcu uruchamia VM.

```bash
./deploy_rocky.sh <VMID> <nazwa> <RAM_MB> <vCPU> <dysk_GB> <VLAN>
```

Przykład:

```bash
./deploy_rocky.sh 160 rocky-test01 2048 2 30 20
```

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