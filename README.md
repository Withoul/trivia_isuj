# 🎓 Academic Pulse — QuizGame ISUTJ

> Plataforma de trivia gamificada para el Instituto Superior Universitario Tecnológico del Japón (ISUTJ). Aplicación móvil multiplataforma construida con Flutter + Backend REST con FastAPI y PostgreSQL.

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)
- [Modelo de Datos](#-modelo-de-datos)
- [API REST — Endpoints](#-api-rest--endpoints)
- [Instalación y Ejecución](#-instalación-y-ejecución)
- [Credenciales de Prueba](#-credenciales-de-prueba)
- [Funcionalidades por Rol](#-funcionalidades-por-rol)
- [Flujos Principales](#-flujos-principales)
- [Sistema de Diseño](#-sistema-de-diseño)
- [Estado del Proyecto](#-estado-del-proyecto)
- [Documentación Adicional](#-documentación-adicional)

---

## 🎯 Descripción General

**Academic Pulse** es una aplicación móvil de trivia académica desarrollada para la comunidad universitaria del ISUTJ. Los estudiantes compiten respondiendo cuestionarios organizados en "bancos de preguntas" con temporizador, acumulan puntos y escalan en un ranking global.

### Características Principales

| Característica | Descripción |
|---|---|
| 🧠 **Trivia con Timer** | Preguntas con temporizador de 12 segundos y feedback visual inmediato |
| 🏆 **Rankings Globales** | Tabla de posiciones con podium visual para el Top 3 |
| 🎖️ **Sistema de Logros** | Insignias y badges desbloqueables por desempeño |
| 🔐 **Autenticación JWT** | Login seguro con tokens y sesiones persistentes |
| 📴 **Modo Demo/Offline** | Bypass inteligente que permite usar la app sin servidor activo |
| 📱 **Multiplataforma** | Compatible con Android e iOS via Flutter |

---

## 📸 Capturas de Pantalla

Los mockups visuales de referencia se encuentran en la carpeta `mokups/`, organizados por pantalla. Cada carpeta contiene un `screen.png` y el `code.html` de diseño de referencia.

| Pantalla | Ubicación |
|---|---|
| Inicio de Sesión | `mokups/iniciar_sesi_n_claro/screen.png` |
| Registro de Usuario | `mokups/registro_de_usuario_claro/screen.png` |
| Dashboard Principal | `mokups/dashboard_principal/screen.png` |
| Quiz en Vivo | `mokups/cuestionario_en_vivo_claro/screen.png` |
| Perfil de Usuario | `mokups/perfil_de_usuario_claro/screen.png` |
| Tabla de Posiciones | `mokups/tabla_de_posiciones_claro/screen.png` |

---

## 🏗️ Arquitectura del Sistema

El proyecto sigue una arquitectura **Cliente-Servidor** de dos capas:

```
┌─────────────────────────┐         HTTP/REST          ┌─────────────────────────┐
│    📱 Flutter App       │◄────── JSON + JWT ────────►│    🖥️ FastAPI Server    │
│                         │                            │                         │
│  • UI / Pantallas       │                            │  • Endpoints REST       │
│  • Riverpod (Estado)    │                            │  • Autenticación JWT    │
│  • SQLite (Local)       │                            │  • ORM SQLAlchemy       │
│  • HTTP Client          │                            │  • Pydantic Schemas     │
└─────────────────────────┘                            └────────────┬────────────┘
                                                                    │
                                                                    ▼
                                                       ┌─────────────────────────┐
                                                       │    🐘 PostgreSQL        │
                                                       │    BD: triviaisuj       │
                                                       │                         │
                                                       │  6 tablas:              │
                                                       │  usuarios, logins,      │
                                                       │  bancos_preguntas,      │
                                                       │  preguntas, respuestas, │
                                                       │  puntajes              │
                                                       └─────────────────────────┘
```

### Principios Arquitectónicos

- **Persistencia dual:** PostgreSQL (servidor) para datos maestros + SQLite (app) para caché y sesión
- **Seguridad por destrucción:** Si el token expira, el archivo SQLite se destruye y recrea completamente
- **Solo puntaje neto:** El servidor solo almacena el puntaje total por banco, no el detalle por pregunta
- **Temporizadores server-side:** Los bancos de preguntas se filtran por rango temporal en el servidor

---

## 📁 Estructura del Proyecto

```
trivia_isuj/
│
├── APP/trivia_app/              # 📱 Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart            # Todas las pantallas (Login, Registro, Home,
│   │   │                        # Quiz, Rankings, Perfil, Navegación)
│   │   ├── api_service.dart     # Cliente HTTP para la API
│   │   ├── auth_provider.dart   # Notifier de autenticación (Riverpod)
│   │   └── database_helper.dart # Singleton de SQLite local
│   └── pubspec.yaml             # Dependencias Flutter
│
├── Server/API/                  # 🖥️ Backend FastAPI
│   ├── main.py                  # Endpoints + seeding de datos
│   ├── auth.py                  # JWT + bcrypt + middlewares de auth
│   ├── models.py                # Modelos ORM (6 tablas)
│   ├── schemas.py               # Esquemas de validación Pydantic
│   ├── database.py              # Conexión a PostgreSQL
│   ├── create_tables.py         # Script: reset completo + seed
│   ├── requirements.txt         # Dependencias Python
│   └── .env                     # Variables de entorno
│
├── Docs/                        # 📚 Documentación
│   ├── main_readme.md           # Documentación técnica principal
│   ├── db_scripts.md            # Scripts SQL de inicialización
│   ├── run_app.md               # Guía de ejecución del frontend
│   └── run_server.md            # Guía de ejecución del backend
│
├── mokups/                      # 🎨 Mockups de diseño
│   ├── DESIGN.md                # Sistema de diseño completo
│   ├── iniciar_sesi_n_claro/    # Login
│   ├── registro_de_usuario_claro/ # Registro
│   ├── dashboard_principal/     # Dashboard
│   ├── cuestionario_en_vivo_claro/ # Quiz activo
│   ├── perfil_de_usuario_claro/ # Perfil
│   └── tabla_de_posiciones_claro/ # Rankings
│
├── AGENT.md                     # 🤖 Documentación técnica para agentes/devs
├── README.md                    # Este archivo
└── .gitignore
```

---

## 🛠️ Tecnologías Utilizadas

### Frontend
| Tecnología | Versión | Propósito |
|---|---|---|
| Flutter | SDK ^3.11.5 | Framework UI multiplataforma |
| Dart | (bundled) | Lenguaje de programación |
| flutter_riverpod | ^3.3.1 | Gestión de estado reactiva |
| http | ^1.6.0 | Cliente HTTP |
| sqflite | ^2.4.2+1 | Base de datos local SQLite |
| shared_preferences | ^2.5.5 | Almacenamiento de preferencias |
| path_provider | ^2.1.5 | Acceso a directorios del sistema |

### Backend
| Tecnología | Versión | Propósito |
|---|---|---|
| FastAPI | 0.109.2 | Framework web Python |
| SQLAlchemy | 2.0.25 | ORM para PostgreSQL |
| PostgreSQL | — | Base de datos principal |
| psycopg2-binary | 2.9.10 | Driver de PostgreSQL |
| PyJWT | 2.8.0 | Tokens JSON Web |
| passlib + bcrypt | 1.7.4 / 4.0.1 | Hash de contraseñas |
| Pydantic | 2.10.6 | Validación de datos |
| Uvicorn | 0.27.0 | Servidor ASGI |

---

## 🗄️ Modelo de Datos

### Base de Datos PostgreSQL (`triviaisuj`)

```mermaid
erDiagram
    USUARIOS ||--o{ LOGINS : "tiene"
    USUARIOS ||--o{ PUNTAJES : "registra"
    BANCOS_PREGUNTAS ||--o{ PREGUNTAS : "contiene"
    BANCOS_PREGUNTAS ||--o{ PUNTAJES : "asocia"
    PREGUNTAS ||--o{ RESPUESTAS : "tiene"

    USUARIOS {
        int id PK
        varchar correo UK
        varchar contrasena
        varchar primer_nombre
        varchar segundo_nombre
        varchar primer_apellido
        varchar segundo_apellido
        varchar institucion
        varchar cedula
        varchar telefono
        enum tipo_perfil
        timestamp creado_en
    }

    LOGINS {
        int id PK
        int usuario_id FK
        varchar token UK
        timestamp creado_en
        timestamp expira_en
    }

    BANCOS_PREGUNTAS {
        int id PK
        varchar titulo
        boolean is_active
        timestamp tiempo_inicio
        timestamp tiempo_fin
        timestamp creado_en
    }

    PREGUNTAS {
        int id PK
        int banco_id FK
        text texto_pregunta
        timestamp creado_en
    }

    RESPUESTAS {
        int id PK
        int pregunta_id FK
        text texto_respuesta
        boolean es_correcta
    }

    PUNTAJES {
        int id PK
        int usuario_id FK
        int banco_id FK
        int puntaje_neto
        timestamp completado_en
    }
```

### Base de Datos SQLite Local (App)

| Tabla | Campos | Propósito |
|---|---|---|
| `session` | `id`, `token`, `usuario_email`, `perfil` | Almacena la sesión JWT activa |
| `active_quiz` | `id`, `bank_id`, `current_score`, `is_finished` | Cache del quiz en progreso |

---

## 🌐 API REST — Endpoints

**Base URL:** `http://localhost:8000`  
**Documentación interactiva:** `http://localhost:8000/docs` (Swagger UI)

### Autenticación (Pública)
```
POST /auth/register    → Registrar nuevo usuario
POST /auth/login       → Iniciar sesión (retorna JWT + usuario)
```

### Bancos de Preguntas (Requiere Bearer Token)
```
GET  /banks/active           → Listar bancos activos (filtro temporal)
GET  /banks/{bank_id}/play   → Obtener preguntas del banco
POST /banks/{bank_id}/score  → Enviar puntaje final
```

### Rankings (Requiere Bearer Token)
```
GET  /ranks/global    → Ranking global de todos los jugadores
```

### Administración (Requiere Bearer Token + Rol Administrador)
```
POST /admin/banks                      → Crear banco de preguntas
POST /admin/banks/{bank_id}/questions  → Agregar preguntas al banco
PUT  /admin/banks/{bank_id}            → Editar banco
```

---

## 🚀 Instalación y Ejecución

### Pre-requisitos
- Python 3.10+
- PostgreSQL instalado y ejecutándose
- Flutter SDK ^3.11 ([instalación](https://flutter.dev/docs/get-started/install))
- Emulador Android/iOS o dispositivo físico

### 1. Backend (Servidor)

```bash
# 1. Navegar al directorio del backend
cd Server/API

# 2. Crear entorno virtual
python -m venv venv

# 3. Activar entorno virtual
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 4. Instalar dependencias
pip install -r requirements.txt

# 5. Configurar .env (ya incluido con valores por defecto)
# DATABASE_URL=postgresql://postgres:admin@localhost:5434/triviaisuj
# SECRET_KEY=triviaisutj_super_secreto_jwt_2025_cambiar_en_produccion

# 6. Crear base de datos PostgreSQL "triviaisuj" manualmente

# 7. Inicializar tablas y datos semilla
python create_tables.py

# 8. Iniciar el servidor
uvicorn main:app --reload
```

### 2. Frontend (App Flutter - Conectada al Servidor)
 
```bash
# 1. Navegar al directorio de la app
cd APP/trivia_app

# 2. Instalar dependencias
flutter pub get

# 3. Configurar la URL del backend (si es necesario)
# Editar lib/api_service.dart:
#   baseUrl = 'http://10.0.2.2:8000'  (emulador Android)
#   baseUrl = 'http://localhost:8000'  (emulador iOS)
#   baseUrl = 'http://<TU_IP>:8000'   (dispositivo físico)

# 4. Ejecutar la aplicación
flutter run
```

### 3. Ejecución Solo Frontend (Modo Demo Offline) 📴

La aplicación cuenta con una **capa de demostración offline integrada (FrontEnd-Only)**. Esta característica es ideal para realizar presentaciones y pruebas de funcionamiento (incluso compilando el APK) **sin necesidad de levantar el backend en Python (FastAPI) ni la base de datos PostgreSQL**.

Los datos mockeados se gestionan en memoria local simulando perfectamente el comportamiento del servidor real.

```bash
# 1. Navegar al directorio de la app
cd APP/trivia_app

# 2. Instalar dependencias
flutter pub get

# 3. Lanzar la app standalone (sin servidor)
flutter run
```

Una vez que la aplicación inicie en tu emulador o dispositivo físico, en la pantalla de inicio de sesión verás la sección **"O INGRESA AL MODO DEMO OFFLINE"** en la parte inferior:

- **🎮 Tarjeta "Demo Estudiante"**:
  - Inicia sesión como el estudiante de prueba **Carlos Mendoza** de la institución *Abdon Calderón*.
  - Permite visualizar estadísticas, jugar mini-quizzes reales de 3 preguntas, acumular rachas dinámicas con animaciones de fuego y ascender posiciones en tiempo real en la **Tabla de Posiciones (Ranking Global)** de forma offline.
- **👑 Tarjeta "Demo Admin"**:
  - Inicia sesión como administrador en un entorno con tema corporativo estructurado.
  - Permite crear nuevos bancos de preguntas en memoria, editar fechas de validez y ver cambios reflejados al instante de forma offline.

---

## 🔑 Credenciales de Prueba

Estas cuentas se crean automáticamente al inicializar la base de datos:

| Rol | Correo | Contraseña |
|---|---|---|
| 👑 Administrador | `admin@admin.com` | `admin` |
| 🎮 Jugador | `usuario@usuario.com` | `user1234` |

---

## 👥 Funcionalidades por Rol

### 🎮 Jugador (Estudiante)

| Funcionalidad | Estado |
|---|---|
| Login / Registro multi-paso | ✅ Funcional |
| Modo Demo (bypass sin servidor) | ✅ Funcional |
| Ver y jugar bancos activos | ✅ Funcional |
| Temporizador por pregunta (12s) | ✅ Funcional |
| Envío automático de puntaje | ✅ Funcional |
| Rankings con podium | ✅ Funcional |
| Perfil con estadísticas | 🟡 Parcial (datos estáticos) |
| Sistema de logros | 🟡 Parcial (solo visual) |
| Tienda de canje | 🔲 Pendiente |
| Sistema de niveles/XP | 🔲 Pendiente |

### 👑 Administrador

| Funcionalidad | Estado |
|---|---|
| Crear bancos de preguntas | ✅ Funcional (vía API) |
| Agregar preguntas y respuestas | ✅ Funcional (vía API) |
| Editar bancos y temporizadores | ✅ Funcional (vía API) |
| Panel administrativo en app | 🔲 Pendiente |
| Gestión de usuarios | 🔲 Pendiente |
| Administrar tienda | 🔲 Pendiente |

---

## 🔄 Flujos Principales

### Flujo de Autenticación
```
Usuario → Login → POST /auth/login → JWT Token
                                      ↓
                              Guardar en SQLite
                                      ↓
                              Acceso a la app
                                      ↓
                         [Token expira] → Destruir SQLite → Volver a Login
```

### Flujo de Juego
```
Ver bancos activos → GET /banks/active
       ↓
Seleccionar banco → GET /banks/{id}/play
       ↓
Responder preguntas (timer 12s c/u)
       ↓                          ↓
  Completa todas           Sale/Interrumpe
       ↓                          ↓
  POST /score              POST /score
  (puntaje final)          (puntaje parcial)
```

---

## 🎨 Sistema de Diseño

El sistema de diseño está documentado en detalle en [`mokups/DESIGN.md`](mokups/DESIGN.md).

### Resumen Visual
- **Paleta:** Púrpura institucional + Dorado de logros + Verde de éxito
- **Tipografía:** Plus Jakarta Sans (display) + Inter (body)
- **Estilo Estudiante:** Glassmorphism, gradientes profundos, micro-animaciones
- **Estilo Admin:** Corporate Modern, high-white-space, tonal layers
- **Grid:** 8px base, 4px para elementos de gamificación
- **Componentes:** Cards glass, botones con gradiente, pills, podium 3D

---

## 📊 Estado del Proyecto

**Progreso general: ~80%**

### Completado ✅
- Arquitectura cliente-servidor completa
- Autenticación JWT con registro en 2 pasos
- Flujo de juego con temporizador y envío de puntaje
- Rankings globales con podium visual
- Bypass de login (modo demo/offline)
- Base de datos PostgreSQL + SQLite con seed automático

### En Progreso 🟡
- Perfil de usuario (datos estáticos actualmente)
- Sistema de logros (solo representación visual)

### Pendiente 🔲
- Panel administrativo en la app
- Sistema funcional de niveles y XP
- Tienda de canje de puntos
- Apartado legal (Términos y Condiciones)
- Activos oficiales de marca institucional
- Tests unitarios e integración

---

## 📚 Documentación Adicional

| Documento | Ubicación | Descripción |
|---|---|---|
| Documentación Técnica Principal | [`Docs/main_readme.md`](Docs/main_readme.md) | Arquitectura, requisitos, APIs, credenciales |
| Scripts de Base de Datos | [`Docs/db_scripts.md`](Docs/db_scripts.md) | SQL completo para inicializar PostgreSQL |
| Guía de Ejecución (App) | [`Docs/run_app.md`](Docs/run_app.md) | Instrucciones para Flutter |
| Guía de Ejecución (Server) | [`Docs/run_server.md`](Docs/run_server.md) | Instrucciones para FastAPI |
| Sistema de Diseño | [`mokups/DESIGN.md`](mokups/DESIGN.md) | Colores, tipografía, componentes, layout |
| Documentación de Agente | [`AGENT.md`](AGENT.md) | Contexto completo para desarrolladores/IA |

---

## 📄 Licencia

Proyecto académico del Instituto Superior Universitario Tecnológico del Japón (ISUTJ).  
Uso educativo e institucional.
