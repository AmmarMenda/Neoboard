<?php
// update_coordinator_status.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "success" => false,
        "error" => "Only POST method allowed",
    ]);
    exit();
}

$input = json_decode(file_get_contents("php://input"), true);
$application_id = $input["id"] ?? "";
$status = $input["status"] ?? "";

if (empty($application_id) || empty($status)) {
    echo json_encode([
        "success" => false,
        "error" => "Application ID and status are required",
    ]);
    exit();
}

if (!in_array($status, ["pending", "approved", "rejected"])) {
    echo json_encode([
        "success" => false,
        "error" => "Invalid status value",
    ]);
    exit();
}

try {
    $sql =
        "UPDATE coordinator_applications SET status = ?, updated_at = NOW() WHERE id = ?";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        throw new Exception("Database prepare failed: " . $conn->error);
    }

    $stmt->bind_param("si", $status, $application_id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode([
                "success" => true,
                "message" => "Status updated successfully",
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "error" => "Application not found",
            ]);
        }
    } else {
        throw new Exception("Execute failed: " . $stmt->error);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "error" => "Failed to update status: " . $e->getMessage(),
    ]);
}

$conn->close();
?>
