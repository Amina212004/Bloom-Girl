# 🌸 Bloom Girl — Application Mobile de Bien-être Féminin

<p align="center">
  <img src="assets/images/woman_butterfly_logo.png" width="120" alt="Bloom Girl Logo" />
</p>

<p align="center">
  <strong>Ton espace personnel de suivi du cycle, de bien-être et d'intelligence artificielle</strong><br/>
  Développée avec Flutter · Backend FastAPI · IA Google Gemini · PostgreSQL
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/FastAPI-0.100+-009688?style=for-the-badge&logo=fastapi" />
  <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql" />
  <img src="https://img.shields.io/badge/Google_Gemini-AI-4285F4?style=for-the-badge&logo=google" />
</p>

---

## ✨ Fonctionnalités Principales

| Écran | Description |
|-------|-------------|
| 🤖 **Lily Chat** | Chatbot IA (Lily Rose) alimenté par Google Gemini — santé féminine, révisions, organisation |
| 🗓️ **Mon Temps** | Organisateur de tâches & routines personnalisé, isolé par utilisatrice |
| 💗 **Mon Cycle** | Suivi interactif du cycle menstruel avec graphe d'énergie, phases et prévisions |
| 🌬️ **Respiration** | Exercices de respiration guidés et anti-douleur menstruelle |
| 👤 **Profil** | Espace personnel avec avatar, préférences de cycle et rappels |

### 🔒 Sécurité & Comptes
- Inscription / Connexion par **Email + Mot de passe** (JWT)
- Connexion via **compte Google** (email Gmail déjà enregistré)
- **Isolation totale** : chaque utilisatrice ne voit que ses propres données
- Réinitialisation de mot de passe par **code email**
- Tokens JWT avec expiration 30 jours

---

## 📂 Structure du Projet

```
Bloom-Girl/
├── lib/                          # Application Flutter
│   ├── main.dart                 # Point d'entrée & configuration
│   ├── models/
│   │   ├── user_profile.dart     # Modèle utilisatrice (cycle, avatar, préférences)
│   │   └── chat_message.dart     # Modèle message de chat
│   ├── services/
│   │   ├── user_service.dart     # Gestion de session & profil (SharedPreferences)
│   │   └── api_service.dart      # Appels HTTP vers le backend FastAPI
│   ├── screens/
│   │   ├── auth_screen.dart      # Connexion / Inscription (Email + Google)
│   │   ├── home_navigation_screen.dart  # Navigation principale
│   │   ├── chat_screen.dart      # Chat IA avec Lily Rose 🌸
│   │   ├── cycle_tracker_screen.dart    # Suivi du cycle (graphe, phases, calendrier)
│   │   ├── time_organizer_screen.dart   # Tâches & organisation
│   │   ├── pain_relief_screen.dart      # Exercices de respiration
│   │   └── profile_screen.dart          # Profil & paramètres
│   └── widgets/
│       ├── pink_panda_mascot.dart       # Mascotte Rose & Papillon
│       ├── chat_bubble.dart             # Bulle de message stylisée
│       ├── voice_chat_overlay.dart      # Interface dictée vocale
│       └── settings_drawer.dart        # Panneau latéral paramètres
│
├── backend/                      # API REST Python (FastAPI)
│   ├── main.py                   # Routes API (Auth, Chat, Cycle, Tâches, TTS)
│   ├── models.py                 # Modèles SQLAlchemy (User, ChatMessage, TaskItem, CycleLog)
│   ├── schemas.py                # Schémas Pydantic (validation des requêtes/réponses)
│   ├── database.py               # Connexion PostgreSQL / SQLite
│   ├── requirements.txt          # Dépendances Python
│   └── .env.example             # Template de configuration (copier en .env)
│
├── assets/
│   └── images/                   # Images & logo de l'application
│
└── pubspec.yaml                  # Dépendances Flutter
```

---

## 🚀 Installation & Lancement

### Prérequis
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) ≥ 3.0
- [Python](https://python.org) ≥ 3.10
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (pour PostgreSQL)
- Un émulateur Android ou appareil physique

---

### 1️⃣ Cloner le projet

```bash
git clone https://github.com/Amina212004/Bloom-Girl.git
cd Bloom-Girl
```

---

### 2️⃣ Lancer la base de données PostgreSQL (Docker)

```bash
docker run --name postgres_container \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=bloomrose_db \
  -p 5432:5432 \
  -d postgres:16
```

---

### 3️⃣ Configurer & lancer le Backend FastAPI

```bash
cd backend

# Copier le fichier de configuration
copy .env.example .env
# Puis ouvrir .env et remplir ta clé GEMINI_API_KEY

# Installer les dépendances Python
pip install -r requirements.txt

# Lancer le serveur backend
python -m uvicorn main:app --reload
```

Le backend sera disponible sur `http://localhost:8000`  
Documentation interactive : `http://localhost:8000/docs`

---

### 4️⃣ Lancer l'Application Flutter

```bash
# Depuis la racine du projet
cd ..

# Récupérer les dépendances Flutter
flutter pub get

# Lancer sur l'émulateur Android
flutter run -d emulator-5554

# OU lancer dans le navigateur
flutter run -d chrome
```

---

## 🔑 Configuration de la clé API Google Gemini

1. Rendez-vous sur [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Créez une clé API gratuite
3. Ajoutez-la dans `backend/.env` :
   ```
   GEMINI_API_KEY=votre_cle_ici
   ```

---

## 🗄️ Architecture Backend (API Endpoints)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/auth/register` | Inscription (retourne JWT) |
| `POST` | `/api/auth/login` | Connexion email/password (retourne JWT) |
| `POST` | `/api/auth/google` | Connexion via Google (email déjà inscrit) |
| `POST` | `/api/auth/forgot-password` | Envoi d'un code de réinitialisation |
| `POST` | `/api/auth/reset-password` | Réinitialisation avec le code reçu |
| `PUT` | `/api/user/profile` | Mise à jour du profil utilisatrice |
| `GET` | `/api/chat/history?user_id=X` | Historique des messages de chat |
| `POST` | `/api/chat` | Envoyer un message à Lily (Gemini IA) |
| `GET` | `/api/tasks?user_id=X` | Liste des tâches de l'utilisatrice |
| `POST` | `/api/tasks` | Créer une tâche |
| `PUT` | `/api/tasks/{id}/toggle` | Marquer une tâche comme faite/non faite |
| `DELETE` | `/api/tasks/{id}` | Supprimer une tâche |
| `POST` | `/api/cycle/log` | Enregistrer une entrée de cycle |
| `GET` | `/api/cycle/history?user_id=X` | Historique du cycle |
| `GET` | `/api/cycle/predictions?user_id=X` | Prédictions (ovulation, prochaines règles) |
| `POST` | `/api/speak` | Synthèse vocale (gTTS en français) |

---

## 🛠️ Technologies Utilisées

**Frontend (Flutter)**
- `google_fonts` — Typographie premium (Outfit, Poppins)
- `shared_preferences` — Stockage local sécurisé par utilisatrice
- `http` — Appels API REST vers le backend
- `speech_to_text` — Dictée vocale pour le chat
- `flutter_tts` — Lecture vocale des réponses de Lily
- `flutter_spinkit` — Animations de chargement

**Backend (Python / FastAPI)**
- `FastAPI` — API REST moderne et rapide
- `SQLAlchemy` — ORM pour PostgreSQL
- `pyjwt` — Tokens JWT pour la sécurité
- `pydantic` — Validation des données
- `gtts` — Synthèse vocale française (Lily parle !)
- `requests` — Appels vers l'API Google Gemini

---

## 👩‍💻 Développeuse

Créé avec 💗 par **Amina** — Étudiante en informatique

> *"Bloom Girl est née du besoin d'un espace doux, intelligent et privé pour les femmes."* 🌸

---

## 📄 Licence

Ce projet est sous licence MIT — libre d'utilisation et de modification.
