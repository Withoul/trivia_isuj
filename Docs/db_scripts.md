# Base de Datos PostgreSQL - Script de Inicialización

Este script contiene la definición completa de las tablas y relaciones para la persistencia en el servidor.
Puedes ejecutar este script en cualquier cliente SQL compatible con PostgreSQL (DBeaver, pgAdmin, psql) para generar las tablas. No es necesario crear la base de datos automáticamente desde el código Python, el backend asumirá que estas tablas existen.

```sql
-- 1. Enum para Tipos de Perfil
CREATE TYPE perfil_enum AS ENUM ('ADMINISTRADOR', 'JUGADOR');

-- 2. Tabla de Usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    correo VARCHAR(255) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL, -- Hashed
    primer_nombre VARCHAR(100) NOT NULL,
    segundo_nombre VARCHAR(100),
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100),
    institucion VARCHAR(255) NOT NULL,
    tipo_perfil perfil_enum NOT NULL DEFAULT 'JUGADOR',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabla de Login (Sesiones/Tokens)
CREATE TABLE logins (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expira_en TIMESTAMP,
    CONSTRAINT fk_usuario_login FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
);

-- 4. Tabla de Bancos de Preguntas
CREATE TABLE bancos_preguntas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    tiempo_inicio TIMESTAMP, -- Inicio del temporizador
    tiempo_fin TIMESTAMP,    -- Fin del temporizador
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabla de Preguntas
CREATE TABLE preguntas (
    id SERIAL PRIMARY KEY,
    banco_id INT NOT NULL,
    texto_pregunta TEXT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_banco_pregunta FOREIGN KEY (banco_id) REFERENCES bancos_preguntas (id) ON DELETE CASCADE
);

-- 6. Tabla de Respuestas
CREATE TABLE respuestas (
    id SERIAL PRIMARY KEY,
    pregunta_id INT NOT NULL,
    texto_respuesta TEXT NOT NULL,
    es_correcta BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_pregunta_respuesta FOREIGN KEY (pregunta_id) REFERENCES preguntas (id) ON DELETE CASCADE
);

-- 7. Tabla de Puntajes (Ranks/Leaderboard)
CREATE TABLE puntajes (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    banco_id INT NOT NULL,
    puntaje_neto INT NOT NULL DEFAULT 0,
    completado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_puntaje FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
    CONSTRAINT fk_banco_puntaje FOREIGN KEY (banco_id) REFERENCES bancos_preguntas (id) ON DELETE CASCADE
);

-- Índices útiles para rendimiento
CREATE INDEX idx_bancos_temporizador ON bancos_preguntas(tiempo_inicio, tiempo_fin) WHERE is_active = TRUE;
CREATE INDEX idx_token_login ON logins(token);
CREATE INDEX idx_puntajes_usuario ON puntajes(usuario_id);
```
