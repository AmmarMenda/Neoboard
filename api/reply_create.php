<?php
// api/reply_create.php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
// Provides the $conn mysqli connection object
require_once "db.php"; 

// --- Input Validation ---
$thread_id = $_POST["thread_id"] ?? null;
$content = $_POST["content"] ?? "";
$image_path = null; // Initialize image path as null

// The Flutter app can send empty content if an image is present.
// So, we only fail if both content and image are missing.
if (empty($content) && !isset($_FILES["image"])) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "error" => "Content or an image is required."]);
    exit();
}

// Thread ID is always required
if (empty($thread_id) || !is_numeric($thread_id)) {
    http_response_code(400);
    echo json_encode(["success" => false, "error" => "A valid thread_id is required."]);
    exit();
}

// Convert thread_id to an integer for security
$thread_id = (int)$thread_id;

// --- Handle Image Upload (if present) ---
if (isset($_FILES["image"]) && $_FILES["image"]["error"] === UPLOAD_ERR_OK) {
    // Define the base directory for uploads, relative to this script's location
    $upload_dir = __DIR__ . "/../uploads/";

    // Create the directory if it doesn't exist
    if (!is_dir($upload_dir)) {
        // The `true` parameter allows for recursive directory creation
        if (!mkdir($upload_dir, 0755, true)) {
            http_response_code(500);
            echo json_encode(["success" => false, "error" => "Failed to create upload directory."]);
            exit();
        }
    }

    $file_info = pathinfo($_FILES["image"]["name"]);
    $extension = strtolower($file_info["extension"]);

    // Validate allowed file extensions for security
    $allowed_ext = ["jpg", "jpeg", "png", "gif", "webp"];
    if (!in_array($extension, $allowed_ext)) {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Unsupported image format. Allowed: " . implode(', ', $allowed_ext)]);
        exit();
    }

    // Generate a unique filename to prevent overwriting existing files
    $filename = uniqid("reply_", true) . "." . $extension;
    $destination = $upload_dir . $filename;

    // Move the temporary file to the final destination
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $destination)) {
        // Store a web-accessible, relative path in the database
        // IMPORTANT: Assumes 'uploads' is in the parent directory of 'api'
        $image_path = "uploads/" . $filename; 
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "error" => "Failed to move uploaded file."]);
        exit();
    }
}

// --- Database Insertion using mysqli ---
$sql = "INSERT INTO replies (thread_id, content, image_path) VALUES (?, ?, ?)";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Database prepare failed: " . $conn->error]);
    exit;
}

// Bind parameters: i = integer, s = string, s = string
$stmt->bind_param("iss", $thread_id, $content, $image_path);

// Execute the statement and check for success
if ($stmt->execute()) {
    // Get the ID of the newly inserted reply using mysqli's property
    $new_reply_id = $conn->insert_id;
    echo json_encode(["success" => true, "reply_id" => $new_reply_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => "Database insert failed: " . $stmt->error]);
}

// --- Cleanup ---
$stmt->close();
$conn->close();

?>
