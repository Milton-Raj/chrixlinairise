<?php
/**
 * Returns the public PayPal Client ID for the frontend.
 * Called when localStorage has no PayPal config (fresh visitor / incognito).
 * Only exposes the Client ID (public) — never the Secret.
 */
require_once __DIR__ . '/paypal-config.php';

echo json_encode([
    'clientId' => PP_CLIENT_ID,
    'currency' => 'USD',
]);
