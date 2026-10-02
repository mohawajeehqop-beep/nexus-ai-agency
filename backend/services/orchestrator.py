import json
import time
from typing import Dict, Any

import redis
from rq import Queue

from core.config import settings
from pathlib import Path

AGENTS_FILE = Path(__file__).resolve().parents[1] / "agents" / "agents.yaml"


def enqueue_orchestration(brief: Dict[str, Any]) -> Dict[str, Any]:
    r = redis.Redis.from_url(settings.redis_url)
    q = Queue("default", connection=r)
    job = q.enqueue("services.orchestrator_worker.process_brief", brief)
    return {"status": "queued", "job_id": job.get_id()}
