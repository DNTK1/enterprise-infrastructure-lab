# Zabbix nie łączył się z PostgreSQL

Połączenie z bazą działało z poziomu terminala, ale front end panelu Zabbix nie mógł połączyć się z bazą PostgreSQL.

Przyczyną była blokada SELinux dla procesu webowego. Przy SELinux ustawionym na `Permissive`, po tej zmianie połączył się z bazą i działał poprawnie, natomiast nie jest to ustawienia docelowe.

# FIXED

Pomogło:

```bash
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect=true
```

SELinux ustawiony na Enforcing (setenforce 1)