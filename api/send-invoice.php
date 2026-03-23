<?php
/**
 * Chrixlin AI Rise — Invoice Email Sender
 * POST /api/send-invoice.php
 * Sends invoice to customer + notification to admin after payment.
 */
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); echo json_encode(['ok'=>false,'error'=>'Method not allowed']); exit; }

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!$data) { http_response_code(400); echo json_encode(['ok'=>false,'error'=>'Invalid JSON']); exit; }

// ── Extract fields ──────────────────────────────────────────────────────────
$orderRef    = htmlspecialchars($data['orderRef']    ?? 'N/A');
$firstName   = htmlspecialchars($data['firstName']   ?? '');
$lastName    = htmlspecialchars($data['lastName']    ?? '');
$fullName    = trim("$firstName $lastName") ?: 'Valued Customer';
$custEmail   = filter_var($data['email'] ?? '', FILTER_VALIDATE_EMAIL);
$phone       = htmlspecialchars($data['phone']       ?? '');
$planName    = htmlspecialchars($data['planName']    ?? 'Chrixlin AI Rise');
$planCycle   = htmlspecialchars($data['planCycle']   ?? '');
$amount      = htmlspecialchars($data['amount']      ?? '');
$currency    = htmlspecialchars($data['currency']    ?? 'USD');
$payMethod   = htmlspecialchars($data['paymentMethod']?? '');
$requirements= htmlspecialchars($data['requirements'] ?? '');
$pdfUrl      = htmlspecialchars($data['pdfUrl']      ?? '');
$adminEmail  = filter_var($data['adminEmail'] ?? 'info@chrixlin.tech', FILTER_VALIDATE_EMAIL) ?: 'info@chrixlin.tech';
$date        = date('d M Y, h:i A T');

if (!$custEmail) { http_response_code(400); echo json_encode(['ok'=>false,'error'=>'Invalid customer email']); exit; }

// ── Helper: send HTML email ──────────────────────────────────────────────────
function sendMail($to, $subject, $htmlBody, $fromName = 'Chrixlin AI Rise', $fromEmail = 'noreply@chrixlin.tech') {
    $headers  = "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    $headers .= "From: $fromName <$fromEmail>\r\n";
    $headers .= "Reply-To: info@chrixlin.tech\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
    return mail($to, $subject, $htmlBody, $headers);
}

// ── Customer invoice HTML ─────────────────────────────────────────────────────
$cycleLabel  = $planCycle ? ' (' . ucfirst($planCycle) . ')' : '';
$pdfSection  = $pdfUrl ? "<p style='margin:0 0 6px'><strong>Document:</strong> <a href='$pdfUrl' style='color:#7c3aed'>View attached document →</a></p>" : '';
$reqSection  = $requirements ? "<div style='background:#f8f4ff;border-left:4px solid #7c3aed;padding:14px 18px;border-radius:0 8px 8px 0;margin:20px 0'><p style='margin:0 0 6px;font-weight:700;color:#4c1d95'>Your Requirements</p><p style='margin:0;color:#374151;line-height:1.6'>$requirements</p></div>" : '';

$customerHtml = <<<HTML
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Your Invoice — Chrixlin AI Rise</title></head>
<body style="margin:0;padding:0;background:#f4f4f8;font-family:'Segoe UI',Arial,sans-serif">
  <div style="max-width:600px;margin:32px auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08)">
    <!-- Header -->
    <div style="background:linear-gradient(135deg,#7c3aed,#06b6d4);padding:36px 40px;text-align:center">
      <h1 style="margin:0;color:#fff;font-size:26px;font-weight:800;letter-spacing:-0.5px">🤖 Chrixlin AI Rise</h1>
      <p style="margin:8px 0 0;color:rgba(255,255,255,0.85);font-size:14px">Payment Confirmation &amp; Invoice</p>
    </div>
    <!-- Body -->
    <div style="padding:36px 40px">
      <p style="margin:0 0 20px;font-size:16px;color:#111827">Hi <strong>$fullName</strong>,</p>
      <p style="margin:0 0 24px;color:#374151;line-height:1.7">Thank you for your payment! We have received your order and our team will get in touch with you within <strong>24 hours</strong> to begin your onboarding.</p>

      <!-- Invoice box -->
      <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:12px;padding:24px;margin-bottom:24px">
        <h2 style="margin:0 0 18px;font-size:16px;color:#111827;font-weight:700">🧾 Invoice Details</h2>
        <table style="width:100%;border-collapse:collapse;font-size:14px">
          <tr><td style="padding:6px 0;color:#6b7280;width:140px">Order Ref</td><td style="padding:6px 0;color:#111827;font-weight:600">$orderRef</td></tr>
          <tr><td style="padding:6px 0;color:#6b7280">Date</td><td style="padding:6px 0;color:#111827">$date</td></tr>
          <tr><td style="padding:6px 0;color:#6b7280">Plan</td><td style="padding:6px 0;color:#111827;font-weight:600">$planName$cycleLabel</td></tr>
          <tr><td style="padding:6px 0;color:#6b7280">Payment Via</td><td style="padding:6px 0;color:#111827">{$payMethod}</td></tr>
          <tr><td style="padding:6px 0;color:#6b7280">Phone</td><td style="padding:6px 0;color:#111827">$phone</td></tr>
        </table>
        <div style="border-top:2px solid #7c3aed;margin-top:16px;padding-top:16px;display:flex;justify-content:space-between">
          <span style="font-size:16px;font-weight:700;color:#111827">Total Paid</span>
          <span style="font-size:22px;font-weight:900;color:#7c3aed">$amount $currency</span>
        </div>
      </div>

      $reqSection

      $pdfSection

      <!-- Next steps -->
      <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:20px;margin-bottom:24px">
        <h3 style="margin:0 0 12px;font-size:15px;color:#166534">✅ What Happens Next</h3>
        <ol style="margin:0;padding:0 0 0 20px;color:#374151;font-size:14px;line-height:1.8">
          <li>Our team reviews your requirements within <strong>2–4 hours</strong></li>
          <li>You receive a personalized onboarding plan via email</li>
          <li>We schedule your kickoff call within <strong>24 hours</strong></li>
          <li>Your AI business transformation begins 🚀</li>
        </ol>
      </div>

      <p style="margin:0 0 8px;color:#374151;font-size:14px">Questions? Reply to this email or contact us:</p>
      <p style="margin:0;font-size:14px"><a href="mailto:$adminEmail" style="color:#7c3aed;font-weight:600">$adminEmail</a></p>
    </div>
    <!-- Footer -->
    <div style="background:#f9fafb;border-top:1px solid #e5e7eb;padding:20px 40px;text-align:center">
      <p style="margin:0;font-size:12px;color:#9ca3af">© 2025 Chrixlin AI Rise · All rights reserved</p>
      <p style="margin:4px 0 0;font-size:12px;color:#9ca3af">This is an automated invoice — please keep it for your records</p>
    </div>
  </div>
