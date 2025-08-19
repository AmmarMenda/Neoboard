<?php
// api/threads.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");

// This file now creates a $conn variable using mysqli
require_once "db.php"; 

$board = isset($_GET["board"]) ? $_GET["board"] : null;

// The query remains the same, but we will use mysqli syntax
$sql = $board
    ? "SELECT id, board, title, content, created_at, image_path, (SELECT COUNT(*) FROM replies WHERE thread_id = threads.id) as replies FROM threads WHERE board=? ORDER BY created_at DESC"
    : "SELECT id, board, title, content, created_at, image_path, (SELECT COUNT(*) FROM replies WHERE thread_id = threads.id) as replies FROM threads ORDER BY created_at DESC";

// Prepare the statement using the $conn (mysqli) object
$stmt = $conn->prepare($sql);

if (!$stmt) {
    // If statement preparation fails, send an error
    echo json_encode(['success' => false, 'error' => 'SQL statement failed: ' . $conn->error]);
    exit;
}

// Bind parameters if a board is specified
if ($board) {
    // 's' means the parameter is a string
    $stmt->bind_param("s", $board);
}

// Execute the statement
$stmt->execute();

// Get the result set from the executed statement
$result = $stmt->get_result();

// Fetch all rows into an array
$threads = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Convert integer fields to the correct type for JSON
        $row['id'] = (int)$row['id'];
        $row['replies'] = (int)$row['replies'];
        $threads[] = $row;
    }
}

// Encode the final array into JSON
echo json_encode($threads);

// Close the statement and connection
$stmt->close();
$conn->close();
?>
