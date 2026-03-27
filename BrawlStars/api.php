<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

if (!isset($_GET['tag']) || empty($_GET['tag'])) {
    die("Nessun tag inserito.");
}

$token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjcyNDcwZDA5LTdhMDctNDZhZC1iZTIyLTczY2FmZWQ1ZWExNiIsImlhdCI6MTc3NDU5ODY1Miwic3ViIjoiZGV2ZWxvcGVyL2EwMTI3YTQ3LTYwMjgtZmZmOC1iMTAwLTFjYjk3Y2ViYmJhYSIsInNjb3BlcyI6WyJicmF3bHN0YXJzIl0sImxpbWl0cyI6W3sidGllciI6ImRldmVsb3Blci9zaWx2ZXIiLCJ0eXBlIjoidGhyb3R0bGluZyJ9LHsiY2lkcnMiOlsiMzcuMjA2LjE2LjE4MiIsIjkzLjYzLjEzOC4xNzAiLCIxNTEuOTUuMjQ3LjE0NCJdLCJ0eXBlIjoiY2xpZW50In1dfQ.C6RUpDKz0SOCybXbT5a66GqTU0YAnBw8xbFQXHAenkxM06mZLo_HEDrTf-IZYMRl5f5LA_y3a9JNnoPdGZ2TCA";
$playerTag = urlencode($_GET['tag']);

$url = "https://api.brawlstars.com/v1/players/" . $playerTag;

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer $token",
    "Accept: application/json"
]);

$response = curl_exec($ch);
if(curl_errno($ch)) {
    die("Errore cURL: " . curl_error($ch));
}
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if($httpCode !== 200) {
    echo "Errore API (HTTP $httpCode)<br>";
    echo "<pre>$response</pre>";
    exit;
}

$data = json_decode($response, true);

echo "<div style='font-family: Arial; padding:20px; background:#111; color:#fff; width:300px; border-radius:10px;'>";
echo "<h2>" . htmlspecialchars($data['name']) . "</h2>";
echo "<p>Tag: " . htmlspecialchars($data['tag']) . "</p>";
echo "<p>Trophies: " . $data['trophies'] . "</p>";
echo "<p>Highest Trophies: " . $data['highestTrophies'] . "</p>";
echo "<p>Total Prestige Level: " . $data['totalPrestigeLevel'] . "</p>";
echo "<p>Exp Level: " . $data['expLevel'] . "</p>";
echo "<p>3vs3 Victories: " . $data['3vs3Victories'] . "</p>";
echo "<p>Solo Victories: " . $data['soloVictories'] . "</p>";
echo "<p>Duo Victories: " . $data['duoVictories'] . "</p>";
echo "<p>Club: " . ($data['club']['name'] ?? "Nessun club") . "</p>";
echo "</div>";

echo "<form method='post' action='database.php'>";
foreach (['tag','name','trophies','highestTrophies','totalPrestigeLevel','expLevel','victories_3vs3','soloVictories','duoVictories'] as $field) {
    echo "<input type='hidden' name='$field' value='" . htmlspecialchars($data[$field] ?? 0) . "'>";
}
echo "<input type='hidden' name='clubName' value='" . htmlspecialchars($data['club']['name'] ?? "") . "'>";
echo "<button type='submit' style='margin-top:10px; padding:5px 10px;'>Salva nel DB</button>";
echo "</form>";
?>