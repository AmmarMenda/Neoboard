<?php
// api/thread_delete.php
header("Content-Type: application/json");
// Keep this header if you need it for a web-based admin panel
header("Access-Control-Allow-Origin: http://127.0.0.1:5678"); 

// Provides the $conn mysqli connection object
require_once "db.php";

// TODO: Authenticate user/moderator before allowing deletion.
// This is a critical security step for a real application.

// --- Input Validation ---
// Check if the ID is provided and is a valid number
if (!isset($_POST["id"]) || !is_numeric($_POST["id"])) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "error" => "A valid thread ID is required."]);
    exit();
}

// Sanitize the ID as an integer
$id = (int)$_POST["id"];

// --- Database Deletion within a Transaction ---
// A transaction ensures that both deletions succeed, or neither do.
try {
    // Start the transaction
    $conn->begin_transaction();

    // 1. Delete all replies associated with the thread
    $sql_replies = "DELETE FROM replies WHERE thread_id = ?";
    $stmt_replies = $conn->prepare($sql_replies);
    if (!$stmt_replies) {
        throw new Exception('Failed to prepare replies deletion statement.');
    }
    $stmt_replies->bind_param("i", $id); // 'i' for integer
    $stmt_replies->execute();
    $stmt_replies->close(); // Close the statement

    // 2. Delete the main thread itself
    $sql_thread = "DELETE FROM threads WHERE id = ?";
    $stmt_thread = $conn->prepare($sql_thread);
    if (!$stmt_thread) {
        throw new Exception('Failed to prepare thread deletion statement.');
    }
    $stmt_thread->bind_param("i", $id);
    $stmt_thread->execute();
    
    // Check if the thread was actually deleted (i.e., it existed)
    if ($stmt_thread->affected_rows === 0) {
        throw new Exception('Thread not found or could not be deleted.');
    }
    $stmt_thread->close(); // Close the statement

    // If both operations were successful, commit the transaction
    $conn->commit();

    // Send success response
    echo json_encode(["success" => true]);

} catch (Exception $e) {
    // If any error occurred, roll back the entire transaction
    $conn->rollback();
    
    // Send an error response
    http_response_code(500); // Internal Server Error
    echo json_encode(["success" => false, "error" => "Database transaction failed: " . $e->getMessage()]);
} finally {
    // --- Cleanup ---
    // Always close the connection
    $conn->close();
}

?>
