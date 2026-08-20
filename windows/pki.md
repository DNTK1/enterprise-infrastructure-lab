# Dwuwarstwowe PKI

| System | Rola | Normalny stan |
|---|---|---|
| `PKI-ROOT01` | standalone Root CA | wyłączony i bez sieci |
| `PKI-ISS01` | domenowy Enterprise Issuing CA | profil `windows` |
| `PKI-WEB01` | Nginx publikujący AIA i CRL | profil `windows` |
| `DC1WinGUI`, `DC2WinGUI` | GPO i dystrybucja zaufania | profil `always` |

## Parametry

| Element | Ustawienie |
|---|---|
| Root CA | RSA 4096, SHA-256, ważność 20 lat |
| Issuing CA | RSA 4096, SHA-256, ważność 10 lat |
| certyfikat Proxmox | RSA 3072 |
| bazowy CRL | 7 dni |
| delta CRL | 1 dzień |

Root CA podpisuje Issuing CA i na co dzień pozostaje wyłączony. Certyfikat Root CA jest rozsyłany przez Active Directory, a autoenrollment GPO obsługuje certyfikaty komputerów domenowych. `PKI-WEB01` udostępnia AIA i CRL przez HTTP.

## Certyfikaty Proxmox

Każdy node tworzy lokalny klucz i CSR. Issuing CA wystawia certyfikat z nazwą DNS noda, a certyfikat i łańcuch są instalowane dla `pveproxy`:

```bash
pvenode cert set node.fullchain.pem node.key.pem -force
systemctl restart pveproxy
```

Root CA jest uruchamiany tylko wtedy, gdy trzeba podpisać CA pośrednią albo opublikować nową CRL. Przed większymi zmianami wykonywany jest backup AD CS.