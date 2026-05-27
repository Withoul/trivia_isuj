# 🔍 Preguntas Abiertas del Proyecto — Academic Pulse / QuizGame ISUTJ

> Este documento recopila preguntas abiertas y puntos de decisión identificados tras el análisis completo del proyecto. Están organizados por área para facilitar la priorización y discusión.

---

## 📐 1. Arquitectura y Estructura del Código

### 1.1 Monolito en `main.dart` — ¿Refactorizar a múltiples archivos?
El archivo `main.dart` contiene **2,124 líneas** con 7 clases de pantalla, lógica de negocio y UI entrelazados. Esto dificulta el mantenimiento, las pruebas y la colaboración entre desarrolladores.

**Pregunta:** ¿Se debería migrar a una estructura de carpetas por feature o por capa (screens/, widgets/, providers/, services/, models/) siguiendo las convenciones estándar de Flutter?

Si, se debe de realizar el desarrollo de forma estructurada y esquematizada de forma que sea sostenible y mantenible a lo largo del tiempo, esto facilitando los módulos de desarrollo y siguiendo esa estructura "atómica" que se maneja dentro de Flutter con Dart.

### 1.2 Ausencia de Capa de Repositorio
El `ApiService` es consumido directamente por los widgets de UI. No existe una capa intermedia (repositorio/use-case) que abstraiga la fuente de datos y facilite el testing o el cambio de implementación.

**Pregunta:** ¿Se beneficiaría el proyecto de implementar un patrón Repository que abstraiga las llamadas API y permita inyectar mocks para tests?

El proyecto se vería beneficiado en el mantenimiento y testing, por lo que de ejecutar estos cambios e implementarlos preguntas y profundizar en como se aplicarán dentro del proyecto y el resultado final de la app.

### 1.3 Gestión de Estado Parcial con Riverpod
Solo se usa `Riverpod` para el estado de autenticación (`authProvider`). El resto de datos (bancos, rankings, quiz en curso) se manejan con `setState()` local en cada `StatefulWidget`.

**Pregunta:** ¿Se deberían migrar todos los estados significativos (bancos activos, rankings, progreso del quiz, perfil) a providers de Riverpod para mayor consistencia y reactividad?

Analizar según se requiera reforzar la funcionalidad principal de la aplicación, por lo que también se busca un tiempo de respuesta y eficiencia en el manejo del estado. No implementar si no es requerido, caso contrario normalizar y utilizar el patrón Riverpod para cada caso.

### 1.4 Colores Hardcodeados
Los colores como `Color(0xFF431874)`, `Color(0xFFFFC043)`, etc., están repetidos en decenas de lugares. El `ThemeData` de Flutter no se aprovecha completamente, lo que hace difícil cambiar la paleta.

**Pregunta:** ¿Debería centralizarse la paleta de colores en un `AppTheme` o `AppColors` class/extension que refleje los tokens del `DESIGN.md`?

Si, debe de normalizarse y facilitar el mantenimiento del tema de la aplicación, por lo que se debe de implementar yu adaptar el proyecto a un uso de un AppTheme. Se debe de analizar y comprender el DESIGN.md y aplicarlo en la app.

### 1.5 Modelos Dart Faltantes
La app no tiene modelos Dart tipados (e.g., `User`, `QuizBank`, `Question`). Todos los datos de la API se manejan como `Map<String, dynamic>` y `List<dynamic>`, lo que anula la seguridad de tipos en tiempo de compilación.

**Pregunta:** ¿Se deberían crear modelos Dart con `fromJson()`/`toJson()` (o usar `freezed`/`json_serializable`) para los datos que se reciben de la API?

Si, se deben crear modelos Dart para los datos que se reciben de la API. Así manejar y controlar los datos de la API de forma independiente según el caso.

---

## 🔐 2. Seguridad

### 2.1 Secret Key Hardcodeada
En `auth.py`, la `SECRET_KEY` está hardcodeada como fallback: `"tu_super_secreto_aqui_cambiar_en_produccion"`. Aunque existe un `.env`, el valor hardcodeado en código es un riesgo si se olvida configurar.

**Pregunta:** ¿Debería eliminarse el fallback hardcodeado y forzar que la `SECRET_KEY` se lea exclusivamente del `.env`, fallando explícitamente si no está presente?

Dado a que actualmente no se posee el lanzamiento a producción, se considera innecesario implementar esta medida de seguridad. Sin embargo, se recomienda su implementación antes del lanzamiento oficial, por lo que agregar un recordatorio dentro del código fallback indicando que se debe de implementar esta medida de seguridad antes del lanzamiento oficial.

### 2.2 `.env` Incluido en el Repositorio
Aunque `.gitignore` lista `.env`, el archivo `Server/API/.env` **existe en el repositorio** con la URL de base de datos y secret key visibles.

**Pregunta:** ¿Se debe eliminar el `.env` del historial de Git, agregar un `.env.example` con valores placeholder, y rotar las credenciales comprometidas?

Si, crea el archivo `.env.example` y agrega los valores placeholder que se encuentran en el archivo `.env`. Además elimina el archivo `.env` del historial de Git en caso de existir este en el repositorio remoto.

### 2.3 Contraseña del Admin por Defecto
La cuenta `admin@admin.com` con contraseña `admin` se siembra automáticamente en producción.

**Pregunta:** ¿Debería existir un mecanismo para forzar el cambio de contraseña del administrador en el primer login, o deshabilitar el seeding en modo producción?

Actualmente el proyecto no se encuentra en producción por lo que se considera innecesario implementar esta medida de seguridad. Sin embargo, se recomienda su implementación antes del lanzamiento oficial, por lo que agregar un recordatorio dentro del código del seed (quemado) indicando que se debe de implementar esta medida de seguridad antes del lanzamiento oficial.

### 2.4 Respuestas Correctas Enviadas al Cliente
El endpoint `GET /banks/{bank_id}/play` envía las respuestas **con el campo `es_correcta`** directamente al cliente. Un usuario técnico podría interceptar la respuesta HTTP y ver todas las respuestas correctas antes de responder.

**Pregunta:** ¿Debería el servidor omitir `es_correcta` en la respuesta, validar cada respuesta individualmente con un endpoint `POST /answer` y devolver si fue correcta o no en tiempo real?

Al ser una aplicación que busca y cuya finalidad es llamar la atención de nuevos usuarios a la institución, no se considera un púnto a mejorar actualmente, esto debido a que tampoco se desea perjudicar el tiempo de análisis de la respuesta de cada pregunta que posee el usuario, en caso de que sea un tiempo de respuesta optimo el planteado según como se manejan otras aplicaciones de Quizz como Kahoot o Preguntados. Por lo que se deja para análisis futuro o si el usuario lo solicita se puede mejorar para una mejor experiencia de usuario.

### 2.5 Validación de Token en Cada Request
El sistema valida el token buscándolo en la tabla `logins` en cada request, lo cual es correcto, pero no limpia tokens expirados de la base de datos.

**Pregunta:** ¿Se debería implementar un job periódico (cron/task) para purgar tokens expirados de la tabla `logins`, o implementar un mecanismo de revocación explícito?

El sistema actual de validación de tokens es correcto, sin embargo, no se implementa un mecanismo para limpiar tokens expirados de la base de datos. Se recomienda implementar un job periódico (cron/task) para purgar tokens expirados de la tabla `logins`, o implementar un mecanismo de revocación explícito. Esto se debe a que los tokens expirados pueden acumularse en la base de datos, lo que podría afectar el rendimiento del sistema. Además, los tokens expirados podrían ser utilizados por atacantes para acceder a las cuentas de los usuarios. Por lo que se recomienda implementar un job periódico (cron/task) para purgar tokens expirados de la tabla `logins`, o implementar un mecanismo de revocación explícito que pueda manejar y/o administrar el administrador según el caso.

---

## 🎨 3. Diseño e Interfaz de Usuario

### 3.1 Gap entre Mockups HTML y Flutter Real
Los mockups en `mokups/` están construidos con HTML + Tailwind CSS usando el sistema de diseño completo de `DESIGN.md` (glassmorphism, gradientes, fuentes Google). Sin embargo, la implementación Flutter usa `Roboto` por defecto (no Plus Jakarta Sans / Inter) y no implementa glassmorphism ni muchos de los efectos visuales especificados.

**Pregunta:** ¿Se debería invertir en alinear la app Flutter con los mockups, incorporando las fuentes correctas (Plus Jakarta Sans + Inter), gradientes de fondo, y efectos de glassmorphism mediante `BackdropFilter`?

Si, se debe de implementar un diseño lo más apegado al archivo de `DESIGN.md`, implementando de ser posible los efectos de glassmorphism mediante `BackdropFilter` y agregando las fuentes correctas (Plus Jakarta Sans + Inter) y gradientes de fondo.

### 3.2 Datos Estáticos en el Perfil
La pantalla de perfil muestra datos hardcodeados: "Alex Estudiante", "45 Quizzes Completados", "12 Racha Máxima", "15,400 Puntos". No se obtienen del servidor ni de la sesión local.

**Pregunta:** ¿Se debe crear un endpoint `GET /users/me/profile` que retorne estadísticas reales del usuario y conectar el `ProfileTab` a datos dinámicos?

Si, se deben de obtener los datos que se guardan y almacenan del usuario para que este pueda visualizar los datos que ingresó mediante el registro del usuario, por lo que se requiere el metodo GET para obtener los datos reales del usuario mediante su ID. Actualmente no se muestra ningún dato del usuario ya que el endpoint GET /users/me/profile no existe.

### 3.3 Pill de Gemas ("1,250 💎") Estática
El indicador de gemas/puntos en el AppBar siempre muestra "1,250" de forma hardcodeada.

**Pregunta:** ¿Esta pill debería reflejar los puntos reales del usuario obtenidos del servidor, o se planea un sistema de "gemas" separado del puntaje de quiz?

Si, debe de reflejar los puntos reales del usuario obtenidos del servidor, dentro de la tabla de usuarios se debe de contemplar realizar un campo que indique los puntos reales del usuario y de igual manera implementar un método GET para obtener los puntos reales del usuario mediante su ID, estos se sumarán según un sistema de puntuación en el que cada pregunta según su respuesta rápida y racha que se posea al responder se entregará un límite máximo de puntos, es decir si la pregunta tiene un total máximo de dar 10 puntos, estos se dividirán según la rapidez de la respuesta del usuario y la racha que tenga, siendo lo máximo que se entregará de puntos el límite impuesto en este ejemplo 10 (por lo que considerar añadir e implementar al campo de las preguntas del banco correspondiente este campo en el que se indique los puntos máximos a entregar por respuesta correcta a la pregunta).

### 3.4 Indicador de Racha ("Racha x5") Estático
En la pantalla de quiz, la racha siempre muestra "x5" sin importar las respuestas consecutivas correctas.

**Pregunta:** ¿Se debería implementar lógica real de racha que incremente con cada respuesta correcta consecutiva y se reinicie con cada error, afectando potencialmente el multiplicador de puntos?

Se debe de implementar la lógica de racha, de manera que si el usuario responde correctamente a las preguntas de manera consecutiva, la racha se incremente en 1, si responde incorrectamente se reinicie a 0, de igual manera se debe de implementar un campo en la tabla de usuarios para guardar la racha del usuario y un método GET para obtener la racha del usuario mediante su ID. Este campo de racha también se debe de utilizar para calcular el multiplicador de puntos que se le entregará al usuario según la racha que tenga, por ejemplo, si el usuario tiene una racha de 5, se le entregarán 5 puntos adicionales a los puntos que se le entreguen según la rapidez de la respuesta del usuario, considerar que la racha no va a persistir dentro de la BDD de postgresql, por lo que ver la forma de manejar el incremento y decrecimiento de la racha según corresponda al intento del usuario en el banco de preguntas que esté jugando.

### 3.5 Dashboard del Mockup vs. Implementación Actual
El mockup `dashboard_principal` muestra un dashboard rico con nivel/XP, Daily Challenge, y categorías de quiz tipo grid (Tecnología, Cultura General, Lógica). La implementación actual en `QuizzesTab` es una lista simple de bancos activos.

**Pregunta:** ¿Se debería implementar el diseño completo del dashboard con sistema de niveles, desafío diario y categorización visual de los bancos de preguntas?

En el dashboard se debe de reflejar los puntos del usuario obtenidos a lo largo de los intentos, los bancos de preguntas (quizzes habilitados), no se requiere del desafío diario y tampoco se requiere un indicador de niveles, debido a que este no se maneja dentro del sistema. Los bancos de preguntas deben de aparecer según la categoría que tenga cada banco de preguntas y en vez del daily challenge debe de mostrarse el quizz con la fecha de finalización más próxima (tiempo_fin).

---

## ⚙️ 4. Lógica de Negocio y Funcionalidad

### 4.1 Puntaje Fijo de +10 por Respuesta
Actualmente, toda respuesta correcta suma exactamente 10 puntos, sin importar la dificultad, el tiempo restante o la racha.

**Pregunta:** ¿Se debería implementar un sistema de puntaje dinámico basado en factores como: tiempo restante al responder, racha de respuestas correctas, o nivel de dificultad de la pregunta?

### 4.2 No Hay Prevención de Repetición de Bancos
Un usuario puede jugar el mismo banco de preguntas múltiples veces y acumular puntaje sin restricción.

**Pregunta:** ¿Debería el sistema prevenir que un usuario juegue un banco más de una vez (o limitar intentos), o se permite la repetición para mejorar puntaje (tomando solo el mejor)?

### 4.3 Cálculo de Accuracy Mockeado
El campo `accuracy` en el ranking se calcula de forma hardcodeada en el backend (`78` para el usuario de prueba, `80 - idx * 2` para otros).

**Pregunta:** ¿Se debería calcular la accuracy real basándose en las respuestas correctas vs. totales? Esto requeriría que el servidor registre más detalle que solo el puntaje neto.

### 4.4 Temporizador Fijo de 12 Segundos
Todas las preguntas tienen el mismo temporizador de 12 segundos, sin distinción por dificultad o tipo de banco.

**Pregunta:** ¿Debería ser configurable el tiempo por pregunta a nivel de banco de preguntas, permitiendo que el administrador defina el timeout?

### 4.5 Número de Preguntas Hardcodeado
La card de quiz muestra "10 Preguntas" de forma fija, pero el número real depende de cuántas preguntas tenga el banco.

**Pregunta:** ¿Debería el endpoint `/banks/active` incluir un conteo de preguntas (`question_count`) para mostrar información precisa al usuario antes de iniciar?

### 4.6 Tienda de Canje — Diseño y Alcance
El `main_readme.md` menciona una tienda de canje donde los estudiantes pueden canjear puntos por becas. No existe implementación ni diseño detallado.

**Pregunta:** ¿Cuál es el alcance de la tienda? ¿Solo becas o también merchandise/beneficios? ¿Quién aprueba un canje? ¿Se requiere integración con sistemas administrativos de la universidad?

### 4.7 Sistema de Logros — Criterios de Desbloqueo
La pantalla de perfil muestra badges como "Mente Rápida" y "Lector Feroz", pero no existe lógica de backend para calcular o registrar logros.

**Pregunta:** ¿Cuáles son los criterios específicos para desbloquear cada logro? ¿Se almacenarán los logros en PostgreSQL? ¿Se requiere una tabla `logros_usuario` y un sistema de reglas configurable?

---

## 🗄️ 5. Base de Datos e Infraestructura

### 5.1 No Existe Tabla para el Detalle de Respuestas del Usuario
El modelo actual solo guarda `puntaje_neto` por banco. No registra qué preguntas respondió correcta o incorrectamente cada usuario.

**Pregunta:** ¿Se debería agregar una tabla `respuestas_usuario` que registre `usuario_id`, `pregunta_id`, `respuesta_id`, `es_correcta`, `tiempo_respuesta` para analytics, accuracy real y detección de trampas?

### 5.2 No Hay Migraciones de Base de Datos
Se usa `create_tables.py` que hace `drop_all()` + `create_all()`. No existe un sistema de migraciones (como Alembic) para evolucionar el esquema sin perder datos.

**Pregunta:** ¿Se debería integrar Alembic para migraciones incrementales del esquema de base de datos, especialmente si se planea un despliegue a producción?

### 5.3 Puerto No Estándar de PostgreSQL
El `.env` usa el puerto `5434` en lugar del estándar `5432`.

**Pregunta:** ¿Es intencional (para evitar conflictos con una instancia existente en 5432) o se debería documentar más claramente, o estandarizar?

### 5.4 No Hay CORS Configurado
`main.py` no configura `CORSMiddleware`. Esto puede causar problemas si se necesita acceso desde un frontend web.

**Pregunta:** ¿Se debería agregar `CORSMiddleware` de FastAPI para permitir requests desde orígenes web, o la app es estrictamente móvil?

### 5.5 Seed Data en Import-Time
El `seed_data()` se ejecuta automáticamente al importar `main.py`, lo cual ocurre cada vez que arranca el servidor.

**Pregunta:** ¿Debería el seeding ser un comando explícito (`python seed.py`), una opción de línea de comandos (`--seed`), o activarse solo con una variable de entorno (`SEED_ON_START=true`)?

---

## 🧪 6. Testing y Calidad

### 6.1 Ausencia Total de Tests
No existen tests unitarios, de integración, ni end-to-end en ninguna capa del proyecto (ni Flutter ni Python).

**Pregunta:** ¿Cuál es la estrategia de testing deseada? ¿Se debería comenzar con tests unitarios para los endpoints de FastAPI (con `TestClient`) y para la lógica del `AuthNotifier` / `ApiService` en Flutter?

### 6.2 No Hay Manejo Robusto de Errores de Red
En `api_service.dart`, las llamadas HTTP no tienen `try-catch` para manejar `SocketException`, timeouts, o errores de parsing JSON.

**Pregunta:** ¿Se debería implementar un wrapper HTTP con manejo centralizado de errores, reintentos automáticos, y estados de carga/error/éxito consistentes?

