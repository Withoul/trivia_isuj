<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/jwt.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido", "message" => "Utiliza GET para consultar tu perfil."]);
    exit();
}

// Authenticate JWT Token
$payload = JWT::authenticate();
$correo = $payload['sub'];

try {
    // Find user
    $stmt = $pdo->prepare("SELECT id, correo, primer_nombre, primer_apellido, institucion, cedula, telefono, tipo_perfil FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(["error" => "Usuario no encontrado", "message" => "El usuario asociado al token no existe."]);
        exit();
    }

    // Calculate real stats from the database
    // Total Score
    $stmt = $pdo->prepare("SELECT SUM(puntaje_neto) FROM puntajes WHERE usuario_id = ?");
    $stmt->execute([$user['id']]);
    $total_score = (int) $stmt->fetchColumn();

    // Completed unique quizzes
    $stmt = $pdo->prepare("SELECT COUNT(DISTINCT banco_id) FROM puntajes WHERE usuario_id = ?");
    $stmt->execute([$user['id']]);
    $quizzes_completed = (int) $stmt->fetchColumn();

    http_response_code(200);
    echo json_encode([
        "id" => (int) $user['id'],
        "correo" => $user['correo'],
        "primer_nombre" => $user['primer_nombre'],
        "primer_apellido" => $user['primer_apellido'],
        "institucion" => $user['institucion'],
        "cedula" => $user['cedula'],
        "telefono" => $user['telefono'],
        "tipo_perfil" => $user['tipo_perfil'],
        "puntaje_total" => $total_score,
        "quizzes_completados" => $quizzes_completed,
        "racha_maxima" => 0 // Fallback default
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error interno", "message" => $e->getMessage()]);
}
?>
