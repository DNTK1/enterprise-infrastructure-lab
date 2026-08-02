# SecureHash Lab — etap Docker Compose

## Uruchomienie

```bash
docker compose config
docker compose build --pull
docker compose up -d
docker compose ps
```

Aplikacja: `http://ADRES_BUILD01:8080`

## Testy

```bash
curl -fsS http://127.0.0.1:8080/healthz
curl -fsS http://127.0.0.1:8080/api/health | jq
curl -fsS -X POST http://127.0.0.1:8080/api/hash \
  -H 'Content-Type: application/json' \
  -d '{"password":"Lab-Test-123!"}' | jq
```

## Logi i zatrzymanie

```bash
docker compose logs --tail=100
docker compose down
```

## Quality gate

```bash
./scripts/quality-gate.sh
```

Skrypt sprawdza Compose, uruchamia testy i coverage backendu, lint obu części oraz buduje obrazy.

## Security scan

Po instalacji Trivy:

```bash
./scripts/security-scan.sh
```

Raporty są zapisywane w katalogu `reports/`.
