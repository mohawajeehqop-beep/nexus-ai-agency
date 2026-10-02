from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "NEXUS AI Agency"
    app_env: str = "development"
    app_port: int = 8000
    database_url: str = "postgresql://nexus_user:nexus_pass@db:5432/nexus"
    redis_url: str = "redis://redis:6379/0"
    secret_key: str = "change-me-strong-secret"
    openai_api_key: str = "your-openai-key"

    class Config:
        env_file = ".env"


settings = Settings()
