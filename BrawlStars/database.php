<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

$host = "localhost";
$user = "root";
$password = ""; 
$dbname = "brawlstars";

$conn = new mysqli($host, $user, $password, $dbname);
if ($conn->connect_error) {
    die("Connessione fallita: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['tag'])) {
    $tag = $conn->real_escape_string($_POST['tag']);
    $name = $conn->real_escape_string($_POST['name']);
    $trophies = (int)$_POST['trophies'];
    $highestTrophies = (int)$_POST['highestTrophies'];
    $totalPrestigeLevel = (int)$_POST['totalPrestigeLevel'];
    $expLevel = (int)$_POST['expLevel'];
    $victories_3vs3 = (int)$_POST['victories_3vs3'];
    $soloVictories = (int)$_POST['soloVictories'];
    $duoVictories = (int)$_POST['duoVictories'];
    $clubName = !empty($_POST['clubName']) ? $conn->real_escape_string($_POST['clubName']) : NULL;

    $sql = "INSERT INTO players (tag, name, trophies, highestTrophies, totalPrestigeLevel, expLevel, victories_3vs3, soloVictories, duoVictories, clubName)
            VALUES ('$tag', '$name', $trophies, $highestTrophies, $totalPrestigeLevel, $expLevel, $victories_3vs3, $soloVictories, $duoVictories, ".($clubName ? "'$clubName'" : "NULL").")
            ON DUPLICATE KEY UPDATE
                name='$name', trophies=$trophies, highestTrophies=$highestTrophies,
                totalPrestigeLevel=$totalPrestigeLevel, expLevel=$expLevel,
                victories_3vs3=$victories_3vs3, soloVictories=$soloVictories, duoVictories=$duoVictories,
                clubName=".($clubName ? "'$clubName'" : "NULL").", last_update=NOW()";

    if ($conn->query($sql) === TRUE) {
        echo "<p>Player salvato con successo nel database!</p>";
    } else {
        echo "Errore salvataggio: " . $conn->error;
    }

    echo "<p><a href='index.html'>Torna alla ricerca</a></p>";
} else {
    echo "<p>Nessun dato ricevuto.</p>";
}
?>