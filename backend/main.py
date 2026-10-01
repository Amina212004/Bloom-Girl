import os
import io
import base64
import json
import requests
import hashlib
import secrets
import smtplib
import jwt
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, HTTPException, status, BackgroundTasks, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
from gtts import gTTS

import models, schemas
from database import engine, get_db

# Charger les variables d'environnement depuis .env
load_dotenv()

# Auto-création des tables SQL dans la base de données
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Bloom Rose API 🌸",
    description="API REST Backend avec JWT Auth, Suivi de Cycle, IA Google Gemini & PostgreSQL/SQLite",
    version="2.5.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Sécurité & Tokens JWT ---
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "bloomrose_super_secret_jwt_key_2026_butterfly")
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login", auto_error=False)

# Dictionnaire temporaire pour stocker les codes de réinitialisation de mot de passe (Email -> Code)
reset_codes_db = {}

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except Exception:
        return None

# Clé API Google Gemini fournie par l'utilisatrice
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

def call_google_gemini_api(prompt: str) -> str:
    """Appelle l'API Google Gemini officielle avec modèle vérifié et sans astérisques/étoiles."""
    if not GEMINI_API_KEY:
        return _fallback_ai_response(prompt)

    models_to_try = [
        "gemini-3.5-flash-lite",
        "gemini-3.5-flash",
        "gemini-3.6-flash",
        "gemini-3.7-flash"
    ]

    system_prompt = (
        "Tu es Lily Rose 🌸, une compagne virtuelle intelligente, douce et empathique de l'application Bloom Rose. "
        "Tu réponds aux questions (santé féminine, règles, révisions, devoirs, organisation, vie quotidienne) "
        "avec douceur, précision et bienveillance en Français.\n\n"
        "RÈGLES IMPORTANTES D'ÉCRITURE :\n"
        "1. N'utilise JAMAIS d'étoiles ni d'astérisques (* ou **). Aucun formatage en gras markdown avec des étoiles.\n"
        "2. Pour structurer tes réponses, utilise des retours à la ligne clairs, des tirets simples (-) et des émojis doux (🌸, 💕, ✨).\n"
        "3. Termine TOUJOURS toutes tes phrases et explications complètement. Ne t'arrête JAMAIS au milieu d'un mot ou d'une phrase."
    )

    for model_name in models_to_try:
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={GEMINI_API_KEY}"
            contents = [
                {
                    "role": "user",
                    "parts": [{"text": f"{system_prompt}\n\nQuestion de l'utilisatrice : {prompt}"}]
                }
            ]

            response = requests.post(
                url,
                headers={"Content-Type": "application/json"},
                json={
                    "contents": contents,
                    "generationConfig": {
                        "temperature": 0.7,
                        "maxOutputTokens": 2500
                    }
                },
                timeout=14
            )

            if response.status_code == 200:
                data = response.json()
                candidates = data.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        raw_text = parts[0].get("text", "")
                        clean_text = raw_text.replace("**", "").replace("*", "")
                        return clean_text.strip()
        except Exception as e:
            print(f"Erreur API Gemini ({model_name}): {e}")

    return _fallback_ai_response(prompt)

def _fallback_ai_response(prompt: str) -> str:
    p = prompt.lower()
    if any(w in p for w in ["mal", "douleur", "crampe", "règle", "ventre"]):
        return "Oh ma chérie 🥺 Les douleurs de règles sont fatigantes. Pose une bouillotte chaude sur ton bas-ventre 🧺, bois une tisane à la camomille 🫖 et mets-toi en position fœtale. Prends soin de toi ! 🌸"
    elif any(w in p for w in ["organis", "devoir", "cours", "temps", "code", "examen", "informatique"]):
        return "Pour bien réviser tes cours et organiser ton temps sans stress 📚✨ :\n1. Utilise la méthode Pomodoro (25 min d'étude + 5 min de pause).\n2. Planifie tes révisions dans l'onglet 'Mon Temps'. Tu es super douée ! 💪🌸"
    else:
        return f"Je comprends ta question sur '{prompt}' ! 🌸 Je suis là pour t'aider et répondre à toutes tes questions de cours, de santé ou d'organisation ! 💕"

# --- Utilitaires de Sécurité & Mots de passe ---
def hash_password(password: str) -> str:
    salt = secrets.token_hex(16)
    key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode("utf-8"), 100000)
    return f"{salt}${key.hex()}"

