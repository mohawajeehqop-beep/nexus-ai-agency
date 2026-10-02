from __future__ import annotations

from typing import Dict, Any


class OrchestratorService:
    def __init__(self) -> None:
        self.agents = []

    def load_agents(self, items: list[dict[str, Any]]) -> None:
        self.agents = items

    def run(self, brief: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "status": "queued",
            "project_name": brief.get("project_name", "Untitled"),
            "agents": [agent.get("name") for agent in self.agents],
            "summary": "Workflow orchestration initialized successfully.",
        }
