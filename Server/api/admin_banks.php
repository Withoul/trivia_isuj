<?php
/**
 * API: Admin Banks CRUD
 * GET    /api/admin_banks.php?admin_id=1           — List ALL banks (active + inactive)
 * POST   /api/admin_banks.php                      — Create bank { admin_id, titulo, tiempo_por_pregunta }
 * PUT    /api/admin_banks.php?id=1                  — Update bank { admin_id, titulo, is_active, tiempo_por_pregunta }
 * DELETE /api/admin_banks.php?id=1&admin_id=1       — Delete bank
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

// Verify admin exists
function verifyAdmin($pdo, $admin_id) {
    if (!$admin_id || $admin_id <= 0) return false;
    $stmt = $pdo->prepare("SELECT id FROM administradores WHERE id = ?");
    $stmt->execute([$admin_id]);
    return $stmt->fetch() ? true : false;
}

$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

try {
    if ($method === 'GET') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        $stmt = $pdo->query("SELECT id, titulo, is_active, tiempo_por_pregunta, creado_en FROM bancos_preguntas ORDER BY creado_en DESC");
        $banks = $stmt->fetchAll();

        foreach ($banks as &$b) {
            $b['is_active'] = (bool)$b['is_active'];
            $b['tiempo_por_pregunta'] = (int)$b['tiempo_por_pregunta'];
            $cnt = $pdo->prepare("SELECT COUNT(*) FROM preguntas WHERE banco_id = ?");
            $cnt->execute([$b['id']]);
            $b['total_preguntas'] = (int)$cnt->fetchColumn();
        }

        http_response_code(200);
        echo json_encode($banks);
        exit();
    }

    if ($method === 'POST') {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!verifyAdmin($pdo, $data['admin_id'] ?? 0)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }
        if (empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["error" => "Título requerido"]);
            exit();
        }

        $titulo = trim($data['titulo']);
        $is_active = isset($data['is_active']) ? (int)$data['is_active'] : 1;
        $tiempo = isset($data['tiempo_por_pregunta']) ? (int)$data['tiempo_por_pregunta'] : 15;

        $stmt = $pdo->prepare("INSERT INTO bancos_preguntas (titulo, is_active, tiempo_por_pregunta) VALUES (?, ?, ?)");
        $stmt->execute([$titulo, $is_active, $tiempo]);
        $new_id = $pdo->lastInsertId();

        $stmt = $pdo->prepare("SELECT * FROM bancos_preguntas WHERE id = ?");
        $stmt->execute([$new_id]);
        $bank = $stmt->fetch();
        $bank['is_active'] = (bool)$bank['is_active'];

        http_response_code(201);
        echo json_encode($bank);
        exit();
    }

    if ($method === 'PUT') {
        if ($id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Falta ID del banco"]);
            exit();
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if (!verifyAdmin($pdo, $data['admin_id'] ?? 0)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        $titulo = trim($data['titulo'] ?? '');
        $is_active = isset($data['is_active']) ? (int)$data['is_active'] : 1;
        $tiempo = isset($data['tiempo_por_pregunta']) ? (int)$data['tiempo_por_pregunta'] : 15;

        $stmt = $pdo->prepare("UPDATE bancos_preguntas SET titulo = ?, is_active = ?, tiempo_por_pregunta = ? WHERE id = ?");
        $stmt->execute([$titulo, $is_active, $tiempo, $id]);

        $stmt = $pdo->prepare("SELECT * FROM bancos_preguntas WHERE id = ?");
        $stmt->execute([$id]);
        $bank = $stmt->fetch();
        $bank['is_active'] = (bool)$bank['is_active'];

        http_response_code(200);
        echo json_encode($bank);
        exit();
    }

    if ($method === 'DELETE') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id) || $id <= 0) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado o ID inválido"]);
            exit();
        }

        $pdo->prepare("DELETE FROM bancos_preguntas WHERE id = ?")->execute([$id]);
        http_response_code(200);
        echo json_encode(["detail" => "Banco eliminado"]);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
