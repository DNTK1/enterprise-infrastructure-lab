# VLAN problem przez nested virtualization

Otagowane VLANy 20, 30, 40, 50 działają poprawnie na Lab 4 i 5 (fizyczne stacje Intel).
Na Lab 1,2,3 te same VM nie dostają adresu IP na tych vlanach, na ten moment muszą zostać na nieotagowanym vlanie 10.
Problem jest przez nested virtualization - bridge sieciówki w Proxmoxie do bridga sieciówki w VMWare Workstation.
Zmieniłem w ustawieniach VMWare:
```
ethernet0.noPromisc = "FALSE"
ethernet0.noForgedSrcAddr = "FALSE"
```
Natomiast to nie pomogło.

Przykładowy VM odbija się na switchu na poprawnym vlanie:
BC:24:11:9E:ED:E6	dynamic	2	20
Więc problem musi być gdzieś dalej.

Prawdopodobnie jedyny fix to zmiana infrastruktury, na ten moment trzeba używać nieotagowanego vlana 10 dla wszystkiego.

# 29.07.2026

Problem prawdopodobnie jest między VMWare Workstation a Windowsem, wypuszcza ruch dalej na otagowanym vlanie, ale filtruje ruch powrotny.

Możliwy fix to przekazanie osobnej karty sieciowej USB dla zagnieżdzonego Proxmoxa, żeby pominąć komunikację Windows - bridge VMware.

# FIXED

Problem rozwiązało dodanie dodatkowych kart sieciowych USB dla każdego noda, następnie przekazanie ich bezpośrednio w VMware dla Proxmoxa.

# Dodanie osobnych kart sieciowych do VMWare Workstation

Karty muszą być zapamiętane dla każdego noda osobna w tym celu trzeba przekazać kartę po USB w VMWare (VM -> Removable devices).
Po dodaniu komendą w powershellu można sprawdzić jej path, u mnie np. 1/2/1:

```
Select-String -Path .\vmware.log -Pattern "vid:0bda pid:8156" | Select-Object -Last 5
```

Następnie trzeba wyłączyć VM i w .vmx dopisać (zależnie od path):

```
usb.autoConnect.device0 = "vid:0bda pid:8156 path:1/2/1 autoclean:0"
```

Dla każdej VM to samo, następnie Proxmox:

```
lsusb | grep 0bda:8156
ip -br link | grep enx
```

Następnie trzeba dodać nowy bridge w Proxmoxie i nazwa bridge ports będzie z poprzedniej komendy np. enx18694503a656