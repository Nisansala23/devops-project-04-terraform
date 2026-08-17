# backend/database.py

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Get database URL from environment variable
# Falls back to localhost for local development
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://urluser:urlpass@localhost:5432/urlshortener"
)

# Create database engine
engine = create_engine(DATABASE_URL)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for all models
Base = declarative_base()


# Dependency - used in every route that needs DB


def get_db():
    db = SessionLocal()
    try:
        yield db        # Give DB session to the route
    finally:
        db.close()      # Always close when done