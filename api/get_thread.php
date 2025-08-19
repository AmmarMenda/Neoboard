<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
include 'db.php'; // Your database connection file

// Check if thread_id is provided in the request
if (!isset($_GET['thread_id'])) {
    echo json_encode(['success' => false, 'error' => 'Thread ID not provided.']);
    exit;
}

$thread_id = (int)$_GET['thread_id'];

// Use a prepared statement to prevent SQL injection
$stmt = $conn->prepare("SELECT id, board, title, content, created_at ,image_path FROM threads WHERE id = ?");
$stmt->bind_param("i", $thread_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $thread = $result->fetch_assoc();
    // Optionally, you can also fetch all replies for this thread here
    echo json_encode(['success' => true, 'thread' => $thread]);
} else {
    echo json_encode(['success' => false, 'error' => 'Thread not found.']);
}

$stmt->close();
$conn->close();
?>
