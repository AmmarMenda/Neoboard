<?php
// api/threads.php
header("Content-Type: application/json");
// Use a wildcard for development to allow requests from any port.
header("Access-Control-Allow-Origin: *");

require_once "db.php"; 

$board_param = isset($_GET["board"]) ? $_GET["board"] : null;

// The query remains the same, but we will use mysqli syntax
$sql = $board_param
    ? "SELECT id, board, title, content, created_at, image_path, (SELECT COUNT(*) FROM replies WHERE thread_id = threads.id) as replies FROM threads WHERE board=? ORDER BY created_at DESC"
    : "SELECT id, board, title, content, created_at, image_path, (SELECT COUNT(*) FROM replies WHERE thread_id = threads.id) as replies FROM threads ORDER BY created_at DESC";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['success' => false, 'error' => 'SQL statement failed: ' . $conn->error]);
    exit;
}

// Bind parameters if a board is specified
if ($board_param) {
    // **THE FIX IS HERE:**
    // We wrap the board name with slashes to match the format '/b/', '/g/', etc.
    // as it is likely stored in the database.
    $board_to_query = '/' . $board_param . '/';
    $stmt->bind_param("s", $board_to_query);
}

$stmt->execute();
$result = $stmt->get_result();

$threads = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['replies'] = (int)$row['replies'];
        $threads[] = $row;
    }
}

echo json_encode($threads);

$stmt->close();
$conn->close();
?>
