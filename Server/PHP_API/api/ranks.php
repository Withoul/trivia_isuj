<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/jwt.php';

$db = new Database();
$pdo = $db->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["error" => "Método no permitido", "message" => "Utiliza GET para rankings."]);
    exit();
}

// Authenticate JWT Token
JWT::authenticate();

try {
    // Get real rankings from DB
    $query = "SELECT 
                u.id as usuario_id, 
                u.primer_nombre, 
                u.primer_apellido, 
                u.correo, 
                u.institucion, 
                COALESCE(SUM(p.puntaje_neto), 0) as puntaje_acumulado
              FROM usuarios u
              LEFT JOIN puntajes p ON p.usuario_id = u.id
              WHERE u.tipo_perfil = 'JUGADOR'
              GROUP BY u.id
              ORDER BY puntaje_acumulado DESC";
              
    $stmt = $pdo->query($query);
    $real_ranks = $stmt->fetchAll();

    $rankings = [];
    foreach ($real_ranks as $idx => $r) {
        $rankings[] = [
            "usuario_id" => (int) $r['usuario_id'],
            "primer_nombre" => $r['primer_nombre'],
            "primer_apellido" => $r['primer_apellido'] ? $r['primer_apellido'] : "",
            "correo" => $r['correo'],
            "institucion" => $r['institucion'] ? $r['institucion'] : "",
            "puntaje_acumulado" => (int) $r['puntaje_acumulado'],
            "accuracy" => 78 // Default mock accuracy
        ];
    }

    // Mock profiles to populate the leaderboard visual mock podium
    $mock_users = [
        ["usuario_id" => 9991, "primer_nombre" => "Andrea", "primer_apellido" => "R.", "correo" => "andrea@ujapon.edu.ec", "institucion" => "Ingeniería Comercial", "puntaje_acumulado" => 15850, "accuracy" => 96],
        ["usuario_id" => 9992, "primer_nombre" => "Carlos", "primer_apellido" => "M.", "correo" => "carlos@ujapon.edu.ec", "institucion" => "Administración", "puntaje_acumulado" => 14200, "accuracy" => 94],
        ["usuario_id" => 9993, "primer_nombre" => "Luis", "primer_apellido" => "G.", "correo" => "luis@ujapon.edu.ec", "institucion" => "Diseño Gráfico", "puntaje_acumulado" => 13900, "accuracy" => 91],
        ["usuario_id" => 9994, "primer_nombre" => "Miguel", "primer_apellido" => "Torres", "correo" => "miguel@ujapon.edu.ec", "institucion" => "Derecho", "puntaje_acumulado" => 12400, "accuracy" => 92],
        ["usuario_id" => 9995, "primer_nombre" => "Sofia", "primer_apellido" => "Ruiz", "correo" => "sofia@ujapon.edu.ec", "institucion" => "Medicina", "puntaje_acumulado" => 11850, "accuracy" => 89],
        ["usuario_id" => 9996, "primer_nombre" => "Paula", "primer_apellido" => "N.", "correo" => "paula@ujapon.edu.ec", "institucion" => "Marketing", "puntaje_acumulado" => 8100, "accuracy" => 75],
    ];

    // Combine real and mock users without duplicate first names
    $combined = $rankings;
    foreach ($mock_users as $mu) {
        $exists = false;
        foreach ($rankings as $rk) {
            if ($rk['primer_nombre'] === $mu['primer_nombre']) {
                $exists = true;
                break;
            }
        }
        if (!$exists) {
            $combined[] = $mu;
        }
    }

    // Sort by points descending
    usort($combined, function($a, $b) {
        return $b['puntaje_acumulado'] - $a['puntaje_acumulado'];
    });

    // Update index specific accuracies for visual aesthetics
    foreach ($combined as $idx => &$user) {
        if ($user['usuario_id'] !== 9991 && $user['usuario_id'] !== 9992 && $user['usuario_id'] !== 9993) {
            $user['accuracy'] = max(60, 80 - $idx * 2);
        }
    }

    http_response_code(200);
    echo json_encode($combined);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
