# Zabbix

Zabbix działa na VM `RockyZabbix` z Rocky Linux. Na tej samej maszynie
uruchomione są:

- Zabbix Server
- PostgreSQL
- Zabbix Agent 2
- Apache i PHP-FPM z panelem webowym

Do Zabbixa są dodane wszystkie serwery Windows oraz `RockyGUIAnsible`.
Agenty na maszynach Rocky Linux można instalować playbookiem Ansible z
[`linux/ansible/zabbix/`](../linux/ansible/zabbix/).
