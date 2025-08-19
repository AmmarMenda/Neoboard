<?php
// api/report.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
require_once "db.php";

$type = $_POST["type"] ?? "";
$target_id = $_POST["target_id"] ?? "";
$reason = $_POST["reason"] ?? "";
$description = $_POST["description"] ?? "";
if (!$type || !$target_id || !$reason) {
    echo json_encode(["success" => false, "error" => "Missing fields"]);
    exit();
}

$stmt = $pdo->prepare(
    "INSERT INTO reports (report_type, target_id, reason, description, created_at, status) VALUES (?, ?, ?, ?, NOW(), 'pending')",
);
$stmt->execute([$type, $target_id, $reason, $description]);
echo json_encode(["success" => true, "report_id" => $pdo->lastInsertId()]);
