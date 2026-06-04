<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/jwt.php';

$db = new Database();
$pdo = $db->getConnection();

// Authenticate JWT Token & verify administrator role
$payload = JWT::authenticate();
$user_id = $payload['id'];

$stmt = $pdo->prepare("SELECT tipo_perfil FROM usuarios WHERE id = ?");
$stmt->execute([$user_id]);
$role = $stmt->fetchColumn();

if ($role !== 'ADMINISTRADOR') {
    http_response_code(403);
    echo json_encode(["error" => "Prohibido", "message" => "Acceso restringido a administradores."]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
$bank_id = isset($_GET['bank_id']) ? (int)$_GET['bank_id'] : 0;
$question_id = isset($_GET['question_id']) ? (int)$_GET['question_id'] : 0;

if ($bank_id <= 0) {
    http_response_code(400);
    echo json_encode(["error" => "Parámetro inválido", "message" => "Falta bank_id."]);
    exit();
}

try {
    // Verify bank exists
    $stmt = $pdo->prepare("SELECT id FROM bancos_preguntas WHERE id = ?");
    $stmt->execute([$bank_id]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(["error" => "No encontrado", "message" => "El banco de preguntas especificado no existe."]);
        exit();
    }

    if ($method === 'POST') {
        // --- 1. CREATE QUESTION ---
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (empty($data['texto_pregunta']) || empty($data['respuestas']) || !is_array($data['respuestas'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "El enunciado y las alternativas son obligatorios."]);
            exit();
        }

        $texto_pregunta = trim($data['texto_pregunta']);
        
        // Insert question statement
        $stmt = $pdo->prepare("INSERT INTO preguntas (banco_id, texto_pregunta) VALUES (?, ?)");
        $stmt->execute([$bank_id, $texto_pregunta]);
        $new_question_id = $pdo->lastInsertId();

        // Insert answers alternatives
        foreach ($data['respuestas'] as $resp) {
            $texto_resp = trim($resp['texto_respuesta']);
            $es_correcta = isset($resp['es_correcta']) && $resp['es_correcta'] ? 1 : 0;
            
            $stmt_resp = $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)");
            $stmt_resp->execute([$new_question_id, $texto_resp, $es_correcta]);
        }

        // Return final question payload
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE id = ?");
        $stmt->execute([$new_question_id]);
        $question = $stmt->fetch();

        $stmt_resp = $pdo->prepare("SELECT id, pregunta_id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
        $stmt_resp->execute([$new_question_id]);
        $respuestas = $stmt_resp->fetchAll();
        
        foreach ($respuestas as &$r) {
            $r['es_correcta'] = (bool)$r['es_correcta'];
        }
        $question['respuestas'] = $respuestas;

        http_response_code(201);
        echo json_encode($question);
        exit();
    }

    if ($method === 'PUT') {
        // --- 2. UPDATE QUESTION ---
        if ($question_id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Parámetro inválido", "message" => "Falta question_id."]);
            exit();
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if (empty($data['texto_pregunta']) || empty($data['respuestas']) || !is_array($data['respuestas'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "El enunciado y las alternativas son obligatorios."]);
            exit();
        }

        // Verify question exists in this bank
        $stmt = $pdo->prepare("SELECT id FROM preguntas WHERE id = ? AND banco_id = ?");
        $stmt->execute([$question_id, $bank_id]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(["error" => "No encontrado", "message" => "La pregunta no existe en este banco."]);
            exit();
        }

        $texto_pregunta = trim($data['texto_pregunta']);

        // Update statement
        $stmt = $pdo->prepare("UPDATE preguntas SET texto_pregunta = ? WHERE id = ?");
        $stmt->execute([$texto_pregunta, $question_id]);

        // Delete old answers
        $pdo->prepare("DELETE FROM respuestas WHERE pregunta_id = ?")->execute([$question_id]);

        // Insert new answers
        foreach ($data['respuestas'] as $resp) {
            $texto_resp = trim($resp['texto_respuesta']);
            $es_correcta = isset($resp['es_correcta']) && $resp['es_correcta'] ? 1 : 0;
            
            $stmt_resp = $pdo->prepare("INSERT INTO respuestas (pregunta_id, texto_respuesta, es_correcta) VALUES (?, ?, ?)");
            $stmt_resp->execute([$question_id, $texto_resp, $es_correcta]);
        }

        // Return updated question payload
        $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE id = ?");
        $stmt->execute([$question_id]);
        $question = $stmt->fetch();

        $stmt_resp = $pdo->prepare("SELECT id, pregunta_id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
        $stmt_resp->execute([$question_id]);
        $respuestas = $stmt_resp->fetchAll();
        
        foreach ($respuestas as &$r) {
            $r['es_correcta'] = (bool)$r['es_correcta'];
        }
        $question['respuestas'] = $respuestas;

        http_response_code(200);
        echo json_encode($question);
        exit();
    }

    if ($method === 'DELETE') {
        // --- 3. DELETE QUESTION ---
        if ($question_id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Parámetro inválido", "message" => "Falta question_id."]);
            exit();
        }

        // Verify question exists
        $stmt = $pdo->prepare("SELECT id FROM preguntas WHERE id = ? AND banco_id = ?");
        $stmt->execute([$question_id, $bank_id]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(["error" => "No encontrado", "message" => "La pregunta no existe en este banco."]);
            exit();
        }

        $stmt = $pdo->prepare("DELETE FROM preguntas WHERE id = ?");
        $stmt->execute([$question_id]);

        http_response_code(200);
        echo json_encode(["detail" => "Pregunta eliminada correctamente"]);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
