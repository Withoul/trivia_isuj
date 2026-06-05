import mysql.connector
import bcrypt
import json

def run():
    print("Connecting...")
    conn = mysql.connector.connect(
        host="institutoj17.sg-host.com",
        user="ubr7awxothprf",
        password="ISUJ123/2026",
        database="dbg4rp1niwrzmg"
    )
    cursor = conn.cursor()

    print("Dropping tables...")
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
    tables = ['puntajes', 'respuestas', 'preguntas', 'bancos_preguntas', 'administradores', 'jugadores', 'logins', 'usuarios']
    for t in tables:
        cursor.execute(f"DROP TABLE IF EXISTS {t};")
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")

    print("Creating tables...")
    cursor.execute("""
    CREATE TABLE jugadores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        avatar VARCHAR(50) DEFAULT 'ball',
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)
    cursor.execute("""
    CREATE TABLE administradores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        correo VARCHAR(255) UNIQUE NOT NULL,
        contrasena VARCHAR(255) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)
    cursor.execute("""
    CREATE TABLE bancos_preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        titulo VARCHAR(255) NOT NULL,
        is_active BOOLEAN DEFAULT TRUE NOT NULL,
        tiempo_por_pregunta INT DEFAULT 15 NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)
    cursor.execute("""
    CREATE TABLE preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        banco_id INT NOT NULL,
        texto_pregunta VARCHAR(1000) NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (banco_id) REFERENCES bancos_preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)
    cursor.execute("""
    CREATE TABLE respuestas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pregunta_id INT NOT NULL,
        texto_respuesta VARCHAR(500) NOT NULL,
        es_correcta BOOLEAN DEFAULT FALSE NOT NULL,
        FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)
    cursor.execute("""
    CREATE TABLE puntajes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        jugador_id INT NOT NULL,
        banco_id INT NOT NULL,
        puntaje_neto INT DEFAULT 0 NOT NULL,
        racha_maxima INT DEFAULT 0 NOT NULL,
        correctas INT DEFAULT 0 NOT NULL,
        total_preguntas INT DEFAULT 0 NOT NULL,
        completado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (jugador_id) REFERENCES jugadores(id) ON DELETE CASCADE,
        FOREIGN KEY (banco_id) REFERENCES bancos_preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    """)

    print("Seeding admin...")
    pw = bcrypt.hashpw(b"admin", bcrypt.gensalt()).decode('utf-8')
    # Use standard bcrypt prefix for PHP compatibility (usually $2y$, but $2b$ is handled by password_verify in newer PHP)
    pw = pw.replace('$2b$', '$2y$')
    cursor.execute("INSERT INTO administradores (correo, contrasena, nombre) VALUES (%s, %s, %s)", ('admin@admin.com', pw, 'Administrador'))

    print("Seeding bank...")
    cursor.execute("INSERT INTO bancos_preguntas (titulo, is_active, tiempo_por_pregunta) VALUES (%s, %s, %s)", ('Mundial de Fútbol ⚽', True, 15))
    banco_id = cursor.lastrowid

    print("Seeding questions...")
    # Just seed a few questions for now to test, the rest can be added from admin panel
    q1 = ('¿En qué año participó Ecuador por primera vez en una Copa Mundial de la FIFA?', [
        ['1998', False], ['2002', True], ['2006', False], ['2010', False]
    ])
    q2 = ('¿Quién es el máximo goleador de los Mundiales?', [
        ['Ronaldo', False], ['Klose', True], ['Pelé', False], ['Messi', False]
    ])
    for q, ops in [q1, q2]:
        cursor.execute("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (%s, %s)", (banco_id, q))
        pid = cursor.lastrowid
        for op_text, op_corr in ops:
            cursor.execute("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (%s, %s, %s)", (pid, op_text, op_corr))

    conn.commit()
    print("Database seeded successfully.")
    cursor.close()
    conn.close()

if __name__ == '__main__':
    run()
