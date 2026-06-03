<?php
class JWT {
    private static $secret_key = "cambiar_en_produccion_por_un_secreto_seguro";

    // Encode data to base64url
    private static function base64UrlEncode($data) {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }

    // Decode base64url data
    private static function base64UrlDecode($data) {
        $padding = strlen($data) % 4;
        if ($padding) {
            $data .= str_repeat('=', 4 - $padding);
        }
        return base64_decode(str_replace(['-', '_'], ['+', '/'], $data));
    }

    // Generate JWT Token
    public static function encode($payload) {
        $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']);
        
        // Add expiration default 24h if not set
        if (!isset($payload['exp'])) {
            $payload['exp'] = time() + (60 * 60 * 24);
        }

        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode(json_encode($payload));
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret_key, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    // Decode and verify JWT Token
    public static function decode($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return null;
        }

        list($header, $payload, $signature) = $parts;

        // Verify Signature
        $validSignature = hash_hmac('sha256', $header . "." . $payload, self::$secret_key, true);
        if (!hash_equals(self::base64UrlDecode($signature), $validSignature)) {
            return null;
        }

        $decodedPayload = json_decode(self::base64UrlDecode($payload), true);

        // Verify Expiration
        if (isset($decodedPayload['exp']) && $decodedPayload['exp'] < time()) {
            return null;
        }

        return $decodedPayload;
    }

    // Extract Bearer Token from HTTP Headers
    public static function getBearerToken() {
        $headers = null;
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } else if (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }

        if (!empty($headers)) {
            if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
                return $matches[1];
            }
        }
        return null;
    }

    // Authenticate current request
    public static function authenticate() {
        $token = self::getBearerToken();
        if (!$token) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado", "message" => "Token de acceso ausente."]);
            exit();
        }

        $payload = self::decode($token);
        if (!$payload) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado", "message" => "Token de acceso inválido o expirado."]);
            exit();
        }

        return $payload; // Returns payload containing user details (e.g. sub = email)
    }
}
?>
