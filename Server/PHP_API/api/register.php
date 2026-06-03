<?php
require_once __DIR__ . '/../config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido", "message" => "Utiliza POST para registrarse."]);
    exit();
}

// Get posted data
$data = json_decode(file_get_contents("php://input"), true);

if (
    empty($data['correo']) ||
    empty($data['contrasena']) ||
    empty($data['primer_nombre']) ||
    empty($data['primer_apellido']) ||
    empty($data['institucion'])
) {
    http_response_code(400);
    echo json_encode(["error" => "Datos incompletos", "message" => "Completa todos los campos obligatorios."]);
    exit();
}

$correo = trim($data['correo']);
$contrasena = $data['contrasena'];
$primer_nombre = trim($data['primer_nombre']);
$segundo_nombre = isset($data['segundo_nombre']) ? trim($data['segundo_nombre']) : null;
$primer_apellido = trim($data['primer_apellido']);
$segundo_apellido = isset($data['segundo_apellido']) ? trim($data['segundo_apellido']) : null;
$institucion = trim($data['institucion']);
$cedula = isset($data['cedula']) ? trim($data['cedula']) : null;
$telefono = isset($data['telefono']) ? trim($data['telefono']) : null;
$tipo_perfil = isset($data['tipo_perfil']) ? trim($data['tipo_perfil']) : 'JUGADOR';

try {
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE correo = ?");
    $stmt->execute([$correo]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["error" => "Correo duplicado", "message" => "El correo electrónico ya está registrado."]);
        exit();
    }

    // Hash password
    $hashed_pw = password_hash($contrasena, PASSWORD_BCRYPT);

    // Insert user
    $query = "INSERT INTO usuarios 
              (correo, contrasena, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, institucion, cedula, telefono, tipo_perfil) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([
        $correo, 
        $hashed_pw, 
        $primer_nombre, 
        $segundo_nombre, 
        $primer_apellido, 
        $segundo_apellido, 
        $institucion, 
        $cedula, 
        $telefono, 
        $tipo_perfil
    ]);

    $new_user_id = $pdo->lastInsertId();

    // Fetch and return the newly created user without password
    $stmt = $pdo->prepare("SELECT id, correo, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, institucion, cedula, telefono, tipo_perfil, creado_en FROM usuarios WHERE id = ?");
    $stmt->execute([$new_user_id]);
    $user = $stmt->fetch();

    http_response_code(201);
    echo json_encode($user);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error interno", "message" => $e->getMessage()]);
}
?>
