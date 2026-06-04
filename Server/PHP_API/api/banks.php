<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/jwt.php';

$db = new Database();
$pdo = $db->getConnection();

// Authenticate JWT Token
$payload = JWT::authenticate();
$user_id = $payload['id'];

// Get user role
$stmt = $pdo->prepare("SELECT tipo_perfil FROM usuarios WHERE id = ?");
$stmt->execute([$user_id]);
$role = $stmt->fetchColumn();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';
$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

try {
    if ($method === 'GET') {
        // --- 1. GET QUESTIONS TO PLAY ---
        if ($action === 'play') {
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(["error" => "Parámetro inválido", "message" => "Falta ID del banco."]);
                exit();
            }

            // Verify bank exists
            $stmt = $pdo->prepare("SELECT id FROM bancos_preguntas WHERE id = ?");
            $stmt->execute([$id]);
            if (!$stmt->fetch()) {
                http_response_code(404);
                echo json_encode(["error" => "No encontrado", "message" => "El banco de preguntas no existe."]);
                exit();
            }

            // Fetch questions
            $stmt = $pdo->prepare("SELECT id, banco_id, texto_pregunta, creado_en FROM preguntas WHERE banco_id = ?");
            $stmt->execute([$id]);
            $preguntas = $stmt->fetchAll();

            // Fetch answers for each question
            foreach ($preguntas as &$preg) {
                $stmt_resp = $pdo->prepare("SELECT id, pregunta_id, texto_respuesta, es_correcta FROM respuestas WHERE pregunta_id = ?");
                $stmt_resp->execute([$preg['id']]);
                $respuestas = $stmt_resp->fetchAll();
                
                // Map boolean type for correct answer
                foreach ($respuestas as &$r) {
                    $r['es_correcta'] = (bool)$r['es_correcta'];
                }
                
                $preg['respuestas'] = $respuestas;
            }

            http_response_code(200);
            echo json_encode($preguntas);
            exit();
        }

        // --- 2. GET BANKS LIST (PLAYER VS ADMIN) ---
        if ($role === 'ADMINISTRADOR') {
            $stmt = $pdo->query("SELECT id, titulo, is_active, tiempo_inicio, tiempo_fin, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente, creado_en FROM bancos_preguntas");
            $banks = $stmt->fetchAll();
            
            // Map boolean properties
            foreach ($banks as &$b) {
                $b['is_active'] = (bool)$b['is_active'];
                $b['es_permanente'] = (bool)$b['es_permanente'];
            }
        } else {
            // Player: Only Active Banks
            $now = date('Y-m-d H:i:s');
            // Fetch active
            $stmt = $pdo->prepare("SELECT id, titulo, is_active, tiempo_inicio, tiempo_fin, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente, creado_en FROM bancos_preguntas WHERE is_active = 1");
            $stmt->execute();
            $banks = $stmt->fetchAll();

            $active_banks = [];
            foreach ($banks as &$b) {
                $b['is_active'] = (bool)$b['is_active'];
                $b['es_permanente'] = (bool)$b['es_permanente'];

                $valid_start = true;
                $valid_end = true;

                if ($b['tiempo_inicio'] && $now < $b['tiempo_inicio']) {
                    $valid_start = false;
                }
                if ($b['tiempo_fin'] && $now > $b['tiempo_fin']) {
                    $valid_end = false;
                }

                if ($valid_start && $valid_end) {
                    $active_banks[] = $b;
                }
            }
            $banks = $active_banks;
        }

        http_response_code(200);
        echo json_encode($banks);
        exit();
    }

    if ($method === 'POST') {
        // --- 3. SUBMIT SCORE (PLAYER) ---
        if ($action === 'score') {
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(["error" => "Parámetro inválido", "message" => "Falta ID del banco."]);
                exit();
            }

            $data = json_decode(file_get_contents("php://input"), true);
            if (!isset($data['puntaje_neto'])) {
                http_response_code(400);
                echo json_encode(["error" => "Datos incompletos", "message" => "Falta puntaje_neto."]);
                exit();
            }

            $puntaje_neto = (int)$data['puntaje_neto'];

            $stmt = $pdo->prepare("INSERT INTO puntajes (usuario_id, banco_id, puntaje_neto) VALUES (?, ?, ?)");
            $stmt->execute([$user_id, $id, $puntaje_neto]);
            
            $new_score_id = $pdo->lastInsertId();

            $stmt = $pdo->prepare("SELECT id, usuario_id, banco_id, puntaje_neto, completado_en FROM puntajes WHERE id = ?");
            $stmt->execute([$new_score_id]);
            $score_response = $stmt->fetch();

            http_response_code(201);
            echo json_encode($score_response);
            exit();
        }

        // --- 4. CREATE BANK (ADMIN ONLY) ---
        if ($role !== 'ADMINISTRADOR') {
            http_response_code(403);
            echo json_encode(["error" => "Prohibido", "message" => "Acceso restringido a administradores."]);
            exit();
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if (empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "El título del banco es requerido."]);
            exit();
        }

        $titulo = trim($data['titulo']);
        $is_active = isset($data['is_active']) ? (int)$data['is_active'] : 0;
        $es_permanente = isset($data['es_permanente']) ? (int)$data['es_permanente'] : 0;
        
        $tiempo_inicio = ($es_permanente === 1 || empty($data['tiempo_inicio'])) ? null : date('Y-m-d H:i:s', strtotime($data['tiempo_inicio']));
        $tiempo_fin = ($es_permanente === 1 || empty($data['tiempo_fin'])) ? null : date('Y-m-d H:i:s', strtotime($data['tiempo_fin']));
        
        $tiempo_por_pregunta = isset($data['tiempo_por_pregunta']) ? (int)$data['tiempo_por_pregunta'] : 12;
        $puntos_por_pregunta = isset($data['puntos_por_pregunta']) ? (int)$data['puntos_por_pregunta'] : 5;
        $color_banner = !empty($data['color_banner']) ? trim($data['color_banner']) : '#461F70';

        $query = "INSERT INTO bancos_preguntas 
                  (titulo, is_active, tiempo_inicio, tiempo_fin, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([
            $titulo,
            $is_active,
            $tiempo_inicio,
            $tiempo_fin,
            $tiempo_por_pregunta,
            $color_banner,
            $puntos_por_pregunta,
            $es_permanente
        ]);

        $new_bank_id = $pdo->lastInsertId();

        $stmt = $pdo->prepare("SELECT id, titulo, is_active, tiempo_inicio, tiempo_fin, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente FROM bancos_preguntas WHERE id = ?");
        $stmt->execute([$new_bank_id]);
        $new_bank = $stmt->fetch();
        
        $new_bank['is_active'] = (bool)$new_bank['is_active'];
        $new_bank['es_permanente'] = (bool)$new_bank['es_permanente'];

        http_response_code(201);
        echo json_encode($new_bank);
        exit();
    }

    if ($method === 'PUT') {
        // --- 5. UPDATE BANK (ADMIN ONLY) ---
        if ($role !== 'ADMINISTRADOR') {
            http_response_code(403);
            echo json_encode(["error" => "Prohibido", "message" => "Acceso restringido a administradores."]);
            exit();
        }

        if ($id <= 0) {
            http_response_code(400);
            echo json_encode(["error" => "Parámetro inválido", "message" => "Falta ID del banco a actualizar."]);
            exit();
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if (empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["error" => "Datos incompletos", "message" => "El título del banco es requerido."]);
            exit();
        }

        $titulo = trim($data['titulo']);
        $is_active = isset($data['is_active']) ? (int)$data['is_active'] : 0;
        $es_permanente = isset($data['es_permanente']) ? (int)$data['es_permanente'] : 0;
        
        $tiempo_inicio = ($es_permanente === 1 || empty($data['tiempo_inicio'])) ? null : date('Y-m-d H:i:s', strtotime($data['tiempo_inicio']));
        $tiempo_fin = ($es_permanente === 1 || empty($data['tiempo_fin'])) ? null : date('Y-m-d H:i:s', strtotime($data['tiempo_fin']));
        
        $tiempo_por_pregunta = isset($data['tiempo_por_pregunta']) ? (int)$data['tiempo_por_pregunta'] : 12;
        $puntos_por_pregunta = isset($data['puntos_por_pregunta']) ? (int)$data['puntos_por_pregunta'] : 5;
        $color_banner = !empty($data['color_banner']) ? trim($data['color_banner']) : '#461F70';

        // Check if bank exists
        $stmt = $pdo->prepare("SELECT id FROM bancos_preguntas WHERE id = ?");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(["error" => "No encontrado", "message" => "El banco de preguntas a editar no existe."]);
            exit();
        }

        $query = "UPDATE bancos_preguntas 
                  SET titulo = ?, is_active = ?, tiempo_inicio = ?, tiempo_fin = ?, tiempo_por_pregunta = ?, color_banner = ?, puntos_por_pregunta = ?, es_permanente = ? 
                  WHERE id = ?";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([
            $titulo,
            $is_active,
            $tiempo_inicio,
            $tiempo_fin,
            $tiempo_por_pregunta,
            $color_banner,
            $puntos_por_pregunta,
            $es_permanente,
            $id
        ]);

        $stmt = $pdo->prepare("SELECT id, titulo, is_active, tiempo_inicio, tiempo_fin, tiempo_por_pregunta, color_banner, puntos_por_pregunta, es_permanente FROM bancos_preguntas WHERE id = ?");
        $stmt->execute([$id]);
        $updated_bank = $stmt->fetch();
        
        $updated_bank['is_active'] = (bool)$updated_bank['is_active'];
        $updated_bank['es_permanente'] = (bool)$updated_bank['es_permanente'];

        http_response_code(200);
        echo json_encode($updated_bank);
        exit();
    }

    http_response_code(405);
    echo json_encode(["error" => "Método no permitido"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error de base de datos", "message" => $e->getMessage()]);
}
?>
