<?php
// CORS Headers Configuration
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

class Database {
    private $host = "institutoj17.sg-host.com";
    private $db_name = "dbg4rp1niwrzmg";
    private $username = "ubr7awxothprf";
    private $password = "ISUJ123/2026";
    public $conn;

    public function getConnection() {
        $this->conn = null;

        // Smart fallback: try remote host first, then localhost / 127.0.0.1 for SiteGround hosting environments
        $hosts_to_try = [$this->host, "localhost", "127.0.0.1"];
        $last_exception = null;

        foreach ($hosts_to_try as $h) {
            try {
                $dsn = "mysql:host=" . $h . ";dbname=" . $this->db_name . ";charset=utf8mb4";
                $options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];
                $this->conn = new PDO($dsn, $this->username, $this->password, $options);
                break; // Connection succeeded!
            } catch (PDOException $exception) {
                $last_exception = $exception;
            }
        }

        if ($this->conn === null) {
            http_response_code(500);
            echo json_encode([
                "error" => "Error de conexión a la base de datos",
                "message" => $last_exception ? $last_exception->getMessage() : "Desconocido"
            ]);
            exit();
        }

        return $this->conn;
    }
}
?>
