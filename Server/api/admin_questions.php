<?php
/**
 * API: Admin Questions CRUD
 * GET    /api/admin_questions.php?bank_id=1&admin_id=1       — List questions for a bank
 * POST   /api/admin_questions.php?bank_id=1                   — Create question with answers
 *        Body: { admin_id, texto_pregunta, respuestas: [{ texto_respuesta, es_correcta }] }
 * PUT    /api/admin_questions.php?question_id=1                — Update question with answers
 *        Body: { admin_id, texto_pregunta, respuestas: [...] }
 * DELETE /api/admin_questions.php?question_id=1&admin_id=1     — Delete question
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

function verifyAdmin($pdo, $admin_id) {
    if (!$admin_id || $admin_id <= 0) return false;
    $stmt = $pdo->prepare("SELECT id FROM administradores WHERE id = ?");
    $stmt->execute([$admin_id]);
    return $stmt->fetch() ? true : false;
}

$method = $_SERVER['REQUEST_METHOD'];
$bank_id = isset($_GET['bank_id']) ? (int)$_GET['bank_id'] : 0;
$question_id = isset($_GET['question_id']) ? (int)$_GET['question_id'] : 0;

try {
    if ($method === 'GET') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        if ($bank_id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Falta bank_id"]);
            exit();
        }

        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE banco_id = ? ORDER BY id ASC");
        $stmt->execute([$bank_id]);
        $preguntas = $stmt->fetchAll();

        foreach ($preguntas as &$preg) {
            $stmt_r = $pdo->prepare("SELECT id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
            $stmt_r->execute([$preg['id']]);
            $resps = $stmt_r->fetchAll();
            foreach ($resps as &$r) {
                $r['es_correcta'] = (bool)$r['es_correcta'];
            }
            $preg['respuestas'] = $resps;
        }

        http_response_code(200);
        echo json_encode($preguntas);
        exit();
    }

    if ($method === 'POST') {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!verifyAdmin($pdo, $data['admin_id'] ?? 0)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        if ($bank_id <= 0 || empty($data['texto_pregunta']) || empty($data['respuestas'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "Falta bank_id, texto_pregunta o respuestas."]);
            exit();
        }

        $texto = trim($data['texto_pregunta']);
        $stmt = $pdo->prepare("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (?, ?)");
        $stmt->execute([$bank_id, $texto]);
        $new_id = $pdo->lastInsertId();

        foreach ($data['respuestas'] as $resp) {
            $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
                ->execute([$new_id, trim($resp['texto_respuesta']), $resp['es_correcta'] ? 1 : 0]);
        }

        // Return created question
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE id = ?");
        $stmt->execute([$new_id]);
        $question = $stmt->fetch();

        $stmt_r = $pdo->prepare("SELECT id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
        $stmt_r->execute([$new_id]);
        $resps = $stmt_r->fetchAll();
        foreach ($resps as &$r) { $r['es_correcta'] = (bool)$r['es_correcta']; }
        $question['respuestas'] = $resps;

        http_response_code(201);
        echo json_encode($question);
        exit();
    }

    if ($method === 'PUT') {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!verifyAdmin($pdo, $data['admin_id'] ?? 0)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        if ($question_id <= 0 || empty($data['texto_pregunta']) || empty($data['respuestas'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos"]);
            exit();
        }

        $texto = trim($data['texto_pregunta']);
        $pdo->prepare("UPDATE preguntas SET texto_pregunta = ? WHERE id = ?")->execute([$texto, $question_id]);

        // Delete old answers and insert new ones
        $pdo->prepare("DELETE FROM respuestas WHERE pregunta_id = ?")->execute([$question_id]);
        foreach ($data['respuestas'] as $resp) {
            $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)")
                ->execute([$question_id, trim($resp['texto_respuesta']), $resp['es_correcta'] ? 1 : 0]);
        }

        // Return updated question
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE id = ?");
        $stmt->execute([$question_id]);
        $question = $stmt->fetch();

        $stmt_r = $pdo->prepare("SELECT id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
        $stmt_r->execute([$question_id]);
        $resps = $stmt_r->fetchAll();
        foreach ($resps as &$r) { $r['es_correcta'] = (bool)$r['es_correcta']; }
        $question['respuestas'] = $resps;

        http_response_code(200);
        echo json_encode($question);
        exit();
    }

    if ($method === 'DELETE') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id) || $question_id <= 0) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado o ID inválido"]);
            exit();
        }

        $pdo->prepare("DELETE FROM preguntas WHERE id = ?")->execute([$question_id]);
        http_response_code(200);
        echo json_encode(["detail" => "Pregunta eliminada"]);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
