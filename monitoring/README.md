# Monitoring

W labie działają dwa osobne systemy monitoringu:

| System | Co monitoruje |
|---|---|
| [Zabbix](zabbix.md) | serwery Windows i wybrane VM Linux |
| [Prometheus i Grafana](kubernetes.md) | nody, pody i zasoby klastra K3s |

Zabbix Agent 2 na serwerach Linux jest instalowany przez Ansible. Monitoring
K3s działa jako `kube-prometheus-stack`.
