<?php
/**
 * PayPal Live — Generate Client Token
 * Required by PayPal JS SDK v6 for: Card Fields, Google Pay, Apple Pay, Fastlane
 * Called by: payment.html on page load (fetch /api/paypal-client-token.php)
 */
require_once __DIR__ . '/paypal-config.php';

$token  = pp_get_access_token();
$result = pp_request('POST', '/v1/identity/generate-token', [], $token);

if ($result['code'] !== 200) {
    http_response_code(502);
    echo json_encode(['error' => 'Failed to generate client token', 'detail' => $result['body']]);
    exit;
}

echo json_encode([
    'clientToken' => $result['body']['client_token'] ?? '',
]);
