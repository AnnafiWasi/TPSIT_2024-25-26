<?php
$db = new mysqli('localhost', 'root', '', 'brawlstars');

if ($db->connect_error) {
    die("Errore di connessione: " . $db->connect_error);
}

$db->set_charset('utf8mb4');
