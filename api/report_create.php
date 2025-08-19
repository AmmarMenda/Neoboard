<?php
// api/report_create.php
header("Content-Type: application/json");
require_once "db.php";

// --- Input Validation ---
// Use trim() to clean up string inputs
$type = trim($_POST["type"] ?? "");
$target_id = $_POST["target_id"] ?? "";
$reason = trim($_POST["reason"] ?? "");
$description = trim($_POST["description"] ?? ""); // Optional field

// 1. Validate the report type
$allowed_types = ['thread', 'reply'];
if (empty($type) || !in_array($type, $allowed_types, true)) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "error" => "Invalid or missing report type. Must be 'thread' or 'reply'."]);
    exit();
}

// 2. Validate the target ID
if (empty($target_id) || !is_numeric($target_id)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "A valid target ID is required."]);
    exit();
}
$target_id = (int)$target_id; // Sanitize as an integer

// 3. Validate the reason
if (empty($reason)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "A reason for the report is required."]);
    exit();
}

// --- Database Insertion ---
try {
    // The query sets status to 'pending' by default.
    $sql = "INSERT INTO reports (report_type, target_id, reason, description, created_at, status) VALUES (?, ?, ?, ?, NOW(), 'pending')";
    
    $stmt = $conn->prepare($sql);

    // Check for errors during statement preparation
    if (!$stmt) {
        throw new Exception('Database prepare statement failed: ' . $conn->error);
    }

    // Bind parameters to the query for security
    // s = string, i = integer, s = string, s = string
    $stmt->bind_param("siss", $type, $target_id, $reason, $description);

    // Execute the statement
    if ($stmt->execute()) {
        $new_report_id = $conn->insert_id;
        
        // Use HTTP 201 Created for a successful new resource
        http_response_code(201); 
        echo json_encode(["success" => true, "report_id" => $new_report_id]);
    } else {
        throw new Exception('Database execute failed: ' . $stmt->error);
    }

} catch (Exception $e) {
    // Catch any database errors and return a server error message
    http_response_code(500); // Internal Server Error
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
} finally {
    // --- Cleanup ---
    // Always close the statement and connection
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?>
