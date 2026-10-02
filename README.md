# NEXUS AI Agency

A full-stack AI orchestration platform for multi-agent workflows, project intake, monitoring, and report generation.

## Stack
- Backend: FastAPI + SQLAlchemy + Redis + Pydantic
- Frontend: Next.js + TypeScript + Tailwind CSS
- Database: PostgreSQL
- Runtime: Docker Compose

## Quick start

```bash
docker compose up --build -d
```

Then open:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- Backend health: http://localhost:8000/health
- Swagger docs: http://localhost:8000/docs

## Project structure

```text
nexus-ai-agency/
├── docker-compose.yml
├── README.md
├── .gitignore
├── backend/
│   ├── .env
│   ├── .env.example
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── main.py
│   ├── api/
│   │   └── routes/
│   │       └── health.py
│   ├── core/
│   │   ├── config.py
│   │   └── database.py
│   ├── agents/
│   │   └── agents.yaml
│   └── services/
│       └── orchestrator.py
├── frontend/
│   ├── .env
│   ├── .env.example
│   ├── Dockerfile
│   ├── package.json
│   ├── next.config.mjs
│   ├── tsconfig.json
│   ├── next-env.d.ts
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   └── public/
├── docs/
│   ├── ARCHITECTURE.md
│   └── QUICKSTART.md
└── .github/
```

## Environment
Copy defaults if needed:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

## Notes
This scaffold is intentionally designed to be runnable immediately while leaving room for expansion into a full multi-agent platform with real orchestration, DB models, telemetry, and agent workflows.
