<?php
// api/login.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
require_once "db.php";

// Replace with actual user auth for production
$username = $_POST["username"] ?? "";
$password = $_POST["password"] ?? "";
if ($username === "batman" && $password === "ammar007") {
    // Generate a token, or just return success for test:
    echo json_encode(["success" => true, "token" => "SOME_FAKE_TOKEN"]);
} else {
    echo json_encode(["success" => false, "error" => "Login failed"]);
}
