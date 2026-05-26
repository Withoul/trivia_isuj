# Trivia App - Documentación Principal

## Arquitectura General
El proyecto "Trivia" es una aplicación cliente-servidor orientada a administrar y jugar pruebas de trivia organizadas en "bancos de preguntas".

La arquitectura se divide en dos partes principales:
1. **Server (Backend en FastAPI + PostgreSQL):** Maneja la persistencia central de los datos. Administra usuarios, bancos de preguntas (con temporizadores de apertura y cierre) y registra el puntaje neto final de cada jugador por banco de preguntas.
2. **App (Frontend en Flutter + SQLite):** Aplicación móvil que interactúa con el usuario. Administra localmente las sesiones a través del token y guarda el progreso en una base de datos local SQLite. Si el token de sesión expira o no es válido, se recrea una nueva instancia limpia de SQLite para garantizar la seguridad de los datos locales (sin persistencia de progreso previo).

## Requisitos Funcionales
- **Autenticación:** Login, registro y validación por token en el dispositivo.
- **Roles:** Existen administradores y jugadores. Los administradores pueden crear preguntas, respuestas y jugar. Los jugadores solo juegan.
- **Bancos de Preguntas:** Agrupaciones de preguntas. Se habilitan y deshabilitan en base a un temporizador (fecha/hora inicio y fecha/hora fin).
- **Flujo de Juego:** Al iniciar un banco de preguntas en la App, el usuario debe terminarlo. Si sale de la prueba, se corta en ese momento y se envía el puntaje que haya obtenido hasta allí al backend.
- **Sincronización:** El backend solo registra el *puntaje neto* del usuario en un banco de preguntas en particular. No guarda el detalle de cada pregunta que contestó bien o mal, por eficiencia y simplicidad.

## Requisitos No Funcionales
- **Seguridad:** Contraseñas hasheadas en BD, uso de JWT o tokens únicos por inicio de sesión.
- **Aislamiento en App:** La base de datos SQLite no permite migrar datos si un token queda inválido. La app vacía o regenera la BD local para forzar un nuevo entorno seguro.
- **Temporizadores:** El backend filtra los bancos de preguntas para que el jugador solo vea aquellos cuyo `tiempo_inicio` y `tiempo_fin` coincidan con el momento actual.

## Bases de Datos
1. **PostgreSQL (Servidor):**
   Almacena datos estáticos y sensibles, además del resultado final. Ver `Docs/db_scripts.md` para el script de creación. Adicionalmente, puedes ejecutar el script autónomo `python Server/API/create_tables.py` para generar automáticamente todas las tablas actualizadas en la base de datos `triviaisuj` y sembrar los datos de prueba al instante.
2. **SQLite (App):**
   Almacena token de sesión, estado temporal de preguntas descargadas para jugar offline/sin interrupción y el progreso actual en la trivia hasta que se envía.

## APIs (Endpoints Principales)
### Autenticación
- `POST /auth/register`: Recibe datos de usuario y lo registra.
- `POST /auth/login`: Recibe credenciales y devuelve el Token.

### Bancos de Preguntas y Juego
- `GET /banks/active`: Devuelve los bancos activos en este instante de tiempo (basado en temporizador).
- `GET /banks/{bank_id}/play`: Obtiene las preguntas (con respuestas) del banco para poder jugarlo en la App.
- `POST /banks/{bank_id}/score`: Envía el resultado (puntaje neto) obtenido al terminar de jugar o al salirse de la prueba de forma anticipada.

### Administración
- `POST /admin/banks`: Crea un nuevo banco de preguntas.
- `POST /admin/banks/{bank_id}/questions`: Añade preguntas y respuestas.
- `PUT /admin/banks/{bank_id}`: Edita datos, temporizadores, o el estado de habilitación.

## Credenciales del Sistema (Autosembradas en la base de datos `triviaisuj`)
Al arrancar el servidor backend por primera vez, se insertan automáticamente estas cuentas para facilitar el desarrollo y la evaluación del proyecto:
- **Administrador:**
  - **Correo:** `admin@admin.com`
  - **Contraseña:** `admin`
  - **Rol:** `ADMINISTRADOR`
- **Jugador / Estudiante:**
  - **Correo:** `usuario@usuario.com`
  - **Contraseña:** `user1234`
  - **Rol:** `JUGADOR`

## Conexión a Base de Datos
La base de datos utilizada para el servidor local PostgreSQL se llama `triviaisuj`. Puedes configurar la conexión en `Server/API/database.py` o mediante variables de entorno en tu archivo `.env`.

---

## Estado del Proyecto y Próximos Pasos (Progreso Actual: 80%)
Al día de hoy, la aplicación cuenta con un **80% de avance general**. Las bases de datos PostgreSQL y SQLite, el sistema de autenticación de dos pasos con validaciones minuciosas, el bypass de login para pruebas locales sin conexión, y la sincronización de puntajes básicos se encuentran completamente funcionales.

### 📋 Pendientes Críticos y Requerimientos Futuros
1. **Apartado Legal (Términos y Condiciones / Política de Privacidad):**
   - Aún falta implementar e integrar formalmente la sección legal donde se explique detalladamente el tratamiento y uso de datos personales de los usuarios ("Términos y Condiciones").
2. **Línea Visual e Identidad Institucional:**
   - Se requiere el suministro oficial de los activos de marca de la institución, incluyendo logotipos, logos oficiales, colores corporativos definidos y manual de estilo institucional.

---

## Funcionalidades del Sistema

### 📱 Aplicación Móvil (Multiplataforma: Android & iOS)
La aplicación móvil está siendo desarrollada utilizando Flutter, lo cual asegura su compatibilidad, rendimiento y diseño optimizado tanto para dispositivos **Android** como **iOS**.

#### 👤 Rol: Usuario (Estudiante)
- **Trivia y Quizzes:** Responder trivias basadas en bancos de preguntas con temporizador.
- **Puntos:** Obtención de puntos acumulables por cada quiz o banco de preguntas completado exitosamente.
- **Logros:** Sistema de insignias y logros desbloqueables basados en el desempeño e hitos alcanzados por el usuario.
- **Tienda de Canje:** Una tienda integrada donde el usuario puede canjear sus puntos acumulados por beneficios específicos, tales como becas (no se contemplan otros ítems adicionales en esta etapa).

#### 🔑 Rol: Administrador
- **Gestión de Bancos de Preguntas:** Capacidad completa para subir nuevos bancos de preguntas, añadirles preguntas y respuestas estructuradas.
- **Control de Acceso y Estado:** Habilitar e inhabilitar bancos de preguntas de forma manual o mediante fechas programadas.
- **Edición de la Tienda:** Administrar los artículos y beneficios de la tienda (becas) disponibles para canje.
- **Gestión de Usuarios:** Control, visualización y gestión integral de los usuarios y estudiantes registrados en la plataforma.


