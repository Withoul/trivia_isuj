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
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

try {
    if ($method === 'GET') {
        // --- 1. LIST USERS ---
        $stmt = $pdo->query("SELECT id, correo, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, institucion, cedula, telefono, tipo_perfil, creado_en FROM usuarios");
        $users = $stmt->fetchAll();
        
        http_response_code(200);
        echo json_encode($users);
        exit();
    }

    if ($method === 'PUT') {
        // --- 2. UPDATE USER DETAILS OR ROLE ---
        if ($id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Parámetro inválido", "message" => "Falta ID de usuario."]);
            exit();
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if (
            empty($data['correo']) ||
            empty($data['primer_nombre']) ||
            empty($data['primer_apellido']) ||
            empty($data['institucion']) ||
            empty($data['tipo_perfil'])
        ) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "Llene los campos obligatorios."]);
            exit();
        }

        // Verify user exists
        $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(["error" => "No encontrado", "message" => "El usuario no existe."]);
            exit();
        }

        $correo = trim($data['correo']);
        $primer_nombre = trim($data['primer_nombre']);
        $segundo_nombre = isset($data['segundo_nombre']) ? trim($data['segundo_nombre']) : null;
        $primer_apellido = trim($data['primer_apellido']);
        $segundo_apellido = isset($data['segundo_apellido']) ? trim($data['segundo_apellido']) : null;
        $institucion = trim($data['institucion']);
        $cedula = isset($data['cedula']) ? trim($data['cedula']) : null;
        $telefono = isset($data['telefono']) ? trim($data['telefono']) : null;
        $tipo_perfil = trim($data['tipo_perfil']);

        $query = "UPDATE usuarios 
                  SET correo = ?, primer_nombre = ?, segundo_nombre = ?, primer_apellido = ?, segundo_apellido = ?, institucion = ?, cedula = ?, telefono = ?, tipo_perfil = ? 
                  WHERE id = ?";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([
            $correo, 
            $primer_nombre, 
            $segundo_nombre, 
            $primer_apellido, 
            $segundo_apellido, 
            $institucion, 
            $cedula, 
            $telefono, 
            $tipo_perfil,
            $id
        ]);

        $stmt = $pdo->prepare("SELECT id, correo, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, institucion, cedula, telefono, tipo_perfil, creado_en FROM usuarios WHERE id = ?");
        $stmt->execute([$id]);
        $updated_user = $stmt->fetch();

        http_response_code(200);
        echo json_encode($updated_user);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
