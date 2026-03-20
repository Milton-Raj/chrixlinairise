<?php
/**
 * PayPal Live — Capture Order
 * POST body (JSON): { orderId: "PAYPAL_ORDER_ID" }
 * Returns: full capture details from PayPal
 */
require_once __DIR__ . '/paypal-config.php';

$raw     = file_get_contents('php://input');
$in      = json_decode($raw, true);
$orderId = isset($in['orderId']) ? trim($in['orderId']) : '';

if (!$orderId) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing orderId']);
    exit;
}

// Sanitise orderId — PayPal IDs are alphanumeric
if (!preg_match('/^[A-Z0-9]+$/i', $orderId)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid orderId']);
    exit;
}

$result = pp_request('POST', '/v2/checkout/orders/' . $orderId . '/capture');

if ($result['code'] !== 201 && $result['code'] !== 200) {
    http_response_code(502);
    echo json_encode(['error' => 'Capture failed', 'detail' => $result['body']]);
    exit;
}

echo json_encode($result['body']);
