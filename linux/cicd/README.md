# CI/CD

Ta część laba służy do praktycznej nauki budowy pipeline'ów CI/CD z wykorzystaniem GitLaba, Jenkinsa, Dockera i K3s.

## Środowisko

| Element       | Zadanie                                          |
| ------------- | ------------------------------------------------ |
| GitLab CE     | repozytoria, Merge Requesty i Container Registry |
| Jenkins       | wykonywanie pipeline'ów                          |
| `build01`     | agent Jenkins, Docker i `kubectl`                |
| K3s           | uruchamianie aplikacji                           |
| MetalLB       | adresy `LoadBalancer`                            |
| NGINX Ingress | dostęp do aplikacji                              |

Klaster K3s składa się z trzech nodów: `k3s01`, `k3s02` i `k3s03`.

## Projekty

### SecureHash

Pierwszy, bardziej rozbudowany przykład pipeline'u. Aplikacja składa się z backendu FastAPI i frontendu React.

Pipeline wykonuje m.in.:

* testy i lint;
* budowę obrazów Docker;
* skanowanie Trivy;
* publikację obrazów do GitLab Container Registry;
* deployment do K3s dla brancha `main`;
* sprawdzenie aplikacji po wdrożeniu.

Kod i podstawowe informacje: [`securehash/`](securehash/)

### SecureHash Status

Prostsza aplikacja FastAPI przygotowana głównie w celu nauki pełnego procesu CI/CD.

```text
git push
→ GitLab webhook
→ Jenkins Multibranch
→ testy i security scan
→ Container Registry
→ K3s
→ NGINX Ingress
```

Branche robocze przechodzą testy i skany, natomiast publikacja obrazu oraz deployment wykonywane są tylko z `main`.

Kod i opis: [`securehash-status/`](securehash-status/)

## Infrastruktura

Konfiguracja platformy CI/CD i klastra znajduje się w:

[`infrastructure/ansible/`](infrastructure/ansible/)
