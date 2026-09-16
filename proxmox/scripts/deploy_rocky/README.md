## Tworzenie VM Rocky Linux

Skrypt ustawia RAM, CPU, dysk, sieć, cloud-init, klucze SSH i QEMU Guest Agent, a na końcu uruchamia VM.

```bash
./deploy_rocky.sh <VMID> <nazwa> <RAM_MB> <vCPU> <dysk_GB> <VLAN>
```

Przykład:

```bash
/mnt/pve/FileserverSMB/scripts/deploy_rocky.sh 160 rocky-test01 2048 2 30 30
```