<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "../config/db.php";

$method = $_SERVER["REQUEST_METHOD"];

if ($method !== "PUT" && $method !== "PATCH") {
    http_response_code(405);
    echo json_encode(["error" => "Metodo non consentito"]);
    exit;
}

$body         = json_decode(file_get_contents("php://input"), true);
$tag          = trim($body["tag"]          ?? "");
$password     = trim($body["password"]     ?? "");
$new_password = trim($body["new_password"] ?? "");

if ($tag === "" || $password === "") {
    http_response_code(400);
    echo json_encode(["error" => "tag e password obbligatori"]);
    exit;
}

$tag = strtoupper($tag);
if ($tag[0] !== "#") $tag = "#" . $tag;

$stmt = mysqli_prepare($conn,
    "SELECT tag, password FROM users WHERE tag = ?");
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

if ($new_password === "") {
    http_response_code(400);
    echo json_encode(["error" => "new_password obbligatoria"]);
    exit;
}

if ($method === "PATCH") {
    // PATCH → aggiorna solo la password
    $hashed = password_hash($new_password, PASSWORD_BCRYPT);
    $stmt   = mysqli_prepare($conn,
        "UPDATE users SET password = ? WHERE tag = ?");
    mysqli_stmt_bind_param($stmt, "ss", $hashed, $tag);

} else {
    // PUT → aggiorna tag e password
    $new_tag = trim($body["new_tag"] ?? "");
    if ($new_tag === "") {
        http_response_code(400);
        echo json_encode(["error" => "new_tag obbligatorio per PUT"]);
        exit;
    }
    $new_tag = strtoupper($new_tag);
    if ($new_tag[0] !== "#") $new_tag = "#" . $new_tag;

    $hashed = password_hash($new_password, PASSWORD_BCRYPT);
    $stmt   = mysqli_prepare($conn,
        "UPDATE users SET tag = ?, password = ? WHERE tag = ?");
    mysqli_stmt_bind_param($stmt, "sss", $new_tag, $hashed, $tag);
}

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["success" => true]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Errore database"]);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);