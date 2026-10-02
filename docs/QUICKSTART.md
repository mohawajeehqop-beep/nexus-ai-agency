# Quickstart

## Requirements
- Docker Desktop
- Docker Compose
- Node.js 20+
- Python 3.12+

## Start the full stack

```bash
docker compose up --build -d
```

## Verify

```bash
curl http://localhost:8000/health
curl http://localhost:3000
```

## Stop

```bash
docker compose down
```
