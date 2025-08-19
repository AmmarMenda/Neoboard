<?php
// api/create_thread.php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
// Provides the $conn mysqli connection object
require_once "db.php"; 

// --- Input Validation ---
// Use trim() to remove whitespace and prevent empty submissions
$title = trim($_POST["title"] ?? "");
$content = trim($_POST["content"] ?? "");
$board = trim($_POST["board"] ?? "");

// Validate required fields *before* processing any file uploads
if (empty($title) || empty($content) || empty($board)) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "error" => "Title, content, and board fields are required."]);
    exit();
}

// --- Handle Image Upload (if present) ---
$image_path = null; // Default to null, so it's safely handled if no image is uploaded

if (isset($_FILES["image"]) && $_FILES["image"]["error"] === UPLOAD_ERR_OK) {
    $upload_dir = __DIR__ . "/../uploads/";

    // Create directory if it doesn't exist
    if (!is_dir($upload_dir)) {
        if (!mkdir($upload_dir, 0755, true)) {
            http_response_code(500);
            echo json_encode(["success" => false, "error" => "Failed to create upload directory."]);
            exit();
        }
    }

    $file_info = pathinfo($_FILES["image"]["name"]);
    $extension = strtolower($file_info["extension"]);

    // Security: Validate allowed file extensions
    $allowed_ext = ["jpg", "jpeg", "png", "gif", "webp"];
    if (!in_array($extension, $allowed_ext)) {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Unsupported image format. Allowed: " . implode(', ', $allowed_ext)]);
        exit();
    }

    // Generate a more unique filename to prevent collisions
    $filename = uniqid('thread_', true) . "." . $extension;
    $destination = $upload_dir . $filename;

    // Move the uploaded file to its final destination
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $destination)) {
        // Store the web-accessible relative path. This assumes your server
        // is running from the project root directory ('neobaord/').
        $image_path = "uploads/" . $filename; 
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "error" => "Failed to move uploaded file."]);
        exit();
    }
}

// --- Database Insertion using mysqli ---
// Using NOW() here is a good fallback if the table column doesn't have a DEFAULT CURRENT_TIMESTAMP
$sql = "INSERT INTO threads (title, content, board, image_path, created_at) VALUES (?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Database prepare failed: " . $conn->error]);
    exit;
}

// Bind parameters: s = string. All four parameters are strings.
$stmt->bind_param("ssss", $title, $content, $board, $image_path);

// Execute the statement and check for success
if ($stmt->execute()) {
    // Get the ID of the new thread using mysqli's property
    $new_thread_id = $conn->insert_id;
    echo json_encode(["success" => true, "thread_id" => $new_thread_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Database insert failed: " . $stmt->error]);
}

// --- Cleanup ---
$stmt->close();
$conn->close();

?>
