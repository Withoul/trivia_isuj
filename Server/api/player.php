<?php
/**
 * API: Player Registration
 * POST /api/player.php
 * Body: { "nombre": "MiNombre", "avatar": "ball" }
 * Response: { "id": 1, "nombre": "MiNombre", "avatar": "ball" }
 * 
 * No authentication required. Creates a new player with name + avatar.
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido", "message" => "Utiliza POST."]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['nombre'])) {
    http_response_code(400);
    echo json_encode(["error" => "Datos incompletos", "message" => "El nombre es obligatorio."]);
    exit();
}

$nombre = trim($data['nombre']);
$avatar = isset($data['avatar']) ? trim($data['avatar']) : 'ball';

try {
    $stmt = $pdo->prepare("INSERT INTO jugadores (nombre, avatar) VALUES (?, ?)");
    $stmt->execute([$nombre, $avatar]);
    $id = $pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        "id" => (int)$id,
        "nombre" => $nombre,
        "avatar" => $avatar
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
