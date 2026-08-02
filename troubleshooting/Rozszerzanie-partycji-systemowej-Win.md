# Rozszerzanie partycji systemowej Windows

Rozszerzanie dysku C jest problematyczne przez partycję Recovery, żeby rozszerzyć partycję Unallocated pamięć musi znajdować się obok niej.

![PartycjaRecovery](/images/PartycjaRecovery.png)

# FIX

Obejściem jest tymczasowe wyłączenie Recovery, usunięcie tej partycji, rozszerzenie partycji systemowej i przywrócenie Recovery.

W CMD jako admin:

```
reagentc /disable
diskpart
list disk
select disk 1 (trzeba wskazać dysk na którym jest partycja systemowa)
list partition (do wskazania partycja Recovery)
select partition 4
detail partition (trzeba zapisać Type i Attrib)
delete partition override
```

W tym momencie należy przejść do Disk managementu w Windowsie i rozszerzyć partycję C.

![ExtendVolumeC](/images/ExtendVolumeC.png)

Następnie w tym samym miejscu Shrink Volume o 1gb i trzeba utworzyć osobną partycję bez ustawiania jej litery, posłuży ona do odbudowy Recovery.

Po tym powrót do diskpart.

```
list parition
select partition 4 (do wskazania nowo utworzona partycja 1gb)
set id=<wpisz_Type>
gpt attributes=<wpisz_Attrib>
exit
reagentc /enable
```

Po tym w Disk management partycja powinna być od razu widoczna jako Recovery, jeżeli przypadkiem ustawiło się literę i dysk jest widoczny to trzeba w diskpart:

```
diskpart
list volume
select volume D (swoja litera)
remove letter=D
exit
```