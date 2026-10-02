from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Depends
from core.config import settings
from api.routes import health
from api.routes import auth

app = FastAPI(title="NEXUS AI Agency API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# include routers
app.include_router(health.router)
app.include_router(auth.router)


@app.get("/")
def root():
    return {"message": "Welcome to NEXUS AI Agency"}
