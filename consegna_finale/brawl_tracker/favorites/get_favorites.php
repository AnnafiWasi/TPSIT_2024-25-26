<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "../config/db.php";

$user_tag = trim($_GET["user_tag"] ?? "");

if ($user_tag == "") {

    http_response_code(400);

    echo json_encode([
        "error" => "user_tag obbligatorio"
    ]);

    exit;
}

$user_tag = strtoupper($user_tag);

if ($user_tag[0] != "#") {
    $user_tag = "#" . $user_tag;
}

$stmt = mysqli_prepare(
    $conn,
    "SELECT id, player_tag
     FROM favorites
     WHERE user_tag = ?"
);

mysqli_stmt_bind_param($stmt, "s", $user_tag);

mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);

$favorites = [];

while ($row = mysqli_fetch_assoc($result)) {
    $favorites[] = $row;
}

echo json_encode([
    "success" => true,
    "favorites" => $favorites
]);

mysqli_stmt_close($stmt);

mysqli_close($conn);