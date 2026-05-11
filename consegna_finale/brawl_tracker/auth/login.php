<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "../config/db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["error" => "Metodo non consentito"]);
    exit;
}

$body = json_decode(file_get_contents("php://input"), true);

$tag      = trim($body["tag"]      ?? "");
$password = trim($body["password"] ?? "");

if ($tag === "" || $password === "") {
    http_response_code(400);
    echo json_encode(["error" => "Campi obbligatori"]);
    exit;
}

$tag = strtoupper($tag);
if ($tag[0] !== "#") $tag = "#" . $tag;

$stmt = mysqli_prepare($conn, "SELECT tag, password FROM users WHERE tag = ?");
mysqli_stmt_bind_param($stmt, "s", $tag);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$user   = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt);

if (!$user || !password_verify($password, $user["password"])) {
    http_response_code(401);
    echo json_encode(["error" => "Credenziali non valide"]);
    exit;
}

echo json_encode(["success" => true, "tag" => $user["tag"]]);

mysqli_close($conn);