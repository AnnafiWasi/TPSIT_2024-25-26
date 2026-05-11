<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "../config/db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["error" => "Metodo non consentito"]);
    exit;
}

$body     = json_decode(file_get_contents("php://input"), true);
$tag      = trim($body["tag"]      ?? "");
$password = trim($body["password"] ?? "");

if ($tag === "" || $password === "") {
    http_response_code(400);
    echo json_encode(["error" => "Campi obbligatori"]);
    exit;
}

$tag = strtoupper($tag);
if ($tag[0] !== "#") $tag = "#" . $tag;

$stmt = mysqli_prepare($conn, "SELECT tag FROM users WHERE tag = ?");
mysqli_stmt_bind_param($stmt, "s", $tag);
mysqli_stmt_execute($stmt);
mysqli_stmt_store_result($stmt);

if (mysqli_stmt_num_rows($stmt) > 0) {
    http_response_code(409);
    echo json_encode(["error" => "Utente già esistente"]);
    exit;
}
mysqli_stmt_close($stmt);

$hashed = password_hash($password, PASSWORD_BCRYPT);
$stmt   = mysqli_prepare($conn, "INSERT INTO users(tag, password) VALUES(?, ?)");
mysqli_stmt_bind_param($stmt, "ss", $tag, $hashed);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["success" => true, "tag" => $tag]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Errore database"]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);