# Losowe rozłączanie się kart sieciowych USB

Karty sieciowe usb co jakiś czas rozłaczają się i łącza ponownie, ponowne automatyczne połączenie z vmware działa, natomiast co jakiś czas Proxmox nie wyłapuje i przestaje działać sieć VM, `ifreload -a` chwilowo rozwiązuje problem.

# Próby fix

Do maszyn vmware dodany skip-reset `usb.quirks.device0 = "0x0bda:0x8156 skip-reset"`.
W Windowsie wyłączone oszczędzanie energii dla wszystkich kart sieciowych.
Ręcznie zaktualizowany sterownik Realteka.

# Automatyczny ifreload (systemd)

Dodatkowo dodany automatyczny fix przez ifreload -a opisany w [Rozłączanie kart sieciowych USB](../proxmox/systemd/ifreload-fix-nic)

# Fixed?

Do sprawdzenia czy problem będzie wracał, później można odczytać journalctl czy fix był użyty automatycznie, czy wystarczyły poprzednie zmiany.