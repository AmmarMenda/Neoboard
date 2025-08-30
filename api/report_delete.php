<?php
// api/report_delete.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "db.php";

// TODO: Add moderator authentication for security

// --- Input Validation ---
$id = $_POST["id"] ?? null;

if (empty($id) || !is_numeric($id)) {
    http_response_code(400); // Bad Request
    echo json_encode([
        "success" => false,
        "error" => "A valid report ID is required.",
    ]);
    exit();
}
$id = (int) $id;

// --- Database Deletion ---
try {
    $sql = "DELETE FROM reports WHERE id = ?";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception("Database prepare failed: " . $conn->error);
    }

    $stmt->bind_param("i", $id);
    $stmt->execute();

    // Check if a row was actually deleted to confirm it existed
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true]);
    } else {
        http_response_code(404); // Not Found
        echo json_encode(["success" => false, "error" => "Report not found."]);
    }
} catch (Exception $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode([
        "success" => false,
        "error" => "Database operation failed: " . $e->getMessage(),
    ]);
} finally {
    // --- Cleanup ---
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?>
