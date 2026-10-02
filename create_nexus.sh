#!/bin/bash
set -e
P="nexus-ai-agency"
mkdir -p "$P" && cd "$P"

# === ROOT ===
cat > README.md << 'EOF'
# NEXUS AI Agency
Enterprise Multi-Agent System - 20 Agents
## Quick Start
./setup.sh && docker-compose up -d
EOF

cat > .gitignore << 'EOF'
.env
.env.local
__pycache__/
node_modules/
.next/
*.pyc
postgres_data/
redis_data/
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  api:
    build: ./backend
    ports: ["8000:8000"]
    env_file: ./backend/.env
    depends_on: [db, redis]
    volumes: [./backend:/app]
  frontend:
    build: ./frontend
    ports: ["3000:3000"]
    env_file: ./frontend/.env.local
    depends_on: [api]
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: nexus_user
      POSTGRES_PASSWORD: nexus_password
      POSTGRES_DB: nexus_db
    ports: ["5432:5432"]
    volumes: [postgres_data:/var/lib/postgresql/data]
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
    volumes: [redis_data:/data]
volumes:
  postgres_data:
  redis_data:
EOF

cat > setup.sh << 'EOF'
#!/bin/bash
set -e
[ ! -f backend/.env ] && cp backend/.env.example backend/.env
[ ! -f frontend/.env.local ] && cp frontend/.env.example frontend/.env.local
echo "✅ Setup done. Edit backend/.env then: docker-compose up -d"
EOF
chmod +x setup.sh

# === BACKEND ===
mkdir -p backend/{agents,api/routes,api/models,services,core,models,tests}

cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim as builder
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
FROM python:3.11-slim
RUN apt-get update && apt-get install -y libpq5 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
EOF

cat > backend/requirements.txt << 'EOF'
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0
python-dotenv==1.0.0
python-multipart==0.0.6
crewai==0.19.0
crewai-tools==0.0.16
openai==1.10.0
langchain==0.1.5
langchain-openai==0.0.5
langfuse==2.16.2
sentence-transformers==2.3.1
tiktoken==0.5.2
sqlalchemy==2.0.25
asyncpg==0.29.0
alembic==1.13.1
redis==5.0.1
chromadb==0.4.22
httpx==0.26.0
numpy==1.26.3
pandas==2.2.0
pyyaml==6.0.1
structlog==24.1.0
sentry-sdk==1.40.0
pytest==7.4.4
pytest-asyncio==0.23.3
EOF

cat > backend/.env.example << 'EOF'
APP_ENV=development
APP_PORT=8000
POSTGRES_USER=nexus_user
POSTGRES_PASSWORD=nexus_password
POSTGRES_DB=nexus_db
DATABASE_URL=postgresql+asyncpg://nexus_user:nexus_password@db:5432/nexus_db
REDIS_URL=redis://redis:6379/0
OPENAI_API_KEY=sk-your-openai-key-here
OPENAI_MODEL_PRIMARY=gpt-4o
OPENAI_MODEL_ECONOMY=gpt-4o-mini
SEMANTIC_CACHE_THRESHOLD=0.92
SEMANTIC_CACHE_TTL=86400
SEMANTIC_CACHE_MAX_SIZE=10000
QA_EVALUATION_MODEL=gpt-4o-mini
SECRET_KEY=change-me-to-random-32-chars
CORS_ORIGINS=["http://localhost:3000"]
LANGFUSE_PUBLIC_KEY=
LANGFUSE_SECRET_KEY=
EOF

cat > backend/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 NEXUS AI Agency: System Initialized")
    yield
    logger.info("🛑 NEXUS AI Agency: System Shutting Down")

