<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "../config/db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {

    http_response_code(405);

    echo json_encode([
        "error" => "Metodo non consentito"
    ]);

    exit;
}

$body = json_decode(file_get_contents("php://input"), true);

$user_tag = trim($body["user_tag"] ?? "");
$player_tag = trim($body["player_tag"] ?? "");

if ($user_tag == "" || $player_tag == "") {

    http_response_code(400);

    echo json_encode([
        "error" => "Campi obbligatori"
    ]);

    exit;
}

$user_tag = strtoupper($user_tag);
$player_tag = strtoupper($player_tag);

if ($user_tag[0] != "#") {
    $user_tag = "#" . $user_tag;
}

if ($player_tag[0] != "#") {
    $player_tag = "#" . $player_tag;
}

if ($user_tag == $player_tag) {

    http_response_code(400);

    echo json_encode([
        "error" => "Non puoi aggiungere te stesso"
    ]);

    exit;
}

$stmt = mysqli_prepare(
    $conn,
    "SELECT id
     FROM favorites
     WHERE user_tag = ?
     AND player_tag = ?"
);

mysqli_stmt_bind_param(
    $stmt,
    "ss",
    $user_tag,
    $player_tag
);

mysqli_stmt_execute($stmt);

mysqli_stmt_store_result($stmt);

if (mysqli_stmt_num_rows($stmt) > 0) {

    http_response_code(409);

    echo json_encode([
        "error" => "Già nei preferiti"
    ]);

    exit;
}

mysqli_stmt_close($stmt);

$stmt = mysqli_prepare(
    $conn,
    "INSERT INTO favorites(user_tag, player_tag)
     VALUES(?, ?)"
);

mysqli_stmt_bind_param(
    $stmt,
    "ss",
    $user_tag,
    $player_tag
);

if (mysqli_stmt_execute($stmt)) {

    echo json_encode([
        "success" => true
    ]);

} else {

    http_response_code(500);

    echo json_encode([
        "error" => "Errore database"
    ]);
}

mysqli_stmt_close($stmt);

mysqli_close($conn);