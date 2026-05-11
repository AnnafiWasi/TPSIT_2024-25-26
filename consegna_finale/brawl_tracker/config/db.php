<?php

$host = "localhost";
$dbname = "brawl_tracker";
$user = "root";
$pass = "";

$conn = mysqli_connect($host, $user, $pass, $dbname);

if (!$conn) {
    http_response_code(500);

    echo json_encode([
        "error" => "Connessione database fallita"
    ]);

    exit;
}

mysqli_set_charset($conn, "utf8mb4");