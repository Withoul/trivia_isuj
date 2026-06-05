<?php
/**
 * API: Scores
 * POST /api/scores.php — Submit a score
 * Body: { "jugador_id": 1, "banco_id": 1, "puntaje_neto": 850, "racha_maxima": 5, "correctas": 8, "total_preguntas": 10 }
 * Response: { "id": 1, ... }
 * 
 * GET /api/scores.php?jugador_id=1 — Get scores for a player (optional)
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method === 'POST') {
        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['jugador_id']) || empty($data['banco_id']) || !isset($data['puntaje_neto'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "Faltan jugador_id, banco_id o puntaje_neto."]);
            exit();
        }

        $jugador_id = (int)$data['jugador_id'];
        $banco_id = (int)$data['banco_id'];
        $puntaje_neto = (int)$data['puntaje_neto'];
        $racha_maxima = isset($data['racha_maxima']) ? (int)$data['racha_maxima'] : 0;
        $correctas = isset($data['correctas']) ? (int)$data['correctas'] : 0;
        $total_preguntas = isset($data['total_preguntas']) ? (int)$data['total_preguntas'] : 0;

        $stmt = $pdo->prepare("INSERT INTO puntajes (jugador_id, banco_id, puntaje_neto, racha_maxima, correctas, total_preguntas) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$jugador_id, $banco_id, $puntaje_neto, $racha_maxima, $correctas, $total_preguntas]);

        $id = $pdo->lastInsertId();

        $stmt = $pdo->prepare("SELECT * FROM puntajes WHERE id = ?");
        $stmt->execute([$id]);
        $score = $stmt->fetch();

        http_response_code(201);
        echo json_encode($score);
        exit();
    }

    if ($method === 'GET') {
        $jugador_id = isset($_GET['jugador_id']) ? (int)$_GET['jugador_id'] : 0;

        if ($jugador_id > 0) {
            $stmt = $pdo->prepare("SELECT * FROM puntajes WHERE jugador_id = ? ORDER BY completado_en DESC");
            $stmt->execute([$jugador_id]);
        } else {
            $stmt = $pdo->query("SELECT * FROM puntajes ORDER BY puntaje_neto DESC LIMIT 100");
        }

        http_response_code(200);
        echo json_encode($stmt->fetchAll());
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
