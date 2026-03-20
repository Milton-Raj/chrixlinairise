<?php
/**
 * PayPal Live Configuration
 * Credentials are read from environment variables set in .htaccess
 * Never hardcode credentials here — this file is committed to Git
 */

define('PP_CLIENT_ID',     getenv('PAYPAL_CLIENT_ID')     ?: '');
define('PP_CLIENT_SECRET', getenv('PAYPAL_CLIENT_SECRET') ?: '');
define('PP_BASE',          'https://api-m.paypal.com');   // Live only

// CORS — allow requests from your domain only
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed = ['https://chrixlin.tech', 'https://www.chrixlin.tech'];
if (in_array($origin, $allowed, true)) {
    header('Access-Control-Allow-Origin: ' . $origin);
} else {
    header('Access-Control-Allow-Origin: https://chrixlin.tech');
}
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

/**
 * Get a fresh OAuth2 access token from PayPal Live
 */
function pp_get_access_token(): string {
    $ch = curl_init(PP_BASE . '/v1/oauth2/token');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => 'grant_type=client_credentials',
        CURLOPT_USERPWD        => PP_CLIENT_ID . ':' . PP_CLIENT_SECRET,
        CURLOPT_HTTPHEADER     => ['Accept: application/json', 'Accept-Language: en_US'],
    ]);
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($code !== 200) {
        http_response_code(502);
        echo json_encode(['error' => 'PayPal auth failed', 'status' => $code]);
        exit;
    }

    $data = json_decode($body, true);
    return $data['access_token'] ?? '';
}

/**
 * Generic PayPal REST API call
 */
function pp_request(string $method, string $path, array $payload = [], string $token = ''): array {
    if (!$token) $token = pp_get_access_token();

    $ch = curl_init(PP_BASE . $path);
    $headers = [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json',
        'PayPal-Request-Id: ' . uniqid('chrixlin_', true),
    ];

    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST  => strtoupper($method),
        CURLOPT_HTTPHEADER     => $headers,
    ]);

    if (!empty($payload)) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    }

    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ['code' => $code, 'body' => json_decode($body, true)];
}
