<?php
/**
 * DATABASE SETUP - Trivia Mundialista
 * Ejecutar una vez: https://tudominio.com/api/database_setup.php
 * Con reset: ?reset=true
 * 
 * Crea las tablas: jugadores, administradores, bancos_preguntas, preguntas, respuestas, puntajes
 * Siembra: 1 admin, 1 banco activo, 50 preguntas mundialistas
 */
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
        $pdo->exec("DROP TABLE IF EXISTS administradores;");
        $pdo->exec("DROP TABLE IF EXISTS jugadores;");
        $pdo->exec("DROP TABLE IF EXISTS logins;");
        $pdo->exec("DROP TABLE IF EXISTS usuarios;");
        $pdo->exec("SET FOREIGN_KEY_CHECKS = 1;");
        echo "Tablas eliminadas.\n<br><br>";
    }

    echo "Creando tablas...\n<br>";

    // 1. Jugadores (registro simplificado: solo nombre + avatar)
    $pdo->exec("CREATE TABLE IF NOT EXISTS jugadores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        avatar VARCHAR(50) DEFAULT 'ball',
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'jugadores' ✅<br>";

    // 2. Administradores (login con contraseña)
    $pdo->exec("CREATE TABLE IF NOT EXISTS administradores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        correo VARCHAR(255) UNIQUE NOT NULL,
        contrasena VARCHAR(255) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'administradores' ✅<br>";

    // 3. Bancos de Preguntas
    $pdo->exec("CREATE TABLE IF NOT EXISTS bancos_preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        titulo VARCHAR(255) NOT NULL,
        is_active BOOLEAN DEFAULT TRUE NOT NULL,
        tiempo_por_pregunta INT DEFAULT 15 NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'bancos_preguntas' ✅<br>";

    // 4. Preguntas
    $pdo->exec("CREATE TABLE IF NOT EXISTS preguntas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        banco_id INT NOT NULL,
        texto_pregunta VARCHAR(1000) NOT NULL,
        creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (banco_id) REFERENCES bancos_preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'preguntas' ✅<br>";

    // 5. Respuestas
    $pdo->exec("CREATE TABLE IF NOT EXISTS respuestas (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pregunta_id INT NOT NULL,
        texto_respuesta VARCHAR(500) NOT NULL,
        es_correcta BOOLEAN DEFAULT FALSE NOT NULL,
        FOREIGN KEY (pregunta_id) REFERENCES preguntas(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'respuestas' ✅<br>";

    // 6. Puntajes
    $pdo->exec("CREATE TABLE IF NOT EXISTS puntajes (
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
    echo "- Tabla 'puntajes' ✅<br><br>";

    // ========== SEED DATA ==========

    // Seed admin if none exists
    $stmt = $pdo->query("SELECT COUNT(*) FROM administradores");
    if ($stmt->fetchColumn() == 0) {
        echo "Sembrando administrador...<br>";
        $pw = password_hash("admin", PASSWORD_BCRYPT);
        $pdo->prepare("INSERT INTO administradores (correo, contrasena, nombre) VALUES (?, ?, ?)")
            ->execute(['admin@admin.com', $pw, 'Administrador']);
        echo "- Admin: admin@admin.com / admin ✅<br>";
    }

    // Seed question bank if none exists
    $stmt = $pdo->query("SELECT COUNT(*) FROM bancos_preguntas");
    if ($stmt->fetchColumn() == 0) {
        echo "<br>Sembrando banco de preguntas mundialistas...<br>";

        $pdo->prepare("INSERT INTO bancos_preguntas (titulo, is_active, tiempo_por_pregunta) VALUES (?, ?, ?)")
            ->execute(['Mundial de Fútbol ⚽', 1, 15]);
        $banco_id = $pdo->lastInsertId();

        // Helper function to insert question + answers
        $insertQuestion = function($texto, $opciones) use ($pdo, $banco_id) {
            $pdo->prepare("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (?, ?)")
                ->execute([$banco_id, $texto]);
            $pid = $pdo->lastInsertId();
            foreach ($opciones as $op) {
                $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
                    ->execute([$pid, $op[0], $op[1] ? 1 : 0]);
            }
        };

        // === SECCIÓN 1: SELECCIÓN DE ECUADOR (1-20) ===

        $insertQuestion('¿En qué año participó Ecuador por primera vez en una Copa Mundial de la FIFA?', [
            ['1998', false], ['2002', true], ['2006', false], ['2010', false]
        ]);
        $insertQuestion('¿Quién anotó el primer gol de Ecuador en la historia de los Mundiales (Corea/Japón 2002)?', [
            ['Enner Valencia', false], ['Agustín Delgado', true], ['Edison Méndez', false], ['Iván Kaviedes', false]
        ]);
        $insertQuestion('¿Contra qué selección logró Ecuador su primera victoria en un Mundial (2002)?', [
            ['México', false], ['Italia', false], ['Croacia', true], ['Costa Rica', false]
        ]);
        $insertQuestion('En el Mundial de Alemania 2006, ¿hasta qué fase llegó la selección ecuatoriana?', [
            ['Fase de grupos', false], ['Octavos de final', true], ['Cuartos de final', false], ['Semifinales', false]
        ]);
        $insertQuestion('¿Quién fue el entrenador de Ecuador durante la campaña de Alemania 2006?', [
            ['Hernán Darío Gómez', true], ['Luis Fernando Suárez', false], ['Reinaldo Rueda', false], ['Gustavo Alfaro', false]
        ]);
        $insertQuestion('En Brasil 2014, ¿qué portero fue figura en el empate sin goles contra Francia?', [
            ['Alexander Domínguez', true], ['Máximo Banguera', false], ['Hernán Galíndez', false], ['José Francisco Cevallos', false]
        ]);
        $insertQuestion('¿Cuál es el máximo goleador de Ecuador en la historia de los Mundiales?', [
            ['Agustín Delgado', false], ['Enner Valencia', true], ['Edison Méndez', false], ['Christian Benítez', false]
        ]);
        $insertQuestion('En Catar 2022, Ecuador venció 2-0 al anfitrión en el partido inaugural. ¿Quién anotó los dos goles?', [
            ['Michael Estrada', false], ['Enner Valencia', true], ['Gonzalo Plata', false], ['Moisés Caicedo', false]
        ]);
        $insertQuestion('¿Qué jugador ecuatoriano ha disputado más partidos en Copas del Mundo?', [
            ['Iván Hurtado', true], ['Antonio Valencia', false], ['Enner Valencia', false], ['Édison Méndez', false]
        ]);
        $insertQuestion('¿Contra qué selección perdió Ecuador en los octavos de final de Alemania 2006?', [
            ['Alemania', false], ['Inglaterra', true], ['Portugal', false], ['Países Bajos', false]
        ]);
        $insertQuestion('¿Cuál fue el resultado del partido Ecuador vs. Honduras en Brasil 2014?', [
            ['1-0', false], ['2-1', true], ['3-1', false], ['0-0', false]
        ]);
        $insertQuestion('En el Mundial 2002, Ecuador enfrentó a Italia en fase de grupos. ¿Cómo terminó?', [
            ['0-2', true], ['1-1', false], ['0-1', false], ['2-0', false]
        ]);
        $insertQuestion('¿Qué jugador ecuatoriano fue amonestado en el primer minuto del partido contra Catar en 2022?', [
            ['Piero Hincapié', false], ['Félix Torres', false], ['Jhegson Méndez', true], ['Jackson Porozo', false]
        ]);
        $insertQuestion('¿Quién fue el capitán de Ecuador en su primer Mundial (2002)?', [
            ['Iván Hurtado', true], ['Agustín Delgado', false], ['Alex Aguinaga', false], ['Ulises de la Cruz', false]
        ]);
        $insertQuestion('En el Mundial 2006, Ecuador goleó 3-0 a Costa Rica. ¿Cuál de estos jugadores NO anotó?', [
            ['Agustín Delgado', false], ['Carlos Tenorio', false], ['Iván Kaviedes', true], ['Édison Méndez', false]
        ]);
        $insertQuestion('¿Cuál fue el resultado del partido entre Ecuador y Países Bajos en Catar 2022?', [
            ['1-0', false], ['1-1', true], ['2-1', false], ['0-0', false]
        ]);
        $insertQuestion('¿Qué jugador ecuatoriano recibió tarjeta roja contra Senegal en Catar 2022?', [
            ['Piero Hincapié', false], ['Moisés Caicedo', false], ['Jackson Porozo', true], ['Ángelo Preciado', false]
        ]);
        $insertQuestion('¿Quién es el jugador con más asistencias de Ecuador en Mundiales?', [
            ['Antonio Valencia', false], ['Edison Méndez', true], ['Christian Noboa', false], ['Ángel Mena', false]
        ]);
        $insertQuestion('¿En qué sede jugó Ecuador su primer partido mundialista en 2002?', [
            ['Sapporo', true], ['Yokohama', false], ['Niigata', false], ['Ibaraki', false]
        ]);
        $insertQuestion('¿Qué delantero ecuatoriano usó una máscara de Spider-Man al celebrar un gol en el Mundial 2006?', [
            ['Agustín Delgado', false], ['Carlos Tenorio', false], ['Iván Kaviedes', true], ['Cristian Lara', false]
        ]);

        // === SECCIÓN 2: PREGUNTAS GENERALES DEL MUNDIAL (21-50) ===

        $insertQuestion('¿Qué selección ha ganado más Copas del Mundo?', [
            ['Alemania', false], ['Italia', false], ['Argentina', false], ['Brasil', true]
        ]);
        $insertQuestion('¿Quién es el máximo goleador histórico de los Mundiales?', [
            ['Ronaldo (Brasil)', false], ['Pelé', false], ['Miroslav Klose', true], ['Lionel Messi', false]
        ]);
        $insertQuestion('¿En qué año se celebró el primer Mundial de fútbol?', [
            ['1928', false], ['1930', true], ['1934', false], ['1950', false]
        ]);
        $insertQuestion('¿Qué país fue campeón del Mundial de 1950, conocido por el "Maracanazo"?', [
            ['Brasil', false], ['Uruguay', true], ['Alemania', false], ['Argentina', false]
        ]);
        $insertQuestion('¿Quién es el jugador más joven en marcar un gol en un Mundial?', [
            ['Pelé', true], ['Lionel Messi', false], ['Kylian Mbappé', false], ['Gavi', false]
        ]);
        $insertQuestion('¿Qué selección perdió las finales de los Mundiales de 1974 y 1978 consecutivamente?', [
            ['Alemania Federal', false], ['Argentina', false], ['Países Bajos', true], ['Italia', false]
        ]);
        $insertQuestion('¿Cuál fue el resultado de la final del Mundial de 2014 entre Alemania y Argentina?', [
            ['1-0', false], ['2-1', false], ['1-1 (penales)', false], ['1-0 (prórroga, gol de Götze)', true]
        ]);
        $insertQuestion('¿Quién fue el máximo goleador del Mundial de 2002?', [
            ['Ronaldo (Brasil)', true], ['Miroslav Klose', false], ['Rivaldo', false], ['Hidetoshi Nakata', false]
        ]);
        $insertQuestion('¿Qué hecho histórico ocurrió en 1970 con Brasil al ganar su tercer título?', [
            ['Marcó el gol más rápido', false], ['Se quedó definitivamente con el trofeo Jules Rimet', true], ['Se negó a jugar la final', false], ['Primer Mundial televisado en color', false]
        ]);
        $insertQuestion('¿Cómo se llama el estadio que albergó la final del Mundial de Sudáfrica 2010?', [
            ['Soccer City', true], ['Ellis Park', false], ['Cape Town Stadium', false], ['Loftus Versfeld', false]
        ]);
        $insertQuestion('¿Qué jugador es recordado por la "Mano de Dios" en 1986?', [
            ['Diego Maradona', true], ['Gary Lineker', false], ['Lothar Matthäus', false], ['Michel Platini', false]
        ]);
        $insertQuestion('¿Qué selección africana llegó a cuartos de final en el Mundial de 2010?', [
            ['Nigeria', false], ['Camerún', false], ['Senegal', false], ['Ghana', true]
        ]);
        $insertQuestion('¿Qué jugador dio 5 asistencias en el Mundial de 1986, récord en un solo torneo?', [
            ['Diego Maradona', true], ['Pierre Littbarski', false], ['Gheorghe Hagi', false], ['Enzo Scifo', false]
        ]);
        $insertQuestion('¿Qué selección fue campeona del mundo en 1998 al vencer 3-0 a Brasil?', [
            ['Italia', false], ['Francia', true], ['Alemania', false], ['Argentina', false]
        ]);
        $insertQuestion('¿Quién fue el entrenador campeón del mundo con Alemania en 2014?', [
            ['Jürgen Klinsmann', false], ['Joachim Löw', true], ['Franz Beckenbauer', false], ['Hansi Flick', false]
        ]);
        $insertQuestion('¿Qué país ha organizado dos Copas del Mundo (1974 y 2006)?', [
            ['Italia', false], ['Francia', false], ['Alemania', true], ['México', false]
        ]);
        $insertQuestion('¿Qué jugador anotó un gol desde tiro libre contra Inglaterra en el Mundial 2002?', [
            ['Ronaldinho', true], ['David Beckham', false], ['Rivaldo', false], ['Roberto Carlos', false]
        ]);
        $insertQuestion('¿Qué selección ganó 9-0 a Corea del Sur en el Mundial de 1954?', [
            ['Yugoslavia', false], ['Hungría', true], ['Brasil', false], ['Alemania Federal', false]
        ]);
        $insertQuestion('¿En qué Mundial aparecieron por primera vez las tarjetas amarilla y roja?', [
            ['México 1970', true], ['Alemania 1974', false], ['Inglaterra 1966', false], ['Argentina 1978', false]
        ]);
        $insertQuestion('¿Cuáles Mundiales no se disputaron por la Segunda Guerra Mundial?', [
            ['1942', false], ['1946', false], ['1942 y 1946', true], ['1940', false]
        ]);
        $insertQuestion('¿Qué jugador marcó el gol del triunfo para España en la final de Sudáfrica 2010?', [
            ['Andrés Iniesta', true], ['Xavi Hernández', false], ['Cesc Fàbregas', false], ['Fernando Torres', false]
        ]);
        $insertQuestion('¿Qué arquero tiene el récord de más minutos sin recibir gol en un solo Mundial?', [
            ['Gianluigi Buffon (2006)', false], ['Iker Casillas (2010)', false], ['Walter Zenga (1990)', true], ['Fabien Barthez (1998)', false]
        ]);
        $insertQuestion('¿Qué selección fue campeona en el primer Mundial jugado en Asia (2002)?', [
            ['Corea del Sur', false], ['Japón', false], ['Brasil', true], ['Alemania', false]
        ]);
        $insertQuestion('¿Qué jugador recibió la tarjeta roja más rápida en la historia de los Mundiales?', [
            ['José Batista (Uruguay, 1986)', true], ['Gerardo Bedoya (Colombia)', false], ['Gianluigi Buffon (Italia)', false], ['Zinedine Zidane (Francia)', false]
        ]);
        $insertQuestion('¿Qué selección eliminó a Brasil en los cuartos de final de 2018?', [
            ['Francia', false], ['Bélgica', true], ['Croacia', false], ['Suecia', false]
        ]);
        $insertQuestion('¿Qué jugador tiene el récord de más partidos disputados en Mundiales (26)?', [
            ['Lothar Matthäus', false], ['Lionel Messi', true], ['Miroslav Klose', false], ['Cristiano Ronaldo', false]
        ]);
        $insertQuestion('¿Qué color de camiseta usó Alemania en la final de 2014 cuando ganó el título?', [
            ['Blanca', true], ['Verde', false], ['Negra', false], ['Roja', false]
        ]);
        $insertQuestion('¿Qué delantero neerlandés fue máximo goleador del Mundial 2010 con 5 goles?', [
            ['Arjen Robben', false], ['Robin van Persie', false], ['Wesley Sneijder', true], ['Dirk Kuyt', false]
        ]);
        $insertQuestion('¿En qué estadio se jugó la final de México 1986?', [
            ['Azteca', true], ['Jalisco', false], ['Universitario', false], ['Cuauhtémoc', false]
        ]);
        $insertQuestion('¿Qué selección ganó el Mundial de 1934 con un equipo de jugadores naturalizados?', [
            ['Italia', true], ['Hungría', false], ['Checoslovaquia', false], ['Austria', false]
        ]);

        $total = $pdo->query("SELECT COUNT(*) FROM preguntas WHERE banco_id = $banco_id")->fetchColumn();
        echo "- Banco '$banco_id' creado con $total preguntas ✅<br>";
    }

    echo "<br><h3 style='color:green'>¡Base de datos inicializada correctamente! ✅</h3>";
    echo "<p>Tablas: jugadores, administradores, bancos_preguntas, preguntas, respuestas, puntajes</p>";

} catch (PDOException $e) {
    echo "<h3 style='color:red'>Error:</h3> " . $e->getMessage();
}
?>
