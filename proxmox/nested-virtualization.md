# Proxmox wewnątrz VMware

`Lab1`, `Lab2` i `Lab3` są maszynami VMware Workstation uruchomionymi na
komputerze z procesorem AMD Ryzen.

## Sieć VMware

| Sieć | Fizyczny interfejs |
|---|---|
| `VMnet0` | Realtek 10 GbE |
| `VMnet2` | Realtek 2.5 GbE |

Obie sieci są ustawione ręcznie jako bridged. VMware nie korzysta z opcji
`Automatic bridging`.

## Ustawienia hosta

W UEFI jest włączone AMD-V/SVM.

Na hoście Windows wyłączone są:

- Hyper-V
- Virtual Machine Platform
- Windows Hypervisor Platform
- Windows Sandbox
- Memory Integrity
- VBS i Credential Guard

Dzięki temu VMware korzysta bezpośrednio z AMD-V i może uruchomić Proxmox,
a Proxmox kolejne maszyny KVM. W tym ustawieniu nie działa WSL2, ponieważ
korzysta z hypervisora Windows.

Secure Boot, TPM, Microsoft Defender i Windows Firewall pozostają włączone.
