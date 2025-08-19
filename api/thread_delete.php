<?php
// api/thread_delete.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
require_once "db.php";

// TODO: Authenticate moderator

$id = $_POST["id"] ?? "";
if (!$id) {
    echo json_encode(["success" => false, "error" => "Missing thread id"]);
    exit();
}

// Cascade delete all replies to this thread
$pdo->prepare("DELETE FROM replies WHERE thread_id=?")->execute([$id]);
$pdo->prepare("DELETE FROM threads WHERE id=?")->execute([$id]);

echo json_encode(["success" => true]);
