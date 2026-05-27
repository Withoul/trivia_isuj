# AGENT.md — Documentación de Agente para Trivia ISUTJ (Academic Pulse)

> **Propósito de este archivo:** Servir como referencia maestra para cualquier agente de IA, desarrollador o colaborador que necesite comprender el contexto completo del proyecto, su arquitectura, convenciones de código y estado actual.

---

## 1. Visión General del Proyecto

**Nombre del Producto:** Academic Pulse / QuizGame ISUTJ  
**Tipo:** Aplicación móvil multiplataforma (Android & iOS) con backend REST  
**Institución:** Instituto Superior Universitario Tecnológico del Japón (ISUTJ)  
**Propósito:** Plataforma de trivia gamificada orientada a estudiantes universitarios, donde los participantes responden cuestionarios (bancos de preguntas) con temporizador, acumulan puntos, compiten en rankings globales y desbloquean logros.

### Roles del Sistema

| Rol | Descripción |
|---|---|
| **Jugador (Estudiante)** | Responde trivias, acumula puntos, consulta rankings, desbloquea logros y canjea recompensas en la tienda |
| **Administrador** | Crea y gestiona bancos de preguntas, controla temporizadores, administra usuarios y la tienda de canje |

---

## 2. Stack Tecnológico

### Frontend (Aplicación Móvil)
- **Framework:** Flutter (SDK ^3.11.5)
- **Lenguaje:** Dart
- **Gestión de Estado:** `flutter_riverpod` ^3.3.1 (patrón Notifier)
- **HTTP Client:** `http` ^1.6.0
- **Base de Datos Local:** `sqflite` ^2.4.2+1
- **Almacenamiento de Preferencias:** `shared_preferences` ^2.5.5
- **Path Provider:** `path_provider` ^2.1.5

### Backend (API REST)
- **Framework:** FastAPI 0.109.2 (Python)
- **ORM:** SQLAlchemy 2.0.25
- **Base de Datos:** PostgreSQL (driver: `psycopg2-binary` 2.9.10)
- **Autenticación:** JWT via `PyJWT` 2.8.0 + `passlib[bcrypt]` 1.7.4
- **Validación:** Pydantic 2.10.6
- **Servidor ASGI:** Uvicorn 0.27.0

