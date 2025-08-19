<?php
// api/reports.php
header("Content-Type: application/json");
require_once "db.php";

$allowed_statuses = ['pending', 'reviewed', 'dismissed'];
$status = $_GET["status"] ?? 'all';

// The SQL query is updated to select the image_path from both tables
$sql = "
    SELECT 
        r.id, 
        r.report_type, 
        r.target_id, 
        r.reason, 
        r.description, 
        r.created_at, 
        r.status,
        t.title AS thread_title,
        p.content AS post_content,
        t.image_path AS thread_image_path, -- Get image from threads table
        p.image_path AS reply_image_path   -- Get image from replies table
    FROM 
        reports r
    LEFT JOIN 
        threads t ON r.target_id = t.id AND r.report_type = 'thread'
    LEFT JOIN 
        replies p ON r.target_id = p.id AND r.report_type = 'reply'
";

$params = [];
$types = '';

if (in_array($status, $allowed_statuses, true)) {
    $sql .= " WHERE r.status = ?";
    $params[] = $status;
    $types .= 's';
}

$sql .= " ORDER BY r.created_at DESC";

try {
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception('Database prepare statement failed: ' . $conn->error);
    }

    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $reports = [];
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id'];
        $row['target_id'] = (int)$row['target_id'];
        
        if ($row['report_type'] === 'thread') {
            $row['reported_content'] = $row['thread_title'] ?? '[Thread not found or deleted]';
        } elseif ($row['report_type'] === 'reply') {
            $row['reported_content'] = $row['post_content'] ?? '[Reply not found or deleted]';
        } else {
            $row['reported_content'] = '[Unknown report type]';
        }

        // Add a new 'reported_image_path' field to the JSON.
        // COALESCE will pick the first non-null value (either from the thread or the reply).
        $row['reported_image_path'] = $row['thread_image_path'] ?? $row['reply_image_path'] ?? null;
        
        // Clean up unnecessary fields
        unset($row['thread_title'], $row['post_content'], $row['thread_image_path'], $row['reply_image_path']);
        
        $reports[] = $row;
    }

    echo json_encode($reports);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
} finally {
    if (isset($stmt)) $stmt->close();
    if (isset($conn)) $conn->close();
}
?>
