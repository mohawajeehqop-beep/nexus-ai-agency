# Deployment instructions (production notes)

## Overview
This project can be deployed using Docker Compose for single-host setups, or containerized to Kubernetes/ECS for scalable deployments. The services include:
- Backend (FastAPI)
- Worker (RQ)
- Frontend (Next.js)
- PostgreSQL
- Redis

## Environment
- Set secure values in environment variables or your secrets manager. Do NOT commit production secrets into the repository.

## Running in production (example using docker-compose)

1. Update `.env` files in `/backend` and `/frontend` with production values.
2. Build images and run with non-dev commands (no --reload for uvicorn, run `npm build` and `npm start` for frontend):

```bash
docker compose build --no-cache
docker compose up -d
```

## Scaling
- Use multiple replicas of backend and worker behind a load balancer.
- Move Postgres to managed service (RDS) and use persistent volumes.
- Use a managed Redis (Elasticache, Redis Labs) in production.

## Migrations
This scaffold includes SQLAlchemy models and Alembic is installed. Initialize Alembic and create migration scripts before applying to production DB.
