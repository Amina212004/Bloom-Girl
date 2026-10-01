from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=True, default="Utilisatrice")
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True) # None si authentification Google
    auth_provider = Column(String(20), default="email") # "email" ou "google"
    age = Column(Integer, default=19)
    avatar = Column(String(20), default="🌸")
    cycle_length = Column(Integer, default=28)
    period_duration = Column(Integer, default=5)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relations
    messages = relationship("ChatMessage", back_populates="user", cascade="all, delete-orphan")
    tasks = relationship("TaskItem", back_populates="user", cascade="all, delete-orphan")
    cycle_logs = relationship("CycleLog", back_populates="user", cascade="all, delete-orphan")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    sender = Column(String(20), nullable=False) # 'user' ou 'bot'
    text = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="messages")


class TaskItem(Base):
    __tablename__ = "tasks_routine"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    text = Column(String(255), nullable=False)
    category = Column(String(50), default="Perso")
    completed = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="tasks")


class CycleLog(Base):
    __tablename__ = "cycle_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    mood = Column(String(50), nullable=True)
    symptoms = Column(String(255), nullable=True) # Ex: "crampes,fatigue"
    period_start_date = Column(DateTime, nullable=True)
    notes = Column(Text, nullable=True)
    logged_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="cycle_logs")
