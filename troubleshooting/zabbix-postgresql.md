# Zabbix nie łączył się z PostgreSQL

Połączenie z bazą działało z `psql`, ale instalator webowego panelu Zabbix nie
mógł połączyć się z PostgreSQL.

Najbardziej prawdopodobną przyczyną była blokada SELinux dla procesu
webowego. SELinux został ustawiony na `Permissive`, a kompletny stos Zabbix
z PostgreSQL, Apache i PHP-FPM został zainstalowany ponownie. Po tej zmianie
panel połączył się z bazą i działa poprawnie.

# FIXED

Pomogło:

```bash
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect=true
```

SELinux ustawiony na Enforcing (setenforce 1)