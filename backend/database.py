import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# URL de connexion PostgreSQL (Docker / local)
# Format: postgresql://utilisateur:motdepasse@hote:port/nom_base
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/bloomrose_db"
)

try:
    engine = create_engine(DATABASE_URL, pool_pre_ping=True)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    # Test léger de connexion
    with engine.connect() as conn:
        pass
except Exception:
    # Fallback automatique vers SQLite local si la base PostgreSQL Docker n'est pas encore créée
    SQLITE_URL = "sqlite:///./bloomrose.db"
    engine = create_engine(SQLITE_URL, connect_args={"check_same_thread": False})
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
