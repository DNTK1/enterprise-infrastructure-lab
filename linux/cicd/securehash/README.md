# SecureHash

Testowa aplikacja składająca się z backendu FastAPI oraz frontendu React. Projekt został przygotowany do nauki budowy pipeline'u CI/CD z wykorzystaniem Jenkinsa, Dockera, GitLab Container Registry i K3s.

Aplikacja pozwala podać tekst i wygenerować jego hash bcrypt.

## Uruchomienie lokalne

```bash
docker compose config
docker compose build --pull
docker compose up -d
docker compose ps
```

Zatrzymanie:

```bash
docker compose down
```

## Quality Gate

```bash
./scripts/quality-gate.sh
```

Skrypt sprawdza konfigurację Docker Compose, uruchamia testy i lint oraz buduje obrazy backendu i frontendu.

## Security Scan

```bash
./scripts/security-scan.sh
```

Trivy sprawdza repozytorium oraz obrazy aplikacji. Raporty zapisywane są w katalogu `reports/`.

## Pipeline

W Jenkinsie projekt przechodzi przez:

```text
kod
→ testy i lint
→ budowa obrazów
→ Trivy
→ GitLab Container Registry
→ K3s
```

Deployment do K3s wykonywany jest dla brancha `main`.