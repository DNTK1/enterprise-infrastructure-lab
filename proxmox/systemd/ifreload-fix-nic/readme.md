# Fix dla losowo rozłączających się karty sieciowych USB dla nested pve Lab1-3

```
/etc/systemd/system/ifreload-fix-nic.service
/etc/udev/rules.d/rtl8156-recovery.rules
```

```
systemctl daemon-reload
udevadm control --reload-rules
```

# Test

Odłączona i podłączona karta sieciowa, poprawnie aktywował się fix i sieć wstała.

```
journalctl -fu ifreload-fix-nic.service
Sep 01 17:52:52 Lab1 systemd[1]: Starting ifreload-fix-nic.service - Fix dla USB NIC (ifreload po reconnect)...
Sep 01 17:52:57 Lab1 systemd[1]: ifreload-fix-nic.service: Deactivated successfully.
Sep 01 17:52:57 Lab1 systemd[1]: Finished ifreload-fix-nic.service - Fix dla USB NIC (ifreload po reconnect).
Sep 01 18:13:26 Lab1 systemd[1]: Starting ifreload-fix-nic.service - Fix dla USB NIC (ifreload po reconnect)...
Sep 01 18:13:31 Lab1 systemd[1]: ifreload-fix-nic.service: Deactivated successfully.
Sep 01 18:13:31 Lab1 systemd[1]: Finished ifreload-fix-nic.service - Fix dla USB NIC (ifreload po reconnect).
```