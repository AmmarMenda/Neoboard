<?php
// router.php
header("Access-Control-Allow-Origin: http://127.0.0.1:5678");
// Get the requested path
$path = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);

// Sanitize the path to prevent directory traversal attacks
$path = realpath(__DIR__ . $path);

// Check if the requested path is a file and exists
if ($path && is_file($path)) {
    // Check the file extension to serve it with the correct MIME type
    $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
    $mimes = [
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'css' => 'text/css',
        'js' => 'application/javascript'
    ];

    if (isset($mimes[$extension])) {
        header('Content-Type: ' . $mimes[$extension]);
    }
    
    // Serve the file directly
    readfile($path);
    return; // Stop the script
}

// If it's not a static file, maybe it's an API endpoint.
// This part requires you to route requests to your API files.
// For simplicity, we can assume the request directly maps to a file in the /api directory.
$api_file = __DIR__ . '/api' . parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);
if(file_exists($api_file) && is_file($api_file)){
    require $api_file;
    return;
}


// If the file is not found, return a 404 response
http_response_code(404);
echo "404 Not Found";
?>
