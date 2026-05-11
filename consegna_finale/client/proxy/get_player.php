<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

define(
    "BRAWL_API_TOKEN",
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjcyNDcwZDA5LTdhMDctNDZhZC1iZTIyLTczY2FmZWQ1ZWExNiIsImlhdCI6MTc3NDU5ODY1Miwic3ViIjoiZGV2ZWxvcGVyL2EwMTI3YTQ3LTYwMjgtZmZmOC1iMTAwLTFjYjk3Y2ViYmJhYSIsInNjb3BlcyI6WyJicmF3bHN0YXJzIl0sImxpbWl0cyI6W3sidGllciI6ImRldmVsb3Blci9zaWx2ZXIiLCJ0eXBlIjoidGhyb3R0bGluZyJ9LHsiY2lkcnMiOlsiMzcuMjA2LjE2LjE4MiIsIjkzLjYzLjEzOC4xNzAiLCIxNTEuOTUuMjQ3LjE0NCJdLCJ0eXBlIjoiY2xpZW50In1dfQ.C6RUpDKz0SOCybXbT5a66GqTU0YAnBw8xbFQXHAenkxM06mZLo_HEDrTf-IZYMRl5f5LA_y3a9JNnoPdGZ2TCA"
);

define(
    "BRAWL_API_BASE",
    "https://api.brawlstars.com/v1"
);

$player_tag = trim($_GET["player_tag"] ?? "");

if ($player_tag == "") {

    http_response_code(400);

    echo json_encode([
        "error" => "player_tag obbligatorio"
    ]);

    exit;
}

$player_tag = strtoupper($player_tag);

if ($player_tag[0] != "#") {
    $player_tag = "#" . $player_tag;
}

$encoded = urlencode($player_tag);

$url = BRAWL_API_BASE . "/players/" . $encoded;

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, $url);

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . BRAWL_API_TOKEN
]);

$response = curl_exec($ch);

$http = curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

http_response_code($http);

echo $response;