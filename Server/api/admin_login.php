<?php
/**
 * API: Admin Login
 * POST /api/admin_login.php
 * Body: { "correo": "admin@admin.com", "contrasena": "admin" }
 * Response: { "id": 1, "correo": "...", "nombre": "..." }
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['correo']) || empty($data['contrasena'])) {
    http_response_code(400);
    echo json_encode(["error" => "Credenciales incompletas", "message" => "Proporcione correo y contraseña."]);
    exit();
}

$correo = trim($data['correo']);
$contrasena = $data['contrasena'];

try {
    $stmt = $pdo->prepare("SELECT id, correo, contrasena, nombre FROM administradores WHERE correo = ?");
    $stmt->execute([$correo]);
    $admin = $stmt->fetch();

    if (!$admin || !password_verify($contrasena, $admin['contrasena'])) {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado", "message" => "Correo o contraseña incorrectos."]);
        exit();
    }

    unset($admin['contrasena']);

    http_response_code(200);
    echo json_encode($admin);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error interno", "message" => $e->getMessage()]);
}
?>
