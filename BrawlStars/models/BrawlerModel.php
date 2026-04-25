<?php
require_once __DIR__ . '/../config/Database.php';

$apiToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjcyNDcwZDA5LTdhMDctNDZhZC1iZTIyLTczY2FmZWQ1ZWExNiIsImlhdCI6MTc3NDU5ODY1Miwic3ViIjoiZGV2ZWxvcGVyL2EwMTI3YTQ3LTYwMjgtZmZmOC1iMTAwLTFjYjk3Y2ViYmJhYSIsInNjb3BlcyI6WyJicmF3bHN0YXJzIl0sImxpbWl0cyI6W3sidGllciI6ImRldmVsb3Blci9zaWx2ZXIiLCJ0eXBlIjoidGhyb3R0bGluZyJ9LHsiY2lkcnMiOlsiMzcuMjA2LjE2LjE4MiIsIjkzLjYzLjEzOC4xNzAiLCIxNTEuOTUuMjQ3LjE0NCJdLCJ0eXBlIjoiY2xpZW50In1dfQ.C6RUpDKz0SOCybXbT5a66GqTU0YAnBw8xbFQXHAenkxM06mZLo_HEDrTf-IZYMRl5f5LA_y3a9JNnoPdGZ2TCA';
$apiBase  = 'https://api.brawlstars.com/v1';

function apiGet($endpoint) {
    global $apiToken, $apiBase;
    $ch = curl_init($apiBase . $endpoint);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer ' . $apiToken, 'Accept: application/json']);
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($code !== 200) throw new Exception("Errore API HTTP $code: $body");
    return json_decode($body, true) ?? [];
}

function importBrawlersFromApi() {
    global $db;
    $json   = apiGet('/brawlers');
    $result = ['imported' => 0, 'errors' => []];
    if (!isset($json['items'])) { $result['errors'][] = 'Risposta API non valida.'; return $result; }
    foreach ($json['items'] as $b) {
        $stmt = $db->prepare("INSERT INTO brawlers (id, name) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)");
        $stmt->bind_param("is", $b['id'], $b['name']);
        $stmt->execute();
        $stmt->close();
        foreach ($b['starPowers'] ?? [] as $sp) {
            $stmt = $db->prepare("INSERT INTO starpowers (id, brawler_id, name) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)");
            $stmt->bind_param("iis", $sp['id'], $b['id'], $sp['name']);
            $stmt->execute();
            $stmt->close();
        }
        foreach ($b['gadgets'] ?? [] as $g) {
            $stmt = $db->prepare("INSERT INTO gadgets (id, brawler_id, name) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)");
            $stmt->bind_param("iis", $g['id'], $b['id'], $g['name']);
            $stmt->execute();
            $stmt->close();
        }
        $result['imported']++;
    }
    return $result;
}

function getAllBrawlers() {
    global $db;
    $brawlers = $db->query("SELECT * FROM brawlers ORDER BY name")->fetch_all(MYSQLI_ASSOC);
    foreach ($brawlers as &$b) {
        $b['starpowers'] = getStarpowersFor($b['id']);
        $b['gadgets']    = getGadgetsFor($b['id']);
    }
    return $brawlers;
}

function getBrawlerById($id) {
    global $db;
    $stmt = $db->prepare("SELECT * FROM brawlers WHERE id = ? LIMIT 1");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    if (!$row) return null;
    $row['starpowers'] = getStarpowersFor($id);
    $row['gadgets']    = getGadgetsFor($id);
    return $row;
}

function getStarpowersFor($brawlerId) {
    global $db;
    $stmt = $db->prepare("SELECT id, name FROM starpowers WHERE brawler_id = ? ORDER BY name");
    $stmt->bind_param("i", $brawlerId);
    $stmt->execute();
    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $stmt->close();
    return $rows;
}

function getGadgetsFor($brawlerId) {
    global $db;
    $stmt = $db->prepare("SELECT id, name FROM gadgets WHERE brawler_id = ? ORDER BY name");
    $stmt->bind_param("i", $brawlerId);
    $stmt->execute();
    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $stmt->close();
    return $rows;
}

function getClubMembers($clubTag) {
    $clubData    = apiGet('/clubs/' . urlencode($clubTag));
    $membersData = apiGet('/clubs/' . urlencode($clubTag) . '/members');
    return [
        'club'    => ['name' => $clubData['name'] ?? '', 'tag' => $clubData['tag'] ?? $clubTag, 'trophies' => $clubData['trophies'] ?? 0, 'type' => $clubData['type'] ?? ''],
        'members' => $membersData['items'] ?? $clubData['members'] ?? [],
    ];
}