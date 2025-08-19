<?php
// Database credentials
$servername = "localhost"; // or your db host
$username = "ammar";
$password = "123";
$dbname = "imageboard";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection for errors
if ($conn->connect_error) {
    // Stop script execution and report the error
    die("Connection failed: " . $conn->connect_error);
}

// Optional: Set character set to utf8
$conn->set_charset("utf8");
?>
