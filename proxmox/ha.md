# Proxmox HA

Maszyny używane na co dzień są dodane do Proxmox HA. Przy awarii pojedynczego
noda HA może uruchomić je na innym nodzie.

## Podział maszyn

| Zestaw | VMID | Stan |
|---|---|---|
| `always` | 100, 101, 104, 106, 150 | zawsze uruchomione |
| `windows` | 102, 103, 107, 109 | uruchamiane w profilu Windows |
| `cicd` | 105, 130–135 | uruchamiane w profilu CI/CD |
| `offline` | 108 | Root CA, poza HA i normalnie wyłączona |

## Ustawienia

- `failback=1`, żeby VM same wracały na poprzedni node
- kontrolery domeny są rozdzielone pomiędzy różne nody
- SQL i SCCM są rozdzielone, żeby nie zajmowały razem większości RAM jednego
  hosta
- preferencje nodów nie są ustawione jako `strict`, więc po awarii VM może
  wystartować gdzie indziej
- przy zamykaniu noda używana jest polityka `failover`

Stan profilu zmieniają skrypty z katalogu
[`scripts/profiles/`](scripts/profiles/). Najpierw wyłączają jeden zestaw VM,
a dopiero później uruchamiają drugi.
