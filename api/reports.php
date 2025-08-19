<?php
// api/reports.php
header("Content-Type: application/json");

// Provides the $conn mysqli connection object
require_once "db.php";

// --- Input Validation & Query Building ---
// Define allowed statuses to prevent SQL injection or unexpected behavior
$allowed_statuses = ['pending', 'reviewed', 'dismissed'];
$status = $_GET["status"] ?? 'all';

// The base query
$sql = "SELECT id, report_type, target_id, reason, description, created_at, status FROM reports";

$params = [];
$types = '';

// If a valid status is provided (and it's not 'all'), add a WHERE clause
if (in_array($status, $allowed_statuses, true)) {
    $sql .= " WHERE status = ?";
    $params[] = $status;
    $types .= 's'; // 's' for string
}

// Add ordering
$sql .= " ORDER BY created_at DESC";

// --- Database Execution ---
try {
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception('Database prepare statement failed: ' . $conn->error);
    }

    // Bind parameters if they exist (i.e., if filtering by status)
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $reports = [];
    // Fetch all results into an array
    while ($row = $result->fetch_assoc()) {
        // Ensure numeric types are correct for JSON
        $row['id'] = (int)$row['id'];
        $row['target_id'] = (int)$row['target_id'];
        $reports[] = $row;
    }

    // Return the JSON-encoded array
    echo json_encode($reports);

} catch (Exception $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["error" => $e->getMessage()]);
} finally {
    if (isset($stmt)) $stmt->close();
    if (isset($conn)) $conn->close();
}
?>
