from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

# --- User & Auth Schemas ---
class UserRegister(BaseModel):
    name: Optional[str] = "Utilisatrice"
    email: EmailStr
    password: str
    age: Optional[int] = 19

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class GoogleAuthRequest(BaseModel):
    email: EmailStr
    name: Optional[str] = "Utilisatrice Google"
    avatar: Optional[str] = "🌸"

class UserResponse(BaseModel):
    id: int
    name: Optional[str] = "Utilisatrice"
    email: EmailStr
    auth_provider: Optional[str] = "email"
    age: Optional[int] = 19
    avatar: Optional[str] = "🌸"
    cycle_length: Optional[int] = 28
    period_duration: Optional[int] = 5
    created_at: datetime

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

class UserProfileUpdate(BaseModel):
    user_id: Optional[int] = None
    name: Optional[str] = None
    age: Optional[int] = None
    avatar: Optional[str] = None
    cycle_length: Optional[int] = None
    period_duration: Optional[int] = None

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    reset_code: str
    new_password: str

# --- Chat Schemas ---
class ChatMessageCreate(BaseModel):
    text: str
    user_id: Optional[int] = None

class ChatMessageResponse(BaseModel):
    id: int
    user_id: Optional[int] = None
    sender: str
    text: str
    timestamp: datetime

    class Config:
        from_attributes = True

# --- Task Schemas ---
class TaskCreate(BaseModel):
    text: str
    category: Optional[str] = "Perso"
    completed: Optional[bool] = False
    user_id: Optional[int] = None

class TaskResponse(BaseModel):
    id: int
    user_id: Optional[int] = None
    text: str
    category: str
    completed: bool
    created_at: datetime

    class Config:
        from_attributes = True

# --- Cycle Log & Prediction Schemas ---
class CycleLogCreate(BaseModel):
    user_id: Optional[int] = None
    mood: Optional[str] = None
    symptoms: Optional[str] = None # Ex: "Crampes, Fatigue"
    period_start_date: Optional[datetime] = None
    notes: Optional[str] = None

class CycleLogResponse(BaseModel):
    id: int
    user_id: Optional[int] = None
    mood: Optional[str] = None
    symptoms: Optional[str] = None
    period_start_date: Optional[datetime] = None
    notes: Optional[str] = None
    logged_at: datetime

    class Config:
        from_attributes = True

class CyclePredictionResponse(BaseModel):
    user_id: int
    cycle_length: int
    period_duration: int
    last_period_date: Optional[str] = None
    next_period_date: Optional[str] = None
    ovulation_date: Optional[str] = None
    fertile_window_start: Optional[str] = None
    fertile_window_end: Optional[str] = None
    days_until_next_period: Optional[int] = None
    current_phase: str = "Inconnue"

