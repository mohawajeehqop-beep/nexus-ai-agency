from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Any, Dict

app = FastAPI(title="NEXUS AI Agency API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AgentRequest(BaseModel):
    agent_name: str
    client_brief: Dict[str, Any]


@app.get("/")
def root() -> Dict[str, str]:
    return {"message": "Welcome to NEXUS AI Agency"}


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "service": "nexus-ai-agency"}


@app.post("/api/v1/agents/execute")
def execute_agent(payload: AgentRequest) -> Dict[str, Any]:
    return {
        "status": "success",
        "agent_name": payload.agent_name,
        "message": "Agent executed successfully.",
        "result": {
            "project_name": payload.client_brief.get("project_name", "Untitled"),
            "summary": "The agent received the project brief and is ready for orchestration.",
            "next_step": "Build execution plan and return structured output.",
        },
    }
