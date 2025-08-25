<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php";

// Only allow POST requests
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "success" => false,
        "error" => "Only POST method allowed",
    ]);
    exit();
}

try {
    // Get form data
    $name = trim($_POST["name"] ?? "");
    $enrollment_no = trim($_POST["enrollment_no"] ?? "");
    $division = trim($_POST["division"] ?? "");
    $department = trim($_POST["department"] ?? "");

    // Validate required fields
    if (
        empty($name) ||
        empty($enrollment_no) ||
        empty($division) ||
        empty($department)
    ) {
        echo json_encode([
            "success" => false,
            "error" => "All fields are required",
        ]);
        exit();
    }

    // Additional validation
    if (strlen($name) < 2) {
        echo json_encode([
            "success" => false,
            "error" => "Name must be at least 2 characters long",
        ]);
        exit();
    }

    if (strlen($enrollment_no) < 3) {
        echo json_encode([
            "success" => false,
            "error" => "Enrollment number must be at least 3 characters long",
        ]);
        exit();
    }

    // Check if enrollment number already exists
    $check_sql =
        "SELECT id FROM coordinator_applications WHERE enrollment_no = ?";
    $check_stmt = $conn->prepare($check_sql);
    if ($check_stmt) {
        $check_stmt->bind_param("s", $enrollment_no);
        $check_stmt->execute();
        $result = $check_stmt->get_result();

        if ($result->num_rows > 0) {
            echo json_encode([
                "success" => false,
                "error" => "Enrollment number already registered",
            ]);
            $check_stmt->close();
            exit();
        }
        $check_stmt->close();
    }

    // Handle ID card image upload
    $id_card_path = null;

    if (
        isset($_FILES["id_card"]) &&
        $_FILES["id_card"]["error"] === UPLOAD_ERR_OK
    ) {
        $upload_dir = "uploads/id_cards/";

        // Create upload directory if it doesn't exist
        if (!is_dir($upload_dir)) {
            if (!mkdir($upload_dir, 0755, true)) {
                echo json_encode([
                    "success" => false,
                    "error" => "Failed to create upload directory",
                ]);
                exit();
            }
        }

        // Validate file size (max 5MB) - keeping size validation
        $max_size = 5 * 1024 * 1024; // 5MB
        if ($_FILES["id_card"]["size"] > $max_size) {
            echo json_encode([
                "success" => false,
                "error" => "File size too large. Maximum 5MB allowed",
            ]);
            exit();
        }

        // Generate unique filename
        $file_extension = pathinfo(
            $_FILES["id_card"]["name"],
            PATHINFO_EXTENSION,
        );
        $filename =
            "id_card_" .
            $enrollment_no .
            "_" .
            uniqid() .
            "." .
            strtolower($file_extension);
        $id_card_path = $upload_dir . $filename;

        // Move uploaded file
        if (
            !move_uploaded_file($_FILES["id_card"]["tmp_name"], $id_card_path)
        ) {
            echo json_encode([
                "success" => false,
                "error" => "Failed to upload ID card image",
            ]);
            exit();
        }
    } else {
        // Handle upload errors
        if (isset($_FILES["id_card"])) {
            $error_code = $_FILES["id_card"]["error"];
            switch ($error_code) {
                case UPLOAD_ERR_INI_SIZE:
                case UPLOAD_ERR_FORM_SIZE:
                    $error_msg = "File size too large";
                    break;
                case UPLOAD_ERR_PARTIAL:
                    $error_msg = "File was only partially uploaded";
                    break;
                case UPLOAD_ERR_NO_FILE:
                    $error_msg = "No file was uploaded";
                    break;
                case UPLOAD_ERR_NO_TMP_DIR:
                    $error_msg = "Missing temporary folder";
                    break;
                case UPLOAD_ERR_CANT_WRITE:
                    $error_msg = "Failed to write file to disk";
                    break;
                default:
                    $error_msg = "Unknown upload error";
            }
        } else {
            $error_msg = "ID card image is required";
        }

        echo json_encode([
            "success" => false,
            "error" => $error_msg,
        ]);
        exit();
    }

    // Insert into database
    $sql =
        "INSERT INTO coordinator_applications (name, enrollment_no, division, department, id_card_path, status, created_at) VALUES (?, ?, ?, ?, ?, 'pending', NOW())";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        echo json_encode([
            "success" => false,
            "error" => "Database preparation failed: " . $conn->error,
        ]);
        exit();
    }

    $stmt->bind_param(
        "sssss",
        $name,
        $enrollment_no,
        $division,
        $department,
        $id_card_path,
    );

    if ($stmt->execute()) {
        $application_id = $conn->insert_id;

        echo json_encode([
            "success" => true,
            "message" => "Co-ordinator application submitted successfully!",
            "application_id" => $application_id,
            "data" => [
                "id" => $application_id,
                "name" => $name,
                "enrollment_no" => $enrollment_no,
                "division" => $division,
                "department" => $department,
                "status" => "pending",
            ],
        ]);
    } else {
        // If database insert fails, remove uploaded file
        if ($id_card_path && file_exists($id_card_path)) {
            unlink($id_card_path);
        }

        echo json_encode([
            "success" => false,
            "error" => "Failed to submit application: " . $stmt->error,
        ]);
    }

    $stmt->close();
} catch (Exception $e) {
    // If any error occurs, clean up uploaded file
    if (isset($id_card_path) && $id_card_path && file_exists($id_card_path)) {
        unlink($id_card_path);
    }

    echo json_encode([
        "success" => false,
        "error" => "Server error: " . $e->getMessage(),
    ]);
}

$conn->close();
?>
