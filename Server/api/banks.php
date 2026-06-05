<?php
/**
 * API: Banks (Public)
 * GET /api/banks.php — Returns all active question banks
 * Response: [{ "id": 1, "titulo": "...", "is_active": true, "tiempo_por_pregunta": 15 }]
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);
    exit();
}

try {
    $stmt = $pdo->query("SELECT id, titulo, is_active, tiempo_por_pregunta, creado_en FROM bancos_preguntas WHERE is_active = 1 ORDER BY creado_en DESC");
    $banks = $stmt->fetchAll();

    foreach ($banks as &$b) {
        $b['is_active'] = (bool)$b['is_active'];
        $b['tiempo_por_pregunta'] = (int)$b['tiempo_por_pregunta'];
        // Count questions
        $cnt = $pdo->prepare("SELECT COUNT(*) FROM preguntas WHERE banco_id = ?");
        $cnt->execute([$b['id']]);
        $b['total_preguntas'] = (int)$cnt->fetchColumn();
    }

    http_response_code(200);
    echo json_encode($banks);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