def verify_password(stored_password: str, provided_password: str) -> bool:
    try:
        if not stored_password or "$" not in stored_password:
            return False
        salt, key_hex = stored_password.split("$")
        check_key = hashlib.pbkdf2_hmac("sha256", provided_password.encode("utf-8"), salt.encode("utf-8"), 100000)
        return secrets.compare_digest(check_key.hex(), key_hex)
    except Exception:
        return False

# --- Service d'Email ---
SMTP_HOST = os.getenv("SMTP_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", "Bloom Rose <noreply@bloomrose.com>")

def send_welcome_email(to_email: str, user_name: str):
    """Envoie un email de bienvenue poétique à l'utilisatrice."""
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"></head>
    <body style="font-family: 'Segoe UI', Arial; background-color: #FFF0F5; padding: 20px;">
      <div style="max-width: 500px; margin: 0 auto; background: #fff; border-radius: 20px; padding: 25px; border: 1px solid #FFE5EC;">
        <h1 style="color: #7B1F76; text-align: center;">🌸 Bienvenue {user_name} !</h1>
        <p>Bienvenue sur Bloom Rose 💕. Ton espace virtuel sécurisé pour ton suivi de santé, tes révisions et ton organisation au quotidien !</p>
      </div>
    </body>
    </html>
    """
    _send_email_async(to_email, f"Bienvenue sur Bloom Rose 🌸, {user_name} !", html_content)

def send_reset_code_email(to_email: str, reset_code: str):
    """Envoie un code de réinitialisation de mot de passe."""
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"></head>
    <body style="font-family: 'Segoe UI', Arial; background-color: #FFF0F5; padding: 20px;">
      <div style="max-width: 500px; margin: 0 auto; background: #fff; border-radius: 20px; padding: 25px; border: 1px solid #FFE5EC; text-align: center;">
        <h2 style="color: #7B1F76;">Réinitialisation de mot de passe 🔑</h2>
        <p>Voici ton code de confirmation temporaire Bloom Rose :</p>
        <div style="font-size: 32px; font-weight: bold; color: #B83280; letter-spacing: 4px; margin: 20px 0;">{reset_code}</div>
        <p style="color: #888; font-size: 13px;">Si tu n'as pas demandé ce code, ignore simplement cet email.</p>
      </div>
    </body>
    </html>
    """
    _send_email_async(to_email, "Code de réinitialisation Bloom Rose 🌸", html_content)

def _send_email_async(to_email: str, subject: str, html_content: str):
    if SMTP_USER and SMTP_PASSWORD:
        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = SMTP_FROM
            msg["To"] = to_email
            msg.attach(MIMEText(html_content, "html", "utf-8"))

            with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10) as server:
                server.starttls()
                server.login(SMTP_USER, SMTP_PASSWORD)
                server.sendmail(SMTP_USER, to_email, msg.as_string())
            print(f"✅ Email envoyé à {to_email}")
        except Exception as e:
            print(f"⚠️ Erreur SMTP : {e}")
    else:
        print(f"💌 [NOTIFICATION EMAIL] {subject} -> {to_email}")

@app.get("/")
def root():
    return {
        "status": "online",
        "service": "Bloom Rose API 🌸 avec JWT, Suivi de Cycle & PostgreSQL/SQLite",
        "version": "2.5.0",
        "docs": "/docs"
    }

# --- A. Routes d'Authentification & Tokens JWT ---
@app.post("/api/auth/register", response_model=schemas.TokenResponse)
def register_user(req: schemas.UserRegister, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = req.email.lower().strip()
    existing = db.query(models.User).filter(models.User.email == clean_email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cette adresse email est déjà enregistrée. Veuillez vous connecter."
        )
    
    user = models.User(
        name=req.name or "Utilisatrice",
        email=clean_email,
        hashed_password=hash_password(req.password),
        auth_provider="email",
        age=req.age or 19,
        avatar="🌸"
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    background_tasks.add_task(send_welcome_email, user.email, user.name)
    token = create_access_token({"sub": str(user.id), "email": user.email})
    return {"access_token": token, "token_type": "bearer", "user": user}

@app.post("/api/auth/login", response_model=schemas.TokenResponse)
def login_user(req: schemas.UserLogin, db: Session = Depends(get_db)):
    clean_email = req.email.lower().strip()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Adresse email introuvable ou incorrecte."
        )
    
    if user.auth_provider == "google" and not user.hashed_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ce compte a été créé avec Google. Veuillez cliquer sur 'Continuer avec Google'."
        )

    if not verify_password(user.hashed_password, req.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mot de passe incorrect."
        )

    token = create_access_token({"sub": str(user.id), "email": user.email})
    return {"access_token": token, "token_type": "bearer", "user": user}

