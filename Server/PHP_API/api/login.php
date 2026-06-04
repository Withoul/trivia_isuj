<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/jwt.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido", "message" => "Utiliza POST para iniciar sesión."]);
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
    // Find user
    $stmt = $pdo->prepare("SELECT id, correo, contrasena, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, institucion, cedula, telefono, tipo_perfil, creado_en FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($contrasena, $user['contrasena'])) {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado", "message" => "Correo o contraseña incorrectos."]);
        exit();
    }

    // Generate JWT token
    $payload = [
        "sub" => $user['correo'],
        "id" => $user['id'],
        "exp" => time() + (60 * 30) // Expires in 30 minutes like Python ACCESS_TOKEN_EXPIRE_MINUTES
    ];
    $token = JWT::encode($payload);

    // Save token in logins table
    $expira_en = date('Y-m-d H:i:s', $payload['exp']);
    $stmt = $pdo->prepare("INSERT INTO logins (usuario_id, token, expira_en) VALUES (?, ?, ?)");
    $stmt->execute([$user['id'], $token, $expira_en]);

    // Clean user password before returning
    unset($user['contrasena']);

    http_response_code(200);
    echo json_encode([
        "access_token" => $token,
        "token_type" => "bearer",
        "usuario" => $user
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error interno", "message" => $e->getMessage()]);
}
?>