app = FastAPI(title="NEXUS AI Agency API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "nexus-api", "version": "1.0.0"}

from api.routes import agents, dashboard
app.include_router(agents.router)
app.include_router(dashboard.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
EOF

cat > backend/core/__init__.py << 'EOF'
EOF

cat > backend/core/config.py << 'EOF'
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    APP_ENV: str = "development"
    APP_PORT: int = 8000
    DATABASE_URL: str = "postgresql+asyncpg://nexus_user:nexus_password@db:5432/nexus_db"
    REDIS_URL: str = "redis://redis:6379/0"
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL_PRIMARY: str = "gpt-4o"
    OPENAI_MODEL_ECONOMY: str = "gpt-4o-mini"
    SEMANTIC_CACHE_THRESHOLD: float = 0.92
    SEMANTIC_CACHE_TTL: int = 86400
    SEMANTIC_CACHE_MAX_SIZE: int = 10000
    QA_EVALUATION_MODEL: str = "gpt-4o-mini"
    SECRET_KEY: str = "change-me"
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]
    
    class Config:
        env_file = ".env"

settings = Settings()
EOF

cat > backend/core/database.py << 'EOF'
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from core.config import settings

engine = create_async_engine(settings.DATABASE_URL, echo=False)
async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db():
    async with async_session() as session:
        yield session
EOF

cat > backend/core/redis_client.py << 'EOF'
import redis
from core.config import settings

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
EOF

cat > backend/core/llm_client.py << 'EOF'
import openai
from core.config import settings

openai.api_key = settings.OPENAI_API_KEY

class LLMClient:
    async def generate(self, prompt: str, model: str = None, temperature: float = 0.7, max_tokens: int = 4000):
        model = model or settings.OPENAI_MODEL_PRIMARY
        try:
            response = await openai.ChatCompletion.acreate(
                model=model,
                messages=[{"role": "user", "content": prompt}],
                temperature=temperature,
                max_tokens=max_tokens
            )
            return response.choices[0].message.content
        except Exception as e:
            raise Exception(f"LLM generation failed: {e}")

llm_client = LLMClient()
EOF

cat > backend/api/__init__.py << 'EOF'
EOF

cat > backend/api/routes/__init__.py << 'EOF'
EOF

cat > backend/api/models/__init__.py << 'EOF'
EOF

cat > backend/api/models/schemas.py << 'EOF'
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from enum import Enum

class TaskStatus(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class AgentRequest(BaseModel):
    agent_name: str = Field(..., description="اسم الوكيل المستهدف")
    client_brief: Dict[str, Any] = Field(..., description="وثيقة CLIENT_BRIEF.json")
    previous_outputs: Optional[Dict[str, Any]] = Field(default={})

class TaskResponse(BaseModel):
    task_id: str
    status: TaskStatus
    message: str
EOF

cat > backend/api/routes/agents.py << 'EOF'
from fastapi import APIRouter, BackgroundTasks, HTTPException
from api.models.schemas import AgentRequest, TaskResponse, TaskStatus
from core.redis_client import redis_client
import uuid
import json

router = APIRouter(prefix="/api/v1/agents", tags=["Agents"])

@router.post("/execute", response_model=TaskResponse)
async def trigger_agent_execution(request: AgentRequest, background_tasks: BackgroundTasks):
    task_id = str(uuid.uuid4())
    initial_state = {"status": TaskStatus.PENDING, "result": None}
    redis_client.setex(f"task:{task_id}", 3600, json.dumps(initial_state))
    background_tasks.add_task(execute_agent_task, task_id, request.agent_name, request.client_brief, request.previous_outputs)
    return TaskResponse(task_id=task_id, status=TaskStatus.PENDING, message="تم قبول المهمة وجاري معالجتها")

@router.get("/status/{task_id}")
async def get_task_status(task_id: str):
    task_data = redis_client.get(f"task:{task_id}")
    if not task_data:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")
    return json.loads(task_data)

async def execute_agent_task(task_id: str, agent_name: str, brief: dict, prev_outputs: dict):
    try:
        redis_client.setex(f"task:{task_id}", 3600, json.dumps({"status": "PROCESSING", "result": None}))
        # TODO: CrewAI execution logic
        result = f"نتيجة من الوكيل {agent_name} للمشروع {brief.get('project_name', 'Unknown')}"
        final_state = {"status": "COMPLETED", "result": result}
        redis_client.setex(f"task:{task_id}", 86400, json.dumps(final_state))
    except Exception as e:
        error_state = {"status": "FAILED", "result": f"Error: {str(e)}"}
        redis_client.setex(f"task:{task_id}", 3600, json.dumps(error_state))
EOF

cat > backend/api/routes/dashboard.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from core.database import get_db
from datetime import datetime

router = APIRouter(prefix="/api/v1/dashboard", tags=["Dashboard"])

@router.get("/stats")
async def get_dashboard_stats(db: AsyncSession = Depends(get_db)):
    try:
        return {
            "active_projects": 0,
            "total_revenue": 0.0,
            "avg_project_value": 0.0,
            "client_satisfaction": 4.8,
            "currency": "USD",
            "last_updated": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/metrics")
async def get_agent_metrics(db: AsyncSession = Depends(get_db)):
    try:
        return {
            "total_tasks": 0,
            "completed_tasks": 0,
            "failed_tasks": 0,
            "avg_completion_time": 0.0,
            "success_rate": 0.0,
            "last_updated": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/tasks/active")
async def get_active_tasks(db: AsyncSession = Depends(get_db)):
    return {"tasks": []}
EOF

cat > backend/services/__init__.py << 'EOF'
EOF

cat > backend/services/crew_executor.py << 'EOF'
"""CrewAI Executor Service"""
from crewai import Crew, Agent, Task
import yaml
import logging

logger = logging.getLogger(__name__)

class CrewExecutor:
    def __init__(self):
        with open("agents/agents.yaml", "r") as f:
            self.agents_config = yaml.safe_load(f)
    
    async def execute(self, agent_name: str, brief: dict):
        try:
            config = self.agents_config.get(agent_name)
            if not config:
                raise ValueError(f"Agent {agent_name} not found")
            
            agent = Agent(
                role=config["role"],
                goal=config["goal"],
                backstory=config["backstory"],
                verbose=False
            )
            
            task = Task(
                description=f"نفذ المهمة بناءً على: {brief}",
                expected_output="تقرير شامل منسق",
                agent=agent
            )
            
            crew = Crew(agents=[agent], tasks=[task], verbose=False)
            result = crew.kickoff()
            return str(result)
        except Exception as e:
            logger.error(f"CrewAI execution error: {e}")
            raise

crew_executor = CrewExecutor()
EOF

cat > backend/services/auto_scaler.py << 'EOF'
"""Auto-Scaling Service"""
import asyncio
import logging
from core.redis_client import redis_client

logger = logging.getLogger(__name__)

class AutoScaler:
    def __init__(self):
        self.scale_up_thresholds = {"queue_depth": 100, "cpu_usage": 80}
        self.scale_down_thresholds = {"queue_depth": 10, "cpu_usage": 30}
        self.running = False
    
    async def monitoring_loop(self):
        logger.info("🚀 Auto-Scaler started")
        self.running = True
        while self.running:
            try:
                queue_depth = redis_client.llen("task_queue") if redis_client.exists("task_queue") else 0
                logger.info(f"📊 Queue depth: {queue_depth}")
                
                if queue_depth >= self.scale_up_thresholds["queue_depth"]:
                    logger.warning("⚠️ High load - SCALE UP recommended")
                elif queue_depth <= self.scale_down_thresholds["queue_depth"]:
                    logger.info("✅ Low load - SCALE DOWN possible")
                
                await asyncio.sleep(300)
            except Exception as e:
                logger.error(f"Auto-scaler error: {e}")
                await asyncio.sleep(60)
    
    def stop(self):
        self.running = False

auto_scaler = AutoScaler()
EOF

cat > backend/services/semantic_cache.py << 'EOF'
"""Semantic Cache Service"""
import logging
import numpy as np
import hashlib
from core.redis_client import redis_client
from core.config import settings

logger = logging.getLogger(__name__)

class SemanticCache:
    def __init__(self):
        try:
            from sentence_transformers import SentenceTransformer
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
            self.enabled = True
        except Exception as e:
            logger.warning(f"SentenceTransformer not available: {e}")
            self.enabled = False
        
        self.threshold = settings.SEMANTIC_CACHE_THRESHOLD
        self.ttl = settings.SEMANTIC_CACHE_TTL
        self.max_size = settings.SEMANTIC_CACHE_MAX_SIZE
    
    def _generate_embedding(self, text: str):
        if not self.enabled:
            return None
        return self.model.encode(text, convert_to_numpy=True)
    
    def _cosine_similarity(self, vec1, vec2):
        return float(np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2)))
    
    def _cache_key(self, prompt: str):
        return hashlib.sha256(prompt.encode()).hexdigest()[:16]
    
    async def get_cached_response(self, prompt: str):
        if not self.enabled:
            return None
        try:
            prompt_embedding = self._generate_embedding(prompt)
            cached_embeddings = redis_client.hgetall("semantic_cache:embeddings")
            
            if not cached_embeddings:
                return None
            
            best_key, best_sim = None, 0.0
            for key, emb_bytes in cached_embeddings.items():
                cached_emb = np.frombuffer(emb_bytes.encode('latin1') if isinstance(emb_bytes, str) else emb_bytes, dtype=np.float32)
                sim = self._cosine_similarity(prompt_embedding, cached_emb)
                if sim > best_sim:
                    best_sim, best_key = sim, key.decode() if isinstance(key, bytes) else key
            
            if best_sim >= self.threshold and best_key:
                response = redis_client.hget("semantic_cache:responses", best_key)
                if response:
                    logger.info(f"✅ Cache HIT (sim: {best_sim:.3f})")
                    return response
            return None
        except Exception as e:
            logger.error(f"Cache retrieval error: {e}")
            return None
    
    async def cache_response(self, prompt: str, response: str, ttl: int = None):
        if not self.enabled:
            return
        try:
            key = self._cache_key(prompt)
            embedding = self._generate_embedding(prompt)
            
            if redis_client.hlen("semantic_cache:embeddings") >= self.max_size:
                self._evict_oldest(100)
            
            redis_client.hset("semantic_cache:embeddings", key, embedding.tobytes().decode('latin1'))
            redis_client.hset("semantic_cache:responses", key, response)
            redis_client.expire(f"semantic_cache:embeddings:{key}", ttl or self.ttl)
            redis_client.expire(f"semantic_cache:responses:{key}", ttl or self.ttl)
            logger.info(f"✅ Cached response for key: {key}")
        except Exception as e:
            logger.error(f"Cache storage error: {e}")
    
    def _evict_oldest(self, count: int):
        try:
            keys = list(redis_client.hkeys("semantic_cache:embeddings"))[:count]
            for key in keys:
                redis_client.hdel("semantic_cache:embeddings", key)
                redis_client.hdel("semantic_cache:responses", key)
        except Exception as e:
            logger.error(f"Cache eviction error: {e}")

semantic_cache = SemanticCache()
EOF

cat > backend/services/qa_automation.py << 'EOF'
"""QA Automation Service"""
import logging
import json
from typing import Dict, Optional
from pydantic import BaseModel, Field
from core.llm_client import llm_client
from core.config import settings

logger = logging.getLogger(__name__)

class QARubric(BaseModel):
    criteria: str
    weight: float = Field(ge=0.0, le=1.0)
    threshold: float = Field(ge=0.0, le=1.0)

class QAEvaluationResult(BaseModel):
    status: str
    overall_score: float
    criteria_scores: Dict[str, float] = {}
    feedback: str = ""
    suggested_fix: Optional[str] = None
    requires_human_review: bool = False

class ProactiveQAAgent:
    def __init__(self):
        self.rubrics = [
            QARubric(criteria="الخلو من الهلوسة", weight=0.35, threshold=0.85),
            QARubric(criteria="الالتزام بالتنسيق", weight=0.20, threshold=0.80),
            QARubric(criteria="وضوح الافتراضات", weight=0.20, threshold=0.80),
            QARubric(criteria="الاكتمال", weight=0.15, threshold=0.85),
            QARubric(criteria="الامتثال الأخلاقي", weight=0.10, threshold=0.95),
        ]
        self.evaluation_model = settings.QA_EVALUATION_MODEL
    
    def _build_prompt(self, agent_name: str, output_text: str) -> str:
        rubrics_text = "\n".join([f"{i+1}. {r.criteria} (Weight: {r.weight})" for i, r in enumerate(self.rubrics)])
        return f"""أنت محكم جودة لوكالة NEXUS AI Agency. قيّم المخرج التالي:

الوكيل: {agent_name}
المخرج:
```
{output_text}
```

المعايير:
{rubrics_text}

أعد JSON فقط:
{{"criteria_scores": {{"معيار1": 0.9}}, "overall_score": 0.89, "status": "PASS", "feedback": "", "suggested_fix": null, "requires_human_review": false}}
"""
    
    async def evaluate_output(self, agent_name: str, output_text: str) -> QAEvaluationResult:
        try:
            prompt = self._build_prompt(agent_name, output_text)
            response = await llm_client.generate(prompt, model=self.evaluation_model, temperature=0.1, max_tokens=1000)
            
            try:
                data = json.loads(response)
            except json.JSONDecodeError:
                return QAEvaluationResult(status="FAIL", overall_score=0.0, feedback="فشل تحليل التقييم", requires_human_review=True)
            
            overall = data.get("overall_score", 0.0)
            status = "PASS" if overall >= 0.85 else "FAIL"
            
            return QAEvaluationResult(
                status=status,
                overall_score=overall,
                criteria_scores=data.get("criteria_scores", {}),
                feedback=data.get("feedback", ""),
                suggested_fix=data.get("suggested_fix"),
                requires_human_review=data.get("requires_human_review", False)
            )
        except Exception as e:
            logger.error(f"QA evaluation error: {e}")
            return QAEvaluationResult(status="FAIL", overall_score=0.0, feedback=f"خطأ: {e}", requires_human_review=True)

qa_agent = ProactiveQAAgent()
EOF

cat > backend/agents/agents.yaml << 'EOF'
# NEXUS AI Agency - 20 Agents Registry v1.0.0
agents:
  - name: feasibility_expert
    role: "validates business viability"
    goal: "Evaluate market, assumptions, and risks"
    backstory: "Senior consultant with startup and GTM experience"
    specialty: ["market","assumptions","risk"]
    priority: 1
  - name: strategy_planner
    role: "creates go-to-market strategy"
    goal: "Produce a 90-day GTM plan"
    backstory: "Growth strategist with B2B experience"
    specialty: ["roadmap","positioning","runway"]
    priority: 2
  - name: content_creator
    role: "drafts messaging and campaigns"
    goal: "Produce key messaging and campaign briefs"
    backstory: "Copywriter and content strategist"
    specialty: ["brand","copy","creative"]
    priority: 3
  - name: ops_specialist
    role: "manages delivery and requirements"
    goal: "Turn strategy into an execution plan"
    backstory: "Operations manager with agency delivery background"
    specialty: ["execution","process","coordination"]
    priority: 4
  - name: qa_validator
    role: "verifies output quality"
    goal: "Validate outputs against rubric and flag issues"
    backstory: "QA lead with experience in ML evaluation"
    specialty: ["review","validation","risk"]
    priority: 5
  - name: legal_advisor
    role: "checks compliance and risk exposure"
    goal: "Identify legal risks and recommended mitigations"
    backstory: "Corporate lawyer with privacy expertise"
    specialty: ["contracts","privacy","terms"]
    priority: 6
  - name: finance_analyst
    role: "interprets cost and projection data"
    goal: "Produce budget and pricing recommendations"
    backstory: "Financial analyst with SaaS experience"
    specialty: ["pricing","budget","profitability"]
    priority: 7
  - name: data_scientist
    role: "analyses metrics and patterns"
    goal: "Provide insights and experiments suggestions"
    backstory: "Data scientist specialized in experiments"
    specialty: ["insights","experimentation","optimization"]
    priority: 8
  - name: project_manager
    role: "coordinates milestones and dependencies"
    goal: "Maintain timeline and deliverable ownership"
    backstory: "PMP-certified project manager"
    specialty: ["scheduling","communication","tracking"]
    priority: 9
  - name: customer_success_rep
    role: "supports onboarding and adoption"
    goal: "Create success plan and onboarding checklist"
    backstory: "Customer success manager"
    specialty: ["retention","enablement","support"]
    priority: 10
  - name: growth_hacker
    role: "seeds channels and acquisition loops"
    goal: "Design rapid experiments for acquisition"
    backstory: "Growth marketer with hands-on funnel experience"
    specialty: ["campaigns","growth"]
    priority: 11
  - name: ux_researcher
    role: "studies usage and friction"
    goal: "Deliver user research and recommendations"
    backstory: "UX researcher with mixed-methods expertise"
    specialty: ["interviews","journeys"]
    priority: 12
  - name: product_designer
    role: "shapes user experience and flows"
    goal: "Provide wireframes and prototypes"
    backstory: "Product designer with Figma expertise"
    specialty: ["UX","UI","prototypes"]
    priority: 13
  - name: sales_expert
    role: "structures offers and pipeline"
    goal: "Create sales playbook and lead scoring"
    backstory: "Enterprise sales leader"
    specialty: ["conversion","pipeline"]
    priority: 14
  - name: technical_architect
    role: "designs system and integrations"
    goal: "Architect scalable infra and APIs"
    backstory: "Systems architect with cloud background"
    specialty: ["infra","APIs","dependencies"]
    priority: 15
  - name: procurement_manager
    role: "coordinates vendors and assets"
    goal: "Source and manage vendor relationships"
    backstory: "Procurement specialist"
    specialty: ["sourcing","acquisition"]
    priority: 16
  - name: community_manager
    role: "manages communities and engagement"
    goal: "Build community playbook and moderation"
    backstory: "Community lead"
    specialty: ["engagement","moderation"]
    priority: 17
  - name: data_analyst
    role: "turns metrics into decisions"
    goal: "Create dashboards and KPIs"
    backstory: "Analyst with BI tooling experience"
    specialty: ["dashboards","reporting","KPIs"]
    priority: 18
  - name: risk_officer
    role: "identifies operational risk"
    goal: "Define controls and incident plans"
    backstory: "Risk & compliance officer"
    specialty: ["governance","resilience","controls"]
    priority: 19
  - name: orchestrator
    role: "delegates tasks and coordinates execution"
    goal: "Route tasks to agents and compile outputs"
    backstory: "Chief of staff for AI orchestration"
    specialty: ["workflow","routing"]
    priority: 20
EOF
