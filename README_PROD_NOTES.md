# Production-ready notes

This repository has been expanded to include:
- JWT authentication (register / token)
- SQLAlchemy models for users/projects/tasks
- RQ worker for background orchestration
- Worker service in docker-compose
- Basic frontend auth pages (login) + Dashboard
- Docs: DEPLOYMENT, SECURITY, CONTRIBUTING

Next recommended steps before production:
- Run `python backend/create_tables.py` or run migrations via Alembic
- Replace `.env` secrets with secure values
- Setup monitoring (Sentry / Langfuse) and rate-limiting
- Harden CORS and network access
