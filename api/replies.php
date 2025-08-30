<?php
// api/replies.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
// This file provides the $conn mysqli connection object
require_once "db.php";

// --- Validation ---
// Check if thread_id is provided and is a valid number
if (!isset($_GET["thread_id"]) || !is_numeric($_GET["thread_id"])) {
    // Send a "Bad Request" HTTP status code
    http_response_code(400);
    // The Flutter app expects a list, so return an empty list for errors
    // or a more descriptive error object if your app can handle it.
    // Returning an empty list is safer for the current Flutter code.
    echo json_encode([]);
    exit();
}

// Sanitize the input as an integer
$thread_id = (int) $_GET["thread_id"];

// --- Database Query ---
// It's good practice to select only the columns you need
$sql =
    "SELECT id, thread_id, content, created_at, image_path FROM replies WHERE thread_id = ? ORDER BY created_at ASC";

// Prepare the statement using the mysqli connection ($conn)
$stmt = $conn->prepare($sql);

// Check if the statement preparation failed
if (!$stmt) {
    http_response_code(500); // Internal Server Error
    echo json_encode([
        "error" => "Failed to prepare SQL statement: " . $conn->error,
    ]);
    exit();
}

// Bind the thread_id parameter to the prepared statement
// 'i' specifies that the variable is an integer
$stmt->bind_param("i", $thread_id);

// Execute the statement
$stmt->execute();

// Get the result set from the statement
$result = $stmt->get_result();

$replies = [];
// Check if there are any results
if ($result->num_rows > 0) {
    // Loop through each row of the result set
    while ($row = $result->fetch_assoc()) {
        // Explicitly cast numeric fields to ensure they are numbers in the JSON output
        $row["id"] = (int) $row["id"];
        $row["thread_id"] = (int) $row["thread_id"];
        $replies[] = $row;
    }
}

// Encode the final array of replies into a JSON string
// This will correctly output a JSON array like: [ {..}, {..} ]
echo json_encode($replies);

// --- Cleanup ---
// Close the statement and the database connection
$stmt->close();
$conn->close();
?>
