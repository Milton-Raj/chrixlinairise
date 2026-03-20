<?php
/**
 * PayPal Live — Create Order
 * POST body (JSON): { amount: "99.00", currency: "USD", description: "..." }
 * Returns: { id: "PAYPAL_ORDER_ID" }
 */
require_once __DIR__ . '/paypal-config.php';

$raw = file_get_contents('php://input');
$in  = json_decode($raw, true);

$amount      = isset($in['amount'])      ? (string)$in['amount']      : '0.00';
$currency    = isset($in['currency'])    ? strtoupper($in['currency']) : 'USD';
$description = isset($in['description']) ? substr($in['description'], 0, 127) : 'Chrixlin AI Rise';

if (!$amount || !is_numeric($amount) || floatval($amount) <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid amount']);
    exit;
}

$payload = [
    'intent' => 'CAPTURE',
    'purchase_units' => [[
        'amount' => [
            'currency_code' => $currency,
            'value'         => number_format((float)$amount, 2, '.', ''),
        ],
        'description' => $description,
    ]],
    'payment_source' => [
        'paypal' => [
            'experience_context' => [
                'brand_name'          => 'Chrixlin',
                'locale'              => 'en-US',
                'landing_page'        => 'NO_PREFERENCE',
                'shipping_preference' => 'NO_SHIPPING',
                'user_action'         => 'PAY_NOW',
                'return_url'          => 'https://chrixlin.tech/payment.html?pp=success',
                'cancel_url'          => 'https://chrixlin.tech/payment.html?pp=cancel',
            ],
        ],
    ],
];

$result = pp_request('POST', '/v2/checkout/orders', $payload);

if ($result['code'] !== 201 && $result['code'] !== 200) {
    http_response_code(502);
    echo json_encode(['error' => 'Order creation failed', 'detail' => $result['body']]);
    exit;
}

echo json_encode(['id' => $result['body']['id'] ?? '']);
