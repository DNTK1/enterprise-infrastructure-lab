#!/bin/bash
set -Eeuo pipefail

# Rocky Linux Cloud Deploy

if (( $# != 6 )); then
    echo "Usage:"
    echo "$0 <VMID> <nazwa> <RAM_MB> <vCPU> <dysk_GB> <VLAN>"
	echo "Example:"
    echo "$0 160 rocky-test01 2048 2 30 20"
    exit 1
fi

VMID=${1:-}
HOSTNAME=${2:-}
RAM=${3:-}
CORES=${4:-}
DISK=${5:-}
VLAN=${6:-}

IFS= read -r -s -p "Hasło root (tylko konsola Proxmox): " \
ROOT_PASSWORD </dev/tty
printf '\n' >/dev/tty

IFS= read -r -s -p "Powtórz hasło root: " \
ROOT_PASSWORD_CONFIRM </dev/tty
printf '\n' >/dev/tty

if [[ -z "$ROOT_PASSWORD" || "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]]; then
    echo "Hasła są puste lub nie są identyczne."
    exit 1
fi

unset ROOT_PASSWORD_CONFIRM

# CONFIG

CEPH="RBD-POOL"

SMB="/mnt/pve/FileserverSMB"

IMAGE="$SMB/cloud-images/Rocky-10-GenericCloud.qcow2"

PROXMOX_NODE=$(hostname)

PROXMOX_KEY="$SMB/ssh/${PROXMOX_NODE}.pub"

ANSIBLE_KEY="$SMB/ssh/AnsibleVM.pub"

BRIDGE="vmbr0"
CPU="x86-64-v3"


# START

if qm status "$VMID" &>/dev/null
then

    echo "VMID $VMID już istnieje"

    exit 1

fi


if [[ ! -f "$IMAGE" ]]
then

    echo "Brak obrazu:"
    echo "$IMAGE"

    exit 1

fi


if [[ ! -f "$PROXMOX_KEY" ]]
then

    echo
    echo "Brak klucza noda Proxmox:"
    echo "$PROXMOX_KEY"

    exit 1

fi


if [[ ! -f "$ANSIBLE_KEY" ]]
then

    echo
    echo "Brak klucza Ansible:"
    echo "$ANSIBLE_KEY"

    exit 1

fi


echo
echo "================================="
echo " Rocky Linux Deployment"
echo "================================="
echo
echo "Node:"
echo "$PROXMOX_NODE"
echo "VMID:"
echo "$VMID"
echo "Hostname:"
echo "$HOSTNAME"
echo


echo "[1/10] Tworzenie VM"

# Chwilowo tak musi zostac - "vlan10" to główna sieć, bez taga vlana - do sfixowania
if [[ "$VLAN" != "10" ]]; then
qm create "$VMID" \
--name "$HOSTNAME" \
--memory "$RAM" \
--cores "$CORES" \
--cpu "$CPU" \
--machine q35 \
--net0 virtio,bridge="$BRIDGE",tag="$VLAN" \
--vga std
else
qm create "$VMID" \
--name "$HOSTNAME" \
--memory "$RAM" \
--cores "$CORES" \
--cpu "$CPU" \
--machine q35 \
--net0 virtio,bridge="$BRIDGE" \
--vga std
fi


echo "[2/10] Import obrazu"

qm importdisk \
"$VMID" \
"$IMAGE" \
"$CEPH"

echo "[3/10] Dysk"

qm set "$VMID" \
--scsihw virtio-scsi-single \
--scsi0 "$CEPH:vm-${VMID}-disk-0"
qm resize "$VMID" scsi0 "${DISK}G"


echo "[4/10] Cloud-init"

qm set "$VMID" \
--ide2 "$CEPH:cloudinit" \
--ciupgrade 0


echo "[5/10] SSH"

qm set "$VMID" \
--ciuser rocky \
--sshkey "$PROXMOX_KEY"


echo "[6/10] Sieć"

qm set "$VMID" \
--ipconfig0 ip=dhcp

qm set "$VMID" \
--nameserver "10.10.0.254 10.10.0.253"


echo "[7/10] QEMU Agent"

qm set "$VMID" \
--agent enabled=1

qm set "$VMID" \
--boot order=scsi0


echo "[8/10] Start VM"

qm start "$VMID"


echo
echo "Czekam na DHCP..."

IP=""

max_attempts=20
attempt=0

while [[ -z "$IP" && $attempt -lt $max_attempts ]]; do
    sleep 5
    ((++attempt))

    IP=$(qm guest cmd "$VMID" network-get-interfaces 2>/dev/null \
        | grep -oE "10\.${VLAN}\.0\.[0-9]+" \
        | head -1 || true)

    echo "... próba $attempt/$max_attempts"
done

if [[ -z "$IP" ]]; then
	qm set "$VMID" \
	--name "${HOSTNAME}-DHCPERROR"
    echo "Nie udało się pobrać adresu IP z DHCP."
    exit 1
fi

echo
echo "IP:"
echo "$IP"

ssh-keygen \
-f /root/.ssh/known_hosts \
-R "$IP" \
>/dev/null 2>&1 || true

NEWNAME="${HOSTNAME}-${IP}"
echo
echo "Zmiana nazwy VM:"
echo "$NEWNAME"

qm set "$VMID" \
--name "$NEWNAME"

echo
echo "Czekam SSH..."

attempt=0
until ssh \
-o BatchMode=yes \
-o StrictHostKeyChecking=no \
-o ConnectTimeout=5 \
rocky@"$IP" hostname
do
    ((++attempt))

    echo "SSH niedostępny... próba $attempt/$max_attempts"

    if (( attempt >= max_attempts )); then
        qm set "$VMID" \
        --name "${HOSTNAME}-SSHERROR"

        echo "Nie udało się połączyć przez SSH."
        exit 1
    fi

    sleep 5
done


echo
echo "[9/10] Konfiguracja systemu"

ssh \
-o BatchMode=yes \
-o StrictHostKeyChecking=no \
-o ConnectTimeout=5 \
rocky@"$IP" \
"sudo bash -Eeuo pipefail -s" <<EOF

cloud-init status --wait >/dev/null 2>&1 || true

mkdir -p /home/rocky/.ssh

cat >> /home/rocky/.ssh/authorized_keys <<KEY
$(cat "$ANSIBLE_KEY")
KEY

chown -R rocky:rocky /home/rocky/.ssh
chmod 700 /home/rocky/.ssh
chmod 600 /home/rocky/.ssh/authorized_keys

mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/00-disable-root-login.conf <<CONFIG
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
CONFIG

sshd -t
systemctl reload sshd

EOF

printf 'root:%s\n' "$ROOT_PASSWORD" | ssh \
-o BatchMode=yes \
-o StrictHostKeyChecking=no \
-o ConnectTimeout=5 \
rocky@"$IP" \
"sudo chpasswd"

unset ROOT_PASSWORD


echo
echo "[10/10] GOTOWE"
echo
echo "VMID:"
echo "$VMID"
echo
echo "Nazwa Proxmox:"
echo "$NEWNAME"
echo
echo "IP:"
echo "$IP"
echo
echo "SSH:"
echo "rocky@$IP"
echo "rocky@$HOSTNAME"
echo
