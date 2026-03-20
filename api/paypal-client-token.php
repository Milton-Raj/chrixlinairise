<?php
/**
 * PayPal Live — Generate Client Token (JWT) for JS SDK v6
 * SDK v6 createInstance() requires a JWT from the OAuth2 token endpoint,
 * NOT from /v1/identity/generate-token (that returns a Braintree Base64 token).
 *
 * Correct endpoint:
 *   POST /v1/oauth2/token
 *   grant_type=client_credentials&response_type=client_token
 *   &intent=sdk_init&domains[]=chrixlin.tech
 */
require_once __DIR__ . '/paypal-config.php';

$domain = 'chrixlin.tech';

$ch = curl_init(PP_BASE . '/v1/oauth2/token');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => http_build_query([
        'grant_type'    => 'client_credentials',
        'response_type' => 'client_token',
        'intent'        => 'sdk_init',
        'domains[]'     => $domain,
    ]),
    CURLOPT_USERPWD        => PP_CLIENT_ID . ':' . PP_CLIENT_SECRET,
    CURLOPT_HTTPHEADER     => [
        'Accept: application/json',
        'Accept-Language: en_US',
        'Content-Type: application/x-www-form-urlencoded',
    ],
]);

$body = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($code !== 200) {
    http_response_code(502);
    echo json_encode(['error' => 'PayPal client token request failed', 'status' => $code, 'detail' => json_decode($body, true)]);
    exit;
}

$data = json_decode($body, true);
$clientToken = $data['client_token'] ?? ($data['access_token'] ?? '');

if (!$clientToken) {
    http_response_code(502);
    echo json_encode(['error' => 'Empty client token in PayPal response', 'raw' => $data]);
    exit;
}

echo json_encode(['clientToken' => $clientToken]);
