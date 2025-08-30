<?php
// api/reply_delete.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
// Provides the $conn mysqli connection object
require_once "db.php";

// TODO: Authenticate user/moderator before allowing deletion.
// This is a critical security step for a real application.

// --- Input Validation ---
// Check if the ID is provided and is a valid number
if (!isset($_POST["id"]) || !is_numeric($_POST["id"])) {
    http_response_code(400); // Bad Request
    echo json_encode([
        "success" => false,
        "error" => "A valid reply ID is required.",
    ]);
    exit();
}

// Sanitize the ID as an integer
$id = (int) $_POST["id"];

// --- Database Deletion ---
try {
    // Prepare the DELETE statement
    $sql = "DELETE FROM replies WHERE id = ?";
    $stmt = $conn->prepare($sql);

    // Check if the statement preparation failed
    if (!$stmt) {
        throw new Exception("Failed to prepare deletion statement.");
    }

    // Bind the integer ID to the statement
    $stmt->bind_param("i", $id);

    // Execute the statement
    $stmt->execute();

    // Check if a row was actually deleted
    // If affected_rows is 0, it means no reply with that ID was found.
    if ($stmt->affected_rows > 0) {
        // Send a success response
        echo json_encode(["success" => true]);
    } else {
        // The ID was valid, but no reply was found with that ID
        http_response_code(404); // Not Found
        echo json_encode(["success" => false, "error" => "Reply not found."]);
    }
} catch (Exception $e) {
    // Handle any other exceptions during the process
    http_response_code(500); // Internal Server Error
    echo json_encode([
        "success" => false,
        "error" => "Database operation failed: " . $e->getMessage(),
    ]);
} finally {
    // --- Cleanup ---
    // Make sure the statement and connection are closed if they were created
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?>
