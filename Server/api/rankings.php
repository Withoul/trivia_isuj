<?php
/**
 * API: Rankings (Public)
 * GET /api/rankings.php — Global leaderboard
 * GET /api/rankings.php?limit=20 — Top N players
 * Response: [{ "jugador_id": 1, "nombre": "...", "avatar": "ball", "puntaje_total": 2500, "mejor_racha": 5, "partidas": 3 }]
 */
require_once __DIR__ . '/config/database.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);
    exit();
}

$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
if ($limit <= 0 || $limit > 200) $limit = 50;

try {
    $query = "SELECT 
                j.id as jugador_id,
                j.nombre,
                j.avatar,
                COALESCE(SUM(p.puntaje_neto), 0) as puntaje_total,
                COALESCE(MAX(p.racha_maxima), 0) as mejor_racha,
                COUNT(p.id) as partidas,
                COALESCE(SUM(p.correctas), 0) as total_correctas,
                COALESCE(SUM(p.total_preguntas), 0) as total_preguntas_jugadas
              FROM jugadores j
              LEFT JOIN puntajes p ON p.jugador_id = j.id
              GROUP BY j.id
              HAVING puntaje_total > 0
              ORDER BY puntaje_total DESC
              LIMIT ?";

    $stmt = $pdo->prepare($query);
    $stmt->execute([$limit]);
    $rankings = $stmt->fetchAll();

    // Calculate accuracy percentage
    foreach ($rankings as &$r) {
        $r['jugador_id'] = (int)$r['jugador_id'];
        $r['puntaje_total'] = (int)$r['puntaje_total'];
        $r['mejor_racha'] = (int)$r['mejor_racha'];
        $r['partidas'] = (int)$r['partidas'];
        $total_q = (int)$r['total_preguntas_jugadas'];
        $total_c = (int)$r['total_correctas'];
        $r['precision'] = $total_q > 0 ? round(($total_c / $total_q) * 100) : 0;
        unset($r['total_correctas'], $r['total_preguntas_jugadas']);
    }

    http_response_code(200);
    echo json_encode($rankings);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