### 6.3 No Hay Logging Estructurado
Ni el backend ni el frontend tienen un sistema de logging estructurado (solo `print()` statements).

**Pregunta:** ¿Se debería integrar un logger como `loguru` (Python) y `logger` (Dart) para trazabilidad en desarrollo y producción?

---

## 🚀 7. Despliegue y DevOps

### 7.1 No Hay Configuración de Despliegue
No existe Dockerfile, docker-compose, ni scripts de CI/CD.

**Pregunta:** ¿Se planea un despliegue en la nube (AWS, GCP, DigitalOcean) o es un servidor on-premise de la universidad? ¿Se debería containerizar con Docker?

### 7.2 Separación de Ambientes
No hay distinción entre desarrollo, staging y producción en la configuración.

**Pregunta:** ¿Se deberían crear perfiles de configuración separados para cada ambiente (dev/staging/prod), especialmente para la `SECRET_KEY`, `DATABASE_URL` y la URL base de la API en Flutter?

### 7.3 Versionamiento de la API
La API no tiene prefijo de versión (e.g., `/api/v1/`).

**Pregunta:** ¿Se debería agregar versionamiento de la API para permitir cambios breaking sin afectar clientes existentes?

---

## 📱 8. Experiencia de Usuario (UX)

### 8.1 No Hay Pantalla de Resultados del Quiz
Al terminar un quiz, solo se muestra un `SnackBar` con el puntaje. No hay una pantalla dedicada de resultados con desglose, estadísticas, o call-to-action.

**Pregunta:** ¿Se debería crear una pantalla de resultados que muestre: puntaje obtenido, respuestas correctas vs. incorrectas, tiempo promedio por pregunta, comparación con otros jugadores, y opción de compartir?

### 8.2 No Hay Feedback Visual de Correcto/Incorrecto
Al seleccionar una respuesta, la opción se marca como "seleccionada" visualmente (borde púrpura), pero no se muestra si fue correcta (verde) o incorrecta (rojo/shake) como especifica el `DESIGN.md`.

**Pregunta:** ¿Se deberían implementar los estados visuales de Correct (borde verde + check) e Incorrect (borde rojo + animación "shake") especificados en el sistema de diseño?

### 8.3 No Hay Notificaciones Push
No existe sistema de notificaciones para avisar al usuario cuando se activa un nuevo banco de preguntas.

**Pregunta:** ¿Se debería integrar Firebase Cloud Messaging (FCM) para enviar push notifications cuando se habilita un nuevo banco o cuando se acerca la fecha límite de uno activo?

### 8.4 No Hay Soporte Offline Completo
El bypass de login permite entrar sin servidor, pero no hay preguntas locales ni caché de bancos completados.

**Pregunta:** ¿Se debería implementar una caché local más robusta que descargue bancos y preguntas para jugar completamente offline, sincronizando puntajes cuando se recupere la conexión?

### 8.5 Registro en 2 Pasos — Validación de Cédula Ecuatoriana
La validación de cédula solo verifica 10 dígitos numéricos, pero no aplica el algoritmo de validación de cédula ecuatoriana (módulo 10).

**Pregunta:** ¿Se debería implementar la validación completa del dígito verificador de la cédula ecuatoriana para prevenir datos inválidos?

---

## 📋 Resumen de Prioridades Sugeridas

| Prioridad | Área | Tema |
|---|---|---|
| 🔴 Alta | Seguridad | Respuestas correctas expuestas al cliente (§2.4) |
| 🔴 Alta | Seguridad | `.env` con credenciales en el repo (§2.2) |
| 🔴 Alta | Seguridad | Secret key hardcodeada como fallback (§2.1) |
| 🟠 Media | Arquitectura | Refactorizar `main.dart` monolítico (§1.1) |
| 🟠 Media | Arquitectura | Crear modelos Dart tipados (§1.5) |
| 🟠 Media | Diseño | Alinear Flutter con mockups (fuentes, glassmorphism) (§3.1) |
| 🟠 Media | UX | Feedback visual correcto/incorrecto en quiz (§8.2) |
| 🟠 Media | UX | Pantalla de resultados del quiz (§8.1) |
| 🟠 Media | Lógica | Prevención de repetición de bancos (§4.2) |
| 🟡 Baja | Infra | Migraciones con Alembic (§5.2) |
| 🟡 Baja | Testing | Tests unitarios para API y providers (§6.1) |
| 🟡 Baja | DevOps | Dockerización y CI/CD (§7.1) |
| 🟡 Baja | UX | Notificaciones push con FCM (§8.3) |

---

*Documento generado a partir del análisis del estado actual del proyecto al 26 de mayo de 2026.*
