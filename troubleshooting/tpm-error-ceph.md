# Maszyna nie wstawała przez błąd tpm (ceph)

```
/bin/swtpm exit with status 256: 
TASK ERROR: start failed: command 'swtpm_setup --tpmstate file:///dev/rbd-pve/2f46fc29-e690-40d8-821c-6139162bd9dd/RBD-POOL/vm-100-disk-2 --createek --create-ek-cert --create-platform-cert --lock-nvram --config /etc/swtpm_setup.conf --runas 0 --not-overwrite --tpm2 --ecc' failed: exit code 1
```

# Fix

Wyłączenie vm i zmapowanie ręcznie dysku TPM.

```
ha-manager set vm:100 --state disabled
rbd -c /etc/pve/ceph.conf -p RBD-POOL map vm-100-disk-2
qm start 100
ha-manager set vm:100 --state started
```