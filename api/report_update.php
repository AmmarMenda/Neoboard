<?php
// api/report_update.php
header("Content-Type: application/json");

require_once "db.php";

// --- Input Validation ---
$id = $_POST["id"] ?? null;
$status = $_POST["status"] ?? null;

// Validate ID
if (empty($id) || !is_numeric($id)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "A valid report ID is required."]);
    exit();
}
$id = (int)$id;

// Validate status against an allowed list
$allowed_statuses = ['reviewed', 'dismissed'];
if (empty($status) || !in_array($status, $allowed_statuses, true)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "Invalid status provided."]);
    exit();
}

// --- Database Update ---
try {
    $sql = "UPDATE reports SET status = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception('Database prepare failed: ' . $conn->error);
    }

    // Bind parameters: s = string (status), i = integer (id)
    $stmt->bind_param("si", $status, $id);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true]);
    } else {
        http_response_code(404); // Not Found
        echo json_encode(["success" => false, "error" => "Report not found or status is already set."]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
} finally {
    if (isset($stmt)) $stmt->close();
    if (isset($conn)) $conn->close();
}
?>
