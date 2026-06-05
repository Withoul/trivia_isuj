<?php
/**
 * API: Questions (Public)
 * GET /api/questions.php?bank_id=1 — Returns questions with answers for a bank
 * GET /api/questions.php?bank_id=1&random=10 — Returns N random questions
 * Response: [{ "id": 1, "texto_pregunta": "...", "respuestas": [...] }]
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);
    exit();
}

$bank_id = isset($_GET['bank_id']) ? (int)$_GET['bank_id'] : 0;
$random_count = isset($_GET['random']) ? (int)$_GET['random'] : 0;

if ($bank_id <= 0) {
    http_response_code(400);
    echo json_encode(["error" => "Parámetro inválido", "message" => "Falta bank_id."]);
    exit();
}

try {
    // Verify bank exists
    $stmt = $pdo->prepare("SELECT id, tiempo_por_pregunta FROM bancos_preguntas WHERE id = ?");
    $stmt->execute([$bank_id]);
    $bank = $stmt->fetch();
    if (!$bank) {
        http_response_code(404);
        echo json_encode(["error" => "No encontrado", "message" => "El banco de preguntas no existe."]);
        exit();
    }

    // Fetch questions (random or all)
    if ($random_count > 0) {
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta FROM preguntas WHERE banco_id = ? ORDER BY RAND() LIMIT " . $random_count);
        $stmt->execute([$bank_id]);
    } else {
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta FROM preguntas WHERE banco_id = ? ORDER BY RAND()");
        $stmt->execute([$bank_id]);
    }
    $preguntas = $stmt->fetchAll();

    // Fetch answers for each question and shuffle them
    foreach ($preguntas as &$preg) {
        $stmt_resp = $pdo->prepare("SELECT id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ? ORDER BY RAND()");
        $stmt_resp->execute([$preg['id']]);
        $respuestas = $stmt_resp->fetchAll();
        foreach ($respuestas as &$r) {
            $r['es_correcta'] = (bool)$r['es_correcta'];
        }
        $preg['respuestas'] = $respuestas;
    }

    http_response_code(200);
    echo json_encode([
        "tiempo_por_pregunta" => (int)$bank['tiempo_por_pregunta'],
        "preguntas" => $preguntas
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
