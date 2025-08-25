<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php";

// Only allow GET requests
if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    echo json_encode([
        "success" => false,
        "error" => "Only GET method allowed",
    ]);
    exit();
}

try {
    // Get optional query parameters for filtering
    $status_filter = $_GET["status"] ?? null;
    $limit = isset($_GET["limit"]) ? (int) $_GET["limit"] : null;
    $offset = isset($_GET["offset"]) ? (int) $_GET["offset"] : 0;
    $search = $_GET["search"] ?? null;

    // Build the SQL query with optional filters
    $sql = "SELECT id, name, enrollment_no, division, department, id_card_path, status, created_at, updated_at
            FROM coordinator_applications";

    $conditions = [];
    $params = [];
    $types = "";

    // Add status filter if provided
    if (
        $status_filter &&
        in_array($status_filter, ["pending", "approved", "rejected"])
    ) {
        $conditions[] = "status = ?";
        $params[] = $status_filter;
        $types .= "s";
    }

    // Add search filter if provided
    if ($search && !empty(trim($search))) {
        $search_term = "%" . trim($search) . "%";
        $conditions[] =
            "(name LIKE ? OR enrollment_no LIKE ? OR department LIKE ? OR division LIKE ?)";
        $params = array_merge($params, [
            $search_term,
            $search_term,
            $search_term,
            $search_term,
        ]);
        $types .= "ssss";
    }

    // Add WHERE clause if there are conditions
    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(" AND ", $conditions);
    }

    // Add ordering
    $sql .= " ORDER BY created_at DESC";

    // Add pagination if limit is specified
    if ($limit) {
        $sql .= " LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        $types .= "ii";
    }

    // Prepare and execute the query
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        throw new Exception("Database preparation failed: " . $conn->error);
    }

    // Bind parameters if any
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }

    if (!$stmt->execute()) {
        throw new Exception("Query execution failed: " . $stmt->error);
    }

    $result = $stmt->get_result();
    $applications = [];

    while ($row = $result->fetch_assoc()) {
        // Build full URL for ID card image if it exists
        $id_card_url = null;
        if (!empty($row["id_card_path"])) {
            // Determine the base URL
            $protocol =
                isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] === "on"
                    ? "https"
                    : "http";
            $host = $_SERVER["HTTP_HOST"];
            $script_dir = dirname($_SERVER["SCRIPT_NAME"]);

            // Remove trailing slash from script directory
            $script_dir = rtrim($script_dir, "/");

            $base_url = $protocol . "://" . $host . $script_dir . "/";
            $id_card_url = $base_url . $row["id_card_path"];
        }

        $applications[] = [
            "id" => (int) $row["id"],
            "name" => $row["name"],
            "enrollment_no" => $row["enrollment_no"],
            "division" => $row["division"],
            "department" => $row["department"],
            "id_card_url" => $id_card_url,
            "status" => $row["status"],
            "created_at" => $row["created_at"],
            "updated_at" => $row["updated_at"],
        ];
    }

    $stmt->close();

    // Get total count for pagination (if needed)
    $total_count = 0;
    if ($limit || $search || $status_filter) {
        $count_sql = "SELECT COUNT(*) as total FROM coordinator_applications";
        $count_conditions = [];
        $count_params = [];
        $count_types = "";

        // Add the same filters for count query
        if (
            $status_filter &&
            in_array($status_filter, ["pending", "approved", "rejected"])
        ) {
            $count_conditions[] = "status = ?";
            $count_params[] = $status_filter;
            $count_types .= "s";
        }

        if ($search && !empty(trim($search))) {
            $search_term = "%" . trim($search) . "%";
            $count_conditions[] =
                "(name LIKE ? OR enrollment_no LIKE ? OR department LIKE ? OR division LIKE ?)";
            $count_params = array_merge($count_params, [
                $search_term,
                $search_term,
                $search_term,
                $search_term,
            ]);
            $count_types .= "ssss";
        }

        if (!empty($count_conditions)) {
            $count_sql .= " WHERE " . implode(" AND ", $count_conditions);
        }

        $count_stmt = $conn->prepare($count_sql);
        if ($count_stmt) {
            if (!empty($count_params)) {
                $count_stmt->bind_param($count_types, ...$count_params);
            }
            $count_stmt->execute();
            $count_result = $count_stmt->get_result();
            $count_row = $count_result->fetch_assoc();
            $total_count = (int) $count_row["total"];
            $count_stmt->close();
        }
    } else {
        $total_count = count($applications);
    }

    // Prepare response
    $response = [
        "success" => true,
        "data" => $applications,
        "total" => $total_count,
        "count" => count($applications),
    ];

    // Add pagination info if applicable
    if ($limit) {
        $response["pagination"] = [
            "limit" => $limit,
            "offset" => $offset,
            "has_more" => $offset + count($applications) < $total_count,
        ];
    }

    // Add filter info if applicable
    if ($status_filter || $search) {
        $response["filters"] = [
            "status" => $status_filter,
            "search" => $search,
        ];
    }

    echo json_encode($response);
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "error" => "Failed to fetch applications: " . $e->getMessage(),
        "data" => [],
        "total" => 0,
    ]);
}

$conn->close();
?>
