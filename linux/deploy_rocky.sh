#!/bin/bash

set -Eeuo pipefail

# Rocky Linux Cloud Deploy
# Proxmox + Ceph RBD + Cloud-init


VMID=${1:-}
HOSTNAME=${2:-}
RAM=${3:-}
CORES=${4:-}
DISK=${5:-}
VLAN=${6:-}
ROOT_PASSWORD="${7:-}"

if [[ -z "$VMID" || -z "$HOSTNAME" ]]; then

    echo "Usage:"
    echo "$0 VMID hostname"

    exit 1

fi

# CONFIG

CEPH="RBD-POOL"

SMB="/mnt/pve/ProxmoxStorage"

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

if [ $VLAN != 10 ] ; then
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
--ide2 "$CEPH:cloudinit"




echo "[5/10] SSH"


qm set "$VMID" \
--ciuser rocky



qm set "$VMID" \
--cipassword "$ROOT_PASSWORD"



qm set "$VMID" \
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


while [[ -z "$IP" ]]
do

    sleep 10


    IP=$(qm guest cmd "$VMID" network-get-interfaces 2>/dev/null \
    | grep -oE "10\.${VLAN}\.0\.[0-9]+" \
    | head -1 || true)


    echo "..."

done



echo
echo "IP:"
echo "$IP"



NEWNAME="${HOSTNAME}-${IP}"


echo
echo "Zmiana nazwy VM:"
echo "$NEWNAME"


qm set "$VMID" \
--name "$NEWNAME"



echo
echo "Czekam SSH..."


until ssh \
-o StrictHostKeyChecking=no \
-o ConnectTimeout=5 \
rocky@"$IP" hostname

do

    echo "SSH niedostępny..."

    sleep 10

done



echo
echo "Konfiguracja root i Ansible SSH key..."



ssh \
-o StrictHostKeyChecking=no \
rocky@"$IP" \
"sudo bash -s" <<EOF


echo 'root:$ROOT_PASSWORD' | chpasswd


mkdir -p /root/.ssh


cp /home/rocky/.ssh/authorized_keys \
/root/.ssh/authorized_keys



cat >> /root/.ssh/authorized_keys <<KEY

$(cat "$ANSIBLE_KEY")

KEY



chmod 700 /root/.ssh

chmod 600 /root/.ssh/authorized_keys



sed -i \
's/^#PermitRootLogin.*/PermitRootLogin yes/' \
/etc/ssh/sshd_config



systemctl restart sshd


EOF




echo
echo "================================="
echo " GOTOWE"
echo "================================="

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
echo "root@$IP"

echo

echo "Hasło awaryjne:"
echo "$ROOT_PASSWORD"

echo
