from sqlalchemy import text
from core.database import engine

from models.models import User, Project, Task


def create_all():
    print("Creating database tables...")
    User.metadata.create_all(bind=engine)
    Project.metadata.create_all(bind=engine)
    Task.metadata.create_all(bind=engine)


if __name__ == "__main__":
    create_all()
