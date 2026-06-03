<?php
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

$reset = isset($_GET['reset']) && $_GET['reset'] === 'true';

try {
    if ($reset) {
        echo "Eliminando tablas existentes...\n<br>";
        $pdo->exec("SET FOREIGN_KEY_CHECKS = 0;");
        $pdo->exec("DROP TABLE IF EXISTS puntajes;");
        $pdo->exec("DROP TABLE IF EXISTS respuestas;");
        $pdo->exec("DROP TABLE IF EXISTS preguntas;");
        $pdo->exec("DROP TABLE IF EXISTS bancos_preguntas;");
        $pdo->exec("DROP TABLE IF EXISTS logins;");
        $pdo->exec("DROP TABLE IF EXISTS usuarios;");
        $pdo->exec("SET FOREIGN_KEY_CHECKS = 1;");
        echo "Tablas eliminadas.\n<br><br>";
    }

    echo "Creando tablas...\n<br>";

    // 1. Usuarios Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS usuarios (
        id INT AUTO_INCREMENT PRIMARY KEY,
        correo VARCHAR(255) UNIQUE NOT NULL,
        contrasena VARCHAR(255) NOT NULL,
        primer_nombre VARCHAR(100) NOT NULL,
        segundo_nombre VARCHAR(100) NULL,
        primer_apellido VARCHAR(100) NOT NULL,
        segundo_apellido VARCHAR(100) NULL,
        institucion VARCHAR(255) NOT NULL,
        cedula VARCHAR(20) NULL,
        telefono VARCHAR(20) NULL,
        tipo_perfil ENUM('ADMINISTRADOR', 'JUGADOR') DEFAULT 'JUGADOR' NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'usuarios' lista.\n<br>";

    // 2. Logins Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS logins (
        id INT AUTO_INCREMENT PRIMARY KEY,
        usuario_id INT NOT NULL,
        token VARCHAR(255) UNIQUE NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        expira_en DATETIME NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'logins' lista.\n<br>";

    // 3. Bancos Preguntas Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS bancos_preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        titulo VARCHAR(255) NOT NULL,
        is_active BOOLEAN DEFAULT FALSE NOT NULL,
        tiempo_inicio DATETIME NULL,
        tiempo_fin DATETIME NULL,
        tiempo_por_pregunta INT DEFAULT 12 NOT NULL,
        color_banner VARCHAR(20) DEFAULT '#461F70' NOT NULL,
        puntos_por_pregunta INT DEFAULT 5 NOT NULL,
        es_permanente BOOLEAN DEFAULT FALSE NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'bancos_preguntas' lista.\n<br>";

    // 4. Preguntas Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        banco_id INT NOT NULL,
        texto_pregunta VARCHAR(1000) NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (banco_id) REFERENCES bancos_preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'preguntas' lista.\n<br>";

    // 5. Respuestas Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS respuestas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pregunta_id INT NOT NULL,
        texto_respuesta VARCHAR(1000) NOT NULL,
        es_correcta BOOLEAN DEFAULT FALSE NOT NULL,
        FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'respuestas' lista.\n<br>";

    // 6. Puntajes Table
    $pdo->exec("CREATE TABLE IF NOT EXISTS puntajes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        usuario_id INT NOT NULL,
        banco_id INT NOT NULL,
        puntaje_neto INT DEFAULT 0 NOT NULL,
        completado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY (banco_id) REFERENCES bancos_preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'puntajes' lista.\n<br><br>";

    // Seed default data if usuarios is empty
    $stmt = $pdo->query("SELECT COUNT(*) FROM usuarios");
    $count = $stmt->fetchColumn();

    if ($count == 0) {
        echo "Sembrando datos iniciales...\n<br>";

        // Seed Admin
        $pw_admin = password_hash("admin", PASSWORD_BCRYPT);
        $pdo->prepare("INSERT INTO usuarios (correo, contrasena, primer_nombre, primer_apellido, institucion, cedula, telefono, tipo_perfil) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
            ->execute(['admin@admin.com', $pw_admin, 'Admin', 'Sistema', 'Instituto Superior Universitario Japón', '1799999999', '0999999999', 'ADMINISTRADOR']);
        echo "- Sembrado administrador (admin@admin.com / admin)\n<br>";

        // Seed User
        $pw_user = password_hash("user1234", PASSWORD_BCRYPT);
        $pdo->prepare("INSERT INTO usuarios (correo, contrasena, primer_nombre, primer_apellido, institucion, cedula, telefono, tipo_perfil) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
            ->execute(['usuario@usuario.com', $pw_user, 'David', 'L.', 'Ingeniería en Sistemas', '1722222222', '0988888888', 'JUGADOR']);
        echo "- Sembrado jugador de prueba (usuario@usuario.com / user1234)\n<br>";

        // Seed Banks
        $pdo->prepare("INSERT INTO bancos_preguntas (titulo, is_active, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente) VALUES (?, ?, ?, ?, ?, ?)")
            ->execute(['Fundamentos de Desarrollo Móvil e ISUTJ 🧪', 1, 12, '#7C3AED', 5, 1]);
        $banco_id = $pdo->lastInsertId();

        // Seed Questions & Answers
        $pdo->prepare("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (?, ?)")
            ->execute([$banco_id, '¿Cuál es el lenguaje de programación principal para desarrollo Android nativo?']);
        $preg1_id = $pdo->lastInsertId();
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg1_id, 'Swift', 0]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg1_id, 'Kotlin', 1]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg1_id, 'JavaScript', 0]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg1_id, 'C#', 0]);

        $pdo->prepare("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (?, ?)")
            ->execute([$banco_id, 'En Flutter, ¿qué widget se utiliza comúnmente para estructurar una pantalla con AppBar, Body y BottomNavigationBar?']);
        $preg2_id = $pdo->lastInsertId();
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg2_id, 'Container', 0]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg2_id, 'Scaffold', 1]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg2_id, 'Column', 0]);
        $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
            ->execute([$preg2_id, 'SizedBox', 0]);

        echo "- Datos de preguntas iniciales sembrados con éxito.\n<br>";
    }

    echo "<h3>¡Base de datos inicializada correctamente!</h3>";

} catch (PDOException $e) {
    echo "<h3>Error al inicializar la base de datos:</h3> " . $e->getMessage();
}
?>