@app.post("/api/auth/google", response_model=schemas.TokenResponse)
def google_auth(req: schemas.GoogleAuthRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = req.email.lower().strip()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cet utilisateur n'est pas encore inscrit. Veuillez d'abord créer un compte !"
        )
    token = create_access_token({"sub": str(user.id), "email": user.email})
    return {"access_token": token, "token_type": "bearer", "user": user}

# --- E. Mot de Passe Oublié & Réinitialisation ---
@app.post("/api/auth/forgot-password")
def forgot_password(req: schemas.ForgotPasswordRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = req.email.lower().strip()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    if not user:
        raise HTTPException(status_code=400, detail="Aucun compte associé à cette adresse email.")
    
    reset_code = f"{secrets.randbelow(899999) + 100000}"
    reset_codes_db[clean_email] = reset_code
    background_tasks.add_task(send_reset_code_email, clean_email, reset_code)
    return {"message": "Le code de réinitialisation a été envoyé par email.", "email": clean_email}

@app.post("/api/auth/reset-password")
def reset_password(req: schemas.ResetPasswordRequest, db: Session = Depends(get_db)):
    clean_email = req.email.lower().strip()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    if not user:
        raise HTTPException(status_code=400, detail="Utilisateur introuvable.")
    
    stored_code = reset_codes_db.get(clean_email)
    if not stored_code or stored_code != req.reset_code.strip():
        raise HTTPException(status_code=400, detail="Code de réinitialisation invalide ou expiré.")
    
    user.hashed_password = hash_password(req.new_password)
    db.commit()
    del reset_codes_db[clean_email]
    return {"message": "Votre mot de passe a été réinitialisé avec succès !"}

# --- D. Modification du Profil Utilisateur ---
@app.put("/api/user/profile", response_model=schemas.UserResponse)
def update_user_profile(req: schemas.UserProfileUpdate, db: Session = Depends(get_db)):
    if not req.user_id:
        raise HTTPException(status_code=400, detail="ID d'utilisateur requis.")
    
    user = db.query(models.User).filter(models.User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=444, detail="Utilisateur introuvable.")
    
    if req.name is not None: user.name = req.name
    if req.age is not None: user.age = req.age
    if req.avatar is not None: user.avatar = req.avatar
    if req.cycle_length is not None: user.cycle_length = req.cycle_length
    if req.period_duration is not None: user.period_duration = req.period_duration
    
    db.commit()
    db.refresh(user)
    return user

# --- B. Discussion IA & Filtrage par user_id ---
@app.get("/api/chat/history", response_model=List[schemas.ChatMessageResponse])
def get_chat_history(user_id: Optional[int] = Query(None), db: Session = Depends(get_db)):
    query = db.query(models.ChatMessage)
    if user_id:
        query = query.filter(models.ChatMessage.user_id == user_id)
    return query.order_by(models.ChatMessage.timestamp.asc()).all()

@app.post("/api/chat", response_model=schemas.ChatMessageResponse)
def send_chat_message(msg: schemas.ChatMessageCreate, db: Session = Depends(get_db)):
    user_msg = models.ChatMessage(sender="user", text=msg.text, user_id=msg.user_id)
    db.add(user_msg)
    db.commit()

    reply_text = call_google_gemini_api(msg.text)

    bot_msg = models.ChatMessage(sender="bot", text=reply_text, user_id=msg.user_id)
    db.add(bot_msg)
    db.commit()
    db.refresh(bot_msg)

    return bot_msg

# --- B. Tâches & Routines avec Filtrage user_id ---
@app.get("/api/tasks", response_model=List[schemas.TaskResponse])
def get_tasks(user_id: Optional[int] = Query(None), db: Session = Depends(get_db)):
    query = db.query(models.TaskItem)
    if user_id:
        query = query.filter(models.TaskItem.user_id == user_id)
    return query.order_by(models.TaskItem.id.asc()).all()

@app.post("/api/tasks", response_model=schemas.TaskResponse)
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    new_task = models.TaskItem(
        user_id=task.user_id,
        text=task.text,
        category=task.category or "Perso",
        completed=task.completed or False
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

@app.put("/api/tasks/{task_id}/toggle", response_model=schemas.TaskResponse)
def toggle_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.TaskItem).filter(models.TaskItem.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Tâche introuvable")
    db_task.completed = not db_task.completed
    db.commit()
    db.refresh(db_task)
    return db_task

@app.delete("/api/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.TaskItem).filter(models.TaskItem.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Tâche introuvable")
    db.delete(db_task)
    db.commit()
    return {"message": "Tâche supprimée avec succès"}

# --- C. Suivi du Cycle Féminin (`CycleLog`) & Prédictions ---
@app.post("/api/cycle/log", response_model=schemas.CycleLogResponse)
def create_cycle_log(log: schemas.CycleLogCreate, db: Session = Depends(get_db)):
    if not log.user_id:
        raise HTTPException(status_code=400, detail="user_id est obligatoire pour enregistrer le cycle.")
    
    new_log = models.CycleLog(
        user_id=log.user_id,
        mood=log.mood,
        symptoms=log.symptoms,
        period_start_date=log.period_start_date or datetime.utcnow(),
        notes=log.notes
    )
    db.add(new_log)
    db.commit()
    db.refresh(new_log)
    return new_log

@app.get("/api/cycle/history", response_model=List[schemas.CycleLogResponse])
def get_cycle_history(user_id: int = Query(...), db: Session = Depends(get_db)):
    return db.query(models.CycleLog).filter(models.CycleLog.user_id == user_id).order_by(models.CycleLog.logged_at.desc()).all()

@app.get("/api/cycle/predictions", response_model=schemas.CyclePredictionResponse)
def get_cycle_predictions(user_id: int = Query(...), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
    
    cycle_length = user.cycle_length or 28
    period_duration = user.period_duration or 5
    
    latest_log = db.query(models.CycleLog).filter(
        models.CycleLog.user_id == user_id,
        models.CycleLog.period_start_date.isnot(None)
    ).order_by(models.CycleLog.period_start_date.desc()).first()

    if not latest_log or not latest_log.period_start_date:
        return {
            "user_id": user_id,
            "cycle_length": cycle_length,
            "period_duration": period_duration,
            "last_period_date": None,
            "next_period_date": None,
            "ovulation_date": None,
            "fertile_window_start": None,
            "fertile_window_end": None,
            "days_until_next_period": None,
            "current_phase": "En attente du 1er enregistrement de cycle 🌸"
        }

    last_p = latest_log.period_start_date
    next_p = last_p + timedelta(days=cycle_length)
    ovulation = next_p - timedelta(days=14)
    fertile_start = ovulation - timedelta(days=5)
    fertile_end = ovulation + timedelta(days=1)
    
    today = datetime.utcnow()
    days_until = (next_p.date() - today.date()).days
    days_since_start = (today.date() - last_p.date()).days

    if days_since_start < period_duration:
        phase = "Menstruelle 🩸"
    elif days_since_start < (cycle_length - 16):
        phase = "Folliculaire 🌱"
    elif days_since_start <= (cycle_length - 12):
        phase = "Ovulatoire 🥚✨"
    else:
        phase = "Lutéale 🌙"

    return {
        "user_id": user_id,
        "cycle_length": cycle_length,
        "period_duration": period_duration,
        "last_period_date": last_p.strftime("%Y-%m-%d"),
        "next_period_date": next_p.strftime("%Y-%m-%d"),
        "ovulation_date": ovulation.strftime("%Y-%m-%d"),
        "fertile_window_start": fertile_start.strftime("%Y-%m-%d"),
        "fertile_window_end": fertile_end.strftime("%Y-%m-%d"),
        "days_until_next_period": days_until,
        "current_phase": phase
    }

# --- Synthèse Vocale Féminine (Text-to-Speech) ---
@app.post("/api/speak")
def generate_speech(payload: dict):
    """Génère la voix de fille de Lily (Français Féminin doux) via gTTS."""
    text = payload.get("text", "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="Texte requis pour la synthèse vocale")

    clean_text = text.replace("**", "").replace("*", "")
    for emoji_char in ["🌸", "💕", "✨", "🩹", "📚", "😴", "💖", "🦋", "🤖"]:
        clean_text = clean_text.replace(emoji_char, "")
    clean_text = clean_text.strip()

    if not clean_text:
        clean_text = "Bonjour !"

    try:
        fp = io.BytesIO()
        tts = gTTS(text=clean_text, lang='fr', tld='fr', slow=False)
        tts.write_to_fp(fp)
        fp.seek(0)

        audio_b64 = base64.b64encode(fp.read()).decode("utf-8")
        return {"status": "ok", "audio_base64": audio_b64, "format": "mp3"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur de synthèse vocale: {str(e)}")
