<?php
/**
 * API: Admin Users
 * GET /api/admin_users.php?admin_id=1 — List all players (jugadores) and their stats
 * DELETE /api/admin_users.php?id=5&admin_id=1 — Delete a player
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
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

try {
    if ($method === 'GET') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            exit();
        }

        $query = "SELECT 
                    j.id, j.nombre, j.avatar, j.creado_en,
                    COALESCE(SUM(p.puntaje_neto), 0) as puntaje_total,
                    COUNT(p.id) as partidas,
                    COALESCE(MAX(p.racha_maxima), 0) as mejor_racha
                  FROM jugadores j
                  LEFT JOIN puntajes p ON p.jugador_id = j.id
                  GROUP BY j.id
                  ORDER BY j.creado_en DESC";

        $stmt = $pdo->query($query);
        $users = $stmt->fetchAll();

        foreach ($users as &$u) {
            $u['id'] = (int)$u['id'];
            $u['puntaje_total'] = (int)$u['puntaje_total'];
            $u['partidas'] = (int)$u['partidas'];
            $u['mejor_racha'] = (int)$u['mejor_racha'];
        }

        http_response_code(200);
        echo json_encode($users);
        exit();
    }

    if ($method === 'DELETE') {
        $admin_id = isset($_GET['admin_id']) ? (int)$_GET['admin_id'] : 0;
        if (!verifyAdmin($pdo, $admin_id) || $id <= 0) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado o ID inválido"]);
            exit();
        }

        $pdo->prepare("DELETE FROM jugadores WHERE id = ?")->execute([$id]);
        http_response_code(200);
        echo json_encode(["detail" => "Jugador eliminado"]);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
