import yaml
from typing import Dict, Any

from models.models import Task, Project
from core.database import SessionLocal


def process_brief(brief: Dict[str, Any]):
    # Simple worker: persist a project + task and simulate agent steps
    db = SessionLocal()
    try:
        proj = Project(name=brief.get("project_name", "Untitled"), description=brief.get("description", ""))
        db.add(proj)
        db.commit()
        db.refresh(proj)

        task = Task(project_id=proj.id, name="orchestration_" + str(proj.id), status="running")
        db.add(task)
        db.commit()
        db.refresh(task)

        # Load agents YAML for demonstration
        with open("agents/agents.yaml", "r", encoding="utf-8") as f:
            agents = yaml.safe_load(f)

        # Simulate processing - here you would call LLMs / agent logic
        for a in agents.get("agents", [])[:5]:
            # pretend each agent appends a log (not persisted here)
            pass

        task.status = "completed"
        db.add(task)
        db.commit()
    finally:
        db.close()

    return {"status": "completed", "project_id": proj.id, "task_id": task.id}
