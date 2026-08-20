# SecureHash Status

Prosta aplikacja przygotowana w celach edukacyjnych do przećwiczenia pełnego procesu CI/CD — od git push, przez testy i budowę obrazu, aż po automatyczne wdrożenie aplikacji do klastra K3s.

Projekt służył głównie do praktycznej nauki integracji GitLaba, Jenkinsa, Container Registry oraz Kubernetes/K3s.

## Pipeline

```text
git push
- GitLab webhook
- Jenkins Multibranch Pipeline
- Quality Gate
- Security Scan
- GitLab Container Registry
- K3s
- NGINX Ingress
- status.domena.lab
```

Branche robocze przechodzą testy i skany bezpieczeństwa. Publikacja obrazu oraz deployment do K3s wykonywane są tylko z brancha `main`.

Pipeline wykonuje:

```
- lint kodu przy pomocy `ruff`;
- testy `pytest`;
- skan zależności przez `pip-audit`;
- analizę kodu przez `bandit`;
- budowę obrazu Docker;
- publikację obrazu do prywatnego GitLab Container Registry;
- deployment aplikacji do K3s;
- sprawdzenie poprawnego rollout'u.
```

Obrazy są tagowane skróconym SHA commita, dzięki czemu można łatwo sprawdzić, jaka wersja aplikacji działa w klastrze.

## Kubernetes

```text
Deployment (2 repliki)
- Service ClusterIP
- NGINX Ingress
```

Jenkins korzysta z osobnego ServiceAccount `jenkins-deployer` z ograniczonym RBAC.

K3s pobiera obrazy z Registry przy użyciu osobnego Deploy Tokena posiadającego tylko uprawnienie `read_registry`.