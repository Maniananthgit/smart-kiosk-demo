# OrderEase — Smart Table-Side Self-Ordering Kiosk & Kitchen Display System

Enterprise-grade table-side ordering kiosk, Kitchen Display System (KDS), and management analytics platform built with modern architecture and strict security standards.

---

## 🛠️ Technology Stack

| Layer | Technologies | Description |
| :--- | :--- | :--- |
| **Frontend** | **Flutter**, **Dart**, **Provider**, **MVVM Architecture**, **GoRouter** | Responsive cross-platform tablet & web UI with reactive state management, declarative routing, and touch optimization. |
| **Backend** | **Python 3.11**, **FastAPI**, **Pydantic v2**, **SQLAlchemy (Async)** | High-throughput asynchronous REST API with auto-generated OpenAPI/Swagger schemas and dependency injection. |
| **Database** | **PostgreSQL 16** | Relational data persistence with UUID primary keys, JSONB internationalization, and ACID transaction safety. |
| **Security** | **JWT Authentication**, **RSA 2048 Encryption**, **Secure Token Storage** | End-to-end RSA encrypted client credential transmission, role-based JWT access tokens, and encrypted storage. |
| **Infrastructure** | **Redis 7**, **Celery**, **Docker**, **Docker Compose**, **Linux** | Redis caching & pub/sub, asynchronous Celery task queues for digital receipts, and containerized deployment. |
| **CI / CD & Git** | **Git**, **GitHub**, **GitHub Actions** | Automated CI pipeline running unit & widget tests on Linux runners (`ubuntu-latest`). |
| **Testing** | **pytest** (Backend), **Flutter testing** (Frontend) | Full asynchronous test coverage across API, models, encryption, state viewmodels, and UI components. |

---

## 📁 Repository Structure

```text
Demo_kiosk/
├── .github/
│   └── workflows/
│       ├── ci.yml               # Automated Pytest & Flutter Test CI Pipeline
│       └── deploy.yml           # Automated Flutter Web deployment to GitHub Pages
├── backend/
│   ├── Dockerfile               # Production Python 3.11 Linux container
│   ├── requirements.txt         # FastAPI, Pydantic, SQLAlchemy, Celery, Redis, etc.
│   ├── main.py                  # FastAPI Application bootstrap & CORS configuration
│   ├── kiosk_backend/
│   │   ├── api/
│   │   │   ├── deps.py          # JWT authentication & permission dependencies
│   │   │   └── v1/
│   │   │       ├── router.py    # API v1 routes aggregation
│   │   │       └── endpoints/   # Auth, Menu, Orders, Waiter, Feedback, Analytics
│   │   ├── core/
│   │   │   ├── config.py        # Pydantic BaseSettings environment loader
│   │   │   ├── database.py      # Async SQLAlchemy sessionmaker & engine
│   │   │   ├── security.py      # JWT token management, bcrypt, & RSA 2048-bit manager
│   │   │   └── redis.py         # Redis async cache client
│   │   ├── models/              # SQLAlchemy ORM Models (Users, Orders, Items, etc.)
│   │   ├── schemas/             # Pydantic v2 validation models
│   │   └── workers/             # Celery application & asynchronous background tasks
│   └── tests/                   # Pytest test suite (12 async test cases)
├── frontend/
│   ├── Dockerfile               # Multi-stage Flutter Web build + Nginx container
│   ├── nginx.conf               # High-performance Nginx reverse-proxy configuration
│   ├── pubspec.yaml             # Flutter dependencies (Provider, GoRouter, Encrypt, etc.)
│   ├── lib/
│   │   ├── main.dart            # MultiProvider & MaterialApp.router setup
│   │   ├── core/
│   │   │   ├── constants/       # App constants & API endpoints
│   │   │   ├── routes/          # GoRouter declarative route definitions
│   │   │   ├── security/        # SecureStorageService & RSACryptoService
│   │   │   └── theme/           # Culinary Amber & Slate theme palette
│   │   ├── models/              # Dart domain entities
│   │   ├── services/            # ApiService client
│   │   ├── viewmodels/          # Provider ViewModels (MVVM Architecture)
│   │   └── views/               # Kiosk, KDS, Management Dashboard, & Login screens
│   └── test/                    # Flutter unit & widget tests
├── database/
│   ├── init.sql                 # PostgreSQL 16 schema definitions
│   └── seed_data.sql            # Initial menu items, categories, and test users
├── docker-compose.yml           # Multi-container orchestration (DB, Cache, Backend, Worker, UI)
├── .env.example                 # Environment configuration template
└── README.md                    # Documentation
```

---

## 🚀 Quick Start (Docker Compose)

### 1. Clone & Configure Environment
```bash
cp .env.example .env
```

### 2. Launch Entire Monorepo with Docker Compose
```bash
docker compose up -d --build
```

### 3. Service Ports & Access Points
- **Flutter Kiosk & Staff App**: `http://localhost:5174`
- **FastAPI Backend & Interactive Swagger Docs**: `http://localhost:8000/docs`
- **PostgreSQL Database**: `localhost:5432` (`smart_kiosk_db`)
- **Redis Cache & Broker**: `localhost:6379`

---

## 💻 Local Development Setup

### Backend (FastAPI + SQLAlchemy + Celery)
```bash
cd backend
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
python main.py
```

### Frontend (Flutter + Dart + Provider)
```bash
cd frontend
flutter pub get
flutter run -d chrome  # or -d windows / -d android
```

---

## 🧪 Running Tests

### Backend Tests (pytest)
```bash
cd backend
python -m pytest tests/ -v
```
*Executes 12 comprehensive async test cases covering RSA public key exchange, JWT authentication, protected endpoints, menu caching, KDS order bumps, waiter calls, and analytics.*

### Frontend Tests (Flutter testing)
```bash
cd frontend
flutter test
```
*Executes unit and widget tests for Cart calculations, Split Bill math, Kiosk ViewModel state, and UI component rendering.*

---

## 🔒 Security Architecture

1. **RSA-2048 Asymmetric Encryption**:
   - The frontend retrieves the server's public key from `/api/v1/auth/rsa-public-key`.
   - Sensitive user credentials and payment authorization data are encrypted client-side using `RSACryptoService` before transmission.
   - The backend `RSACryptoManager` decrypts payloads using the private key in a secure sandbox.
2. **JWT Authentication & RBAC**:
   - Standard and secure login endpoints issue signed JWT tokens containing user role permissions (`ADMIN`, `KITCHEN`, `WAITER`, `STAFF`).
   - Protected routes enforce role-based dependencies via FastAPI's `Depends(get_current_user)`.
3. **Secure Token Storage**:
   - The Flutter client utilizes `SecureStorageService` backed by `flutter_secure_storage` with platform-level keychain/keystore encryption.