### Sistema de Diseño
- **Fuentes:** Plus Jakarta Sans (display, títulos, scores) + Inter (body, datos)
- **Paleta:** Púrpura institucional (#461F70 / #30015A), Dorado de logros (#FFC70A / #FFD54F), Verde de éxito (#4EDEA3)
- **Estilo Visual:** Híbrido Corporate Modern (admin) + Vibrant Gamification (estudiante)
- **Especificación:** Documentado en `mokups/DESIGN.md`

---

## 3. Arquitectura del Sistema

```
┌────────────────────────────────────────────────────────────────┐
│                     CLIENTE (Flutter App)                       │
│                                                                │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────────┐   │
│  │  main.dart│  │ api_service  │  │   database_helper      │   │
│  │ (2124 lín)│  │   .dart      │  │      .dart             │   │
│  │           │  │              │  │                        │   │
│  │ ┌───────┐ │  │ • login()    │  │ • SQLite local         │   │
│  │ │Screens│ │──│ • register() │  │ • session (token)      │   │
│  │ │       │ │  │ • getActive  │  │ • active_quiz (cache)  │   │
│  │ │ Login │ │  │   Banks()   │  │ • clearAllData()       │   │
│  │ │ SignUp│ │  │ • getQuest.()│  │   (destrucción si      │   │
│  │ │ Home  │ │  │ • submitSc() │  │    token inválido)     │   │
│  │ │ Quiz  │ │  │ • getRanks() │  └────────────────────────┘   │
│  │ │ Ranks │ │  └──────────────┘                               │
│  │ │Profile│ │  ┌──────────────┐                               │
│  │ └───────┘ │  │ auth_provider│                               │
│  │           │  │    .dart     │                               │
│  │           │──│ Riverpod     │                               │
│  │           │  │ Notifier     │                               │
│  └──────────┘  └──────────────┘                               │
└────────────────────────┬───────────────────────────────────────┘
                         │ HTTP (REST/JSON)
                         │ Bearer Token (JWT)
                         ▼
┌────────────────────────────────────────────────────────────────┐
│                     SERVIDOR (FastAPI)                          │
│                                                                │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌─────────────┐  │
│  │ main.py  │  │ auth.py  │  │ models.py │  │ schemas.py  │  │
│  │          │  │          │  │           │  │             │  │
│  │ Endpoints│  │ JWT      │  │ SQLAlchemy│  │ Pydantic    │  │
│  │ + Seed   │  │ bcrypt   │  │ ORM       │  │ Validación  │  │
│  │ Data     │  │ OAuth2   │  │ Modelos   │  │ Serializ.   │  │
│  └──────────┘  └──────────┘  └───────────┘  └─────────────┘  │
│                                                                │
│  ┌──────────────┐  ┌──────────────────┐                       │
│  │ database.py  │  │ create_tables.py │                       │
│  │ Conexión PG  │  │ Reset + Seed     │                       │
│  └──────────────┘  └──────────────────┘                       │
└────────────────────────┬───────────────────────────────────────┘
                         │ SQLAlchemy ORM
                         ▼
              ┌────────────────────┐
              │    PostgreSQL      │
              │  DB: triviaisuj    │
              │                    │
              │  • usuarios        │
              │  • logins          │
              │  • bancos_preguntas│
              │  • preguntas       │
              │  • respuestas      │
              │  • puntajes        │
              └────────────────────┘
```

---

## 4. Estructura de Archivos del Proyecto

```
trivia_isuj/
├── .gitignore
├── README.md                          # README principal del repo
├── AGENT.md                           # Este archivo
│
├── APP/                               # Cliente móvil
│   └── trivia_app/                    # Proyecto Flutter
│       ├── pubspec.yaml               # Dependencias Dart/Flutter
│       ├── lib/
│       │   ├── main.dart              # ⭐ Archivo principal (2124 líneas)
│       │   │                          #    Contiene TODAS las pantallas:
│       │   │                          #    LoginScreen, SignUpScreen,
│       │   │                          #    MainNavigationScreen, QuizzesTab,
│       │   │                          #    RankingsTab, ProfileTab, QuizScreen
│       │   ├── api_service.dart       # Cliente HTTP para la API FastAPI
│       │   ├── auth_provider.dart     # Estado de autenticación (Riverpod)
│       │   └── database_helper.dart   # Singleton SQLite local
│       ├── android/                   # Configuración nativa Android
│       ├── ios/                       # Configuración nativa iOS
│       ├── web/                       # Soporte web (secundario)
│       ├── windows/                   # Soporte desktop Windows
│       ├── linux/                     # Soporte desktop Linux
│       └── macos/                     # Soporte desktop macOS
│
├── Server/                            # Backend
│   └── API/
│       ├── .env                       # Variables de entorno (DB URL, JWT secret)
│       ├── main.py                    # Endpoints FastAPI + data seeding
│       ├── auth.py                    # Autenticación JWT + bcrypt + guards
│       ├── models.py                  # Modelos SQLAlchemy (6 tablas)
│       ├── schemas.py                 # Esquemas Pydantic para validación
│       ├── database.py                # Conexión a PostgreSQL (engine + session)
│       ├── create_tables.py           # Script autónomo: drop + create + seed
│       └── requirements.txt           # Dependencias Python
│
├── Docs/                              # Documentación del proyecto
│   ├── main_readme.md                 # Documentación principal (arquitectura, APIs, flujos)
│   ├── db_scripts.md                  # Script SQL completo para PostgreSQL
│   ├── run_app.md                     # Instrucciones para ejecutar la app Flutter
│   └── run_server.md                  # Instrucciones para ejecutar el backend
│
└── mokups/                            # Mockups de diseño (HTML + PNG)
    ├── DESIGN.md                      # ⭐ Sistema de diseño completo (colores,
    │                                  #    tipografía, componentes, elevación)
    ├── iniciar_sesi_n_claro/          # Mockup: Pantalla de Login
    │   ├── code.html
    │   └── screen.png
    ├── registro_de_usuario_claro/     # Mockup: Pantalla de Registro
    │   ├── code.html
    │   └── screen.png
    ├── dashboard_principal/           # Mockup: Dashboard principal (home)
    │   ├── code.html
    │   └── screen.png
    ├── cuestionario_en_vivo_claro/    # Mockup: Quiz activo en vivo
    │   ├── code.html
    │   └── screen.png
    ├── perfil_de_usuario_claro/       # Mockup: Perfil del usuario
    │   ├── code.html
    │   └── screen.png
    └── tabla_de_posiciones_claro/     # Mockup: Tabla de posiciones / Rankings
        ├── code.html
        └── screen.png
```

---

## 5. Modelo de Datos

### PostgreSQL (Servidor) — 6 Tablas

| Tabla | Propósito | Relaciones |
|---|---|---|
| `usuarios` | Datos del usuario, credenciales hasheadas, rol (ENUM: ADMINISTRADOR/JUGADOR), cédula, teléfono | → `logins`, → `puntajes` |
| `logins` | Sesiones activas con token JWT y fecha de expiración | ← `usuarios` (FK cascade) |
| `bancos_preguntas` | Agrupaciones de preguntas con título, flag `is_active`, y temporizadores (`tiempo_inicio`, `tiempo_fin`) | → `preguntas`, → `puntajes` |
| `preguntas` | Texto de cada pregunta, vinculada a un banco | ← `bancos_preguntas` (FK cascade), → `respuestas` |
| `respuestas` | Texto de cada opción + `es_correcta` (boolean) | ← `preguntas` (FK cascade) |
| `puntajes` | Puntaje neto de un usuario en un banco específico + timestamp | ← `usuarios`, ← `bancos_preguntas` |

### SQLite (App Local) — 2 Tablas

| Tabla | Propósito |
|---|---|
| `session` | Token JWT activo, email del usuario, perfil (rol). Solo 1 fila activa |
| `active_quiz` | Cache del quiz en curso: `bank_id`, `current_score`, `is_finished` |

**Política de seguridad:** Si el token JWT expira o se invalida, la app destruye completamente el archivo SQLite (`trivia_local.db`) y lo recrea limpio. No hay migración de datos entre sesiones.

---

## 6. Endpoints de la API

### Autenticación
| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `POST` | `/auth/register` | Registro de nuevo usuario | ❌ |
| `POST` | `/auth/login` | Login, retorna JWT + datos de usuario | ❌ |

### Bancos de Preguntas (Jugador)
| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `GET` | `/banks/active` | Lista bancos activos (filtrados por temporizador) | ✅ Bearer |
| `GET` | `/banks/{bank_id}/play` | Obtiene preguntas + respuestas de un banco | ✅ Bearer |
| `POST` | `/banks/{bank_id}/score` | Envía puntaje neto al terminar o interrumpir | ✅ Bearer |

### Rankings
| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `GET` | `/ranks/global` | Ranking global (puntajes acumulados + mocks de demo) | ✅ Bearer |

### Administración
| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `POST` | `/admin/banks` | Crear nuevo banco de preguntas | ✅ Admin |
| `POST` | `/admin/banks/{bank_id}/questions` | Agregar preguntas con respuestas a un banco | ✅ Admin |
| `PUT` | `/admin/banks/{bank_id}` | Editar banco (título, estado, temporizadores) | ✅ Admin |

---

## 7. Pantallas de la Aplicación Flutter

Todas las pantallas están definidas en `lib/main.dart` como widgets independientes:

### 7.1 `LoginScreen` (líneas 38–357)
- Formulario con correo y contraseña pre-rellenados para desarrollo
- Checkbox "Mantener sesión activa"
- **Botón Bypass:** "Saltar Login / Modo Demo" — intenta login real; si falla, crea sesión mock local
- Logo institucional "Universitario Japón" recreado con widgets

### 7.2 `SignUpScreen` (líneas 360–797)
- Registro en **2 pasos** con indicador visual de progreso
- **Paso 1:** Nombre completo, cédula (10 dígitos), institución, teléfono (10 dígitos)
- **Paso 2:** Correo electrónico, contraseña (mín. 6 chars), confirmación de contraseña
- Validaciones frontend: formato email, longitud cédula/teléfono, coincidencia de contraseñas

### 7.3 `MainNavigationScreen` (líneas 800–915)
- Shell con `AppBar` (logo + pill de gemas) y `BottomNavigationBar` personalizada
- 3 pestañas: **Quizzes**, **Rankings**, **Profile**
- Barra de navegación animada con `AnimatedContainer`

### 7.4 `QuizzesTab` (líneas 917–1106)
- Lista de bancos de preguntas activos obtenidos del servidor
- Cards con gradiente púrpura, badge "ACTIVO", botón "Jugar Ahora" dorado
- Estado vacío con ícono e indicación de recarga

### 7.5 `RankingsTab` (líneas 1108–1466)
- Podium gráfico con los Top 3 (pilares de altura variable, corona para 1er lugar)
- Lista scrollable del 4to puesto en adelante
- Resaltado especial para el usuario actual ("Tú")
- Formateo de puntos con separador de miles

### 7.6 `ProfileTab` (líneas 1468–1748)
- Avatar con borde púrpura + badge de nivel ("⭐ NIVEL 12 - MAESTRO")
- 2 cards de estadísticas: Quizzes Completados + Racha Máxima
- Card de Puntos Totales
- Sección de Logros Recientes (badges activos + bloqueados)
- Botones: Editar Perfil (placeholder) + Cerrar Sesión

### 7.7 `QuizScreen` (líneas 1750–2124)
- Pantalla de juego con temporizador circular regresivo (12 segundos por pregunta)
- Indicador de racha ("Racha x5")
- Pregunta + 4 opciones (A, B, C, D) con feedback visual al seleccionar
- Barra de progreso con gradiente Dorado→Verde
- **`PopScope`**: Si el usuario intenta salir, se envía automáticamente el puntaje acumulado
- Auto-timeout: si se agota el tiempo, marca como incorrecta

---

## 8. Flujos Críticos de Negocio

### 8.1 Flujo de Autenticación
1. Usuario ingresa credenciales → `POST /auth/login`
2. Servidor valida contra hash bcrypt → genera JWT con expiración 7 días
3. Token se persiste en tabla `logins` (PostgreSQL) y en `session` (SQLite local)
4. Cada request subsecuente envía `Authorization: Bearer <token>`
5. Si token expira → servidor retorna 401 → app destruye SQLite local

### 8.2 Flujo de Juego
1. Jugador ve bancos activos → `GET /banks/active` (filtro de temporizador server-side)
2. Selecciona un banco → `GET /banks/{id}/play` (descarga preguntas + respuestas)
3. Responde preguntas con timer de 12 seg c/u → +10 pts por correcta
4. Al finalizar (o interrumpir) → `POST /banks/{id}/score` con puntaje neto
5. Solo se guarda el **puntaje neto total**, no el detalle por pregunta

### 8.3 Bypass de Login (Modo Demo)
1. Intenta `login('usuario@usuario.com', 'user1234')` contra el backend
2. Si el servidor está activo → ingresa normalmente (modo Online)
3. Si el servidor está inactivo → crea token mock en SQLite local → ingresa en modo Invitado/Offline

---

## 9. Datos Semilla (Seed Data)

El sistema incluye siembra automática al iniciar `main.py` o ejecutar `create_tables.py`:

| Cuenta | Correo | Contraseña | Rol |
|---|---|---|---|
| Administrador | `admin@admin.com` | `admin` | ADMINISTRADOR |
| Jugador de prueba | `usuario@usuario.com` | `user1234` | JUGADOR |

Además, `create_tables.py` siembra un banco de preguntas de ejemplo ("Fundamentos de Desarrollo Móvil e ISUTJ") con 2 preguntas y 4 respuestas cada una.

El endpoint `/ranks/global` incluye **usuarios ficticios** (mock) para poblar el podium visual del diseño: Andrea R. (15,850 pts), Carlos M. (14,200 pts), Luis G. (13,900 pts), etc.

---

## 10. Sistema de Diseño (mokups/DESIGN.md)

### Identidad de Marca
- **Estilo:** Híbrido entre Corporate Modern (admin) y Vibrant Gamification (estudiante)
- **Mood:** Energético, tecnológico, recompensante
- **Enfoque dual:** "Layered Reality" — glassmorphism para estudiantes, tonal layers para admin

### Paleta de Colores
- **Primary (Púrpura institucional):** `#30015A` / `#461F70` — headers, gradientes
- **Secondary (Dorado de logros):** `#FFC70A` / `#FFD54F` — rewards, progress, 1er puesto
- **Tertiary (Verde de éxito):** `#4EDEA3` / `#003D28` — respuestas correctas, feedback positivo
- **Background Gradient (Participante):** `#461F70` → `#1A0B2E`
- **Neutrales:** Cool grays para panel administrativo

### Tipografía
- **Plus Jakarta Sans:** Display, headlines, botones, scores — feel moderno y geométrico
- **Inter:** Body copy, tablas administrativas — alta legibilidad a tamaños pequeños
- **Scores/Timers:** `tabular-nums` para evitar layout shift

### Componentes Clave del Diseño
- **Quiz Cards:** Mín. 64px altura, bordes glass, estados: default/selected/correct/incorrect
- **Botones Participante:** Gradiente Gold-to-Orange, animación `scale(0.98)` al presionar
- **Progress Bars:** 12px, track semi-transparente, fill con gradiente Gold-to-Green
- **Podium:** Top 3 con efecto 3D, medalla de oro con animación de "shine"
- **NavBar:** Frosted glass con `backdrop-filter: blur(12px)`

---

## 11. Convenciones de Código

### Flutter/Dart
- Todo el código UI está en un solo archivo `main.dart` (monolítico, ~2100 líneas)
- Widgets tipo `ConsumerStatefulWidget`/`ConsumerWidget` para integración con Riverpod
- Colores hardcodeados como `Color(0xFF431874)` — no centralizados en tema
- Lógica de negocio mezclada con UI (no hay capa de repositorio separada)
- Nombres de clases descriptivos en inglés: `QuizzesTab`, `RankingsTab`, `ProfileTab`

### Python/FastAPI
- Modelos SQLAlchemy en español: `Usuario`, `BancoPreguntas`, `Pregunta`, `Respuesta`, `Puntaje`
- Esquemas Pydantic con `from_attributes = True` (Pydantic v2)
- Secret key hardcodeada en `auth.py` como fallback
- Seed data ejecutado al importar `main.py` (efecto lateral en import-time)

---

## 12. Estado del Proyecto

**Progreso declarado:** ~80%

### ✅ Completado
- Arquitectura cliente-servidor funcional
- Autenticación JWT con registro y login
- CRUD de bancos de preguntas (admin)
- Flujo de juego completo con temporizador
- Rankings globales con podium visual
- Bypass de login para modo demo/offline
- Validaciones de registro (cédula, teléfono, email, contraseñas)
- Destrucción automática de SQLite al expirar token

### 🔲 Pendiente
- Apartado legal (Términos y Condiciones / Política de Privacidad)
- Activos oficiales de marca institucional (logotipos, manual de estilo)
- Sistema de logros funcional (actualmente mockup visual)
- Tienda de canje de puntos (diseñada pero no implementada)
- Panel administrativo en la app móvil
- Sistema de niveles/XP funcional (actualmente datos estáticos)
- Edición de perfil
- Cálculo real de accuracy (actualmente mockeado)
- Gestión de errores de red robusta
- Tests unitarios e integración

---

## 13. Mockups Disponibles

Cada directorio en `mokups/` contiene un `code.html` (referencia de diseño en HTML/Tailwind) y un `screen.png` (captura visual):

| Carpeta | Pantalla | Descripción |
|---|---|---|
| `iniciar_sesi_n_claro/` | Login | Formulario de inicio de sesión con branding |
| `registro_de_usuario_claro/` | Registro | Registro multi-paso |
| `dashboard_principal/` | Dashboard Home | Level, Daily Challenge, categorías de quiz |
| `cuestionario_en_vivo_claro/` | Quiz Activo | Pregunta con timer, opciones, racha |
| `perfil_de_usuario_claro/` | Perfil | Stats, logros, acciones de cuenta |
| `tabla_de_posiciones_claro/` | Rankings | Podium 3D + lista de posiciones |

---

## 14. Variables de Entorno

### Backend (`Server/API/.env`)
```env
DATABASE_URL=postgresql://postgres:admin@localhost:5434/triviaisuj
SECRET_KEY=triviaisutj_super_secreto_jwt_2025_cambiar_en_produccion
```

### Flutter (`lib/api_service.dart`)
```dart
static const String baseUrl = 'http://10.0.2.2:8000'; // Emulador Android
```

> **Nota:** Para dispositivo físico, cambiar a la IP local de la máquina donde corre el backend.

---

## 15. Comandos de Ejecución Rápida

### Backend
```bash
cd Server/API
python -m venv venv && venv\Scripts\activate   # Windows
pip install -r requirements.txt
python create_tables.py                        # Inicializar DB (drop + create + seed)
uvicorn main:app --reload                      # Iniciar servidor en :8000
```

### Frontend
```bash
cd APP/trivia_app
flutter pub get
flutter run                                    # Conectar emulador o dispositivo
```

### Swagger UI
Accesible en `http://localhost:8000/docs` tras iniciar el servidor.