</body>
</html>
HTML;

// ── Admin notification HTML ───────────────────────────────────────────────────
$adminHtml = <<<HTML
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>New Order — $planName</title></head>
<body style="margin:0;padding:0;background:#f4f4f8;font-family:'Segoe UI',Arial,sans-serif">
  <div style="max-width:600px;margin:32px auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08)">
    <div style="background:linear-gradient(135deg,#111827,#1f2937);padding:28px 36px">
      <h1 style="margin:0;color:#a78bfa;font-size:20px;font-weight:800">💰 New Payment Received!</h1>
      <p style="margin:6px 0 0;color:#9ca3af;font-size:13px">Chrixlin AI Rise — Admin Notification</p>
    </div>
    <div style="padding:28px 36px">
      <table style="width:100%;border-collapse:collapse;font-size:14px">
        <tr style="background:#f9fafb"><td style="padding:10px 12px;color:#6b7280;width:140px;border-radius:6px">Order Ref</td><td style="padding:10px 12px;font-weight:700;color:#111827">$orderRef</td></tr>
        <tr><td style="padding:10px 12px;color:#6b7280">Customer</td><td style="padding:10px 12px;color:#111827">$fullName</td></tr>
        <tr style="background:#f9fafb"><td style="padding:10px 12px;color:#6b7280">Email</td><td style="padding:10px 12px"><a href="mailto:$custEmail" style="color:#7c3aed">$custEmail</a></td></tr>
        <tr><td style="padding:10px 12px;color:#6b7280">Phone</td><td style="padding:10px 12px;color:#111827">$phone</td></tr>
        <tr style="background:#f9fafb"><td style="padding:10px 12px;color:#6b7280">Plan</td><td style="padding:10px 12px;font-weight:700;color:#7c3aed">$planName$cycleLabel</td></tr>
        <tr><td style="padding:10px 12px;color:#6b7280">Amount</td><td style="padding:10px 12px;font-weight:900;color:#059669;font-size:18px">$amount $currency</td></tr>
        <tr style="background:#f9fafb"><td style="padding:10px 12px;color:#6b7280">Payment Via</td><td style="padding:10px 12px;color:#111827">{$payMethod}</td></tr>
        <tr><td style="padding:10px 12px;color:#6b7280">Date</td><td style="padding:10px 12px;color:#111827">$date</td></tr>
      </table>
      HTML . ($requirements ? "
      <div style='margin-top:20px;background:#f5f3ff;border-left:4px solid #7c3aed;padding:14px 18px;border-radius:0 8px 8px 0'>
        <p style='margin:0 0 6px;font-weight:700;color:#4c1d95'>Customer Requirements</p>
        <p style='margin:0;color:#374151;line-height:1.6'>$requirements</p>
      </div>" : '') .
      ($pdfUrl ? "<p style='margin:16px 0 0'><a href='$pdfUrl' style='color:#7c3aed;font-weight:600'>📎 View attached document →</a></p>" : '') . "
    </div>
  </div>
</body>
</html>";

// ── Send emails ───────────────────────────────────────────────────────────────
$custOk  = sendMail($custEmail,  "✅ Payment Confirmed — $planName | Order $orderRef", $customerHtml);
$adminOk = sendMail($adminEmail, "💰 New Order: $planName — $fullName ($amount $currency)", $adminHtml);

echo json_encode([
    'ok'        => $custOk,
    'custSent'  => $custOk,
    'adminSent' => $adminOk,
    'orderRef'  => $orderRef
]);
