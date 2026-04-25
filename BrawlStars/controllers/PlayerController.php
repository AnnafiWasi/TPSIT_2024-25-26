<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../models/UserModel.php';

$apiToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjcyNDcwZDA5LTdhMDctNDZhZC1iZTIyLTczY2FmZWQ1ZWExNiIsImlhdCI6MTc3NDU5ODY1Miwic3ViIjoiZGV2ZWxvcGVyL2EwMTI3YTQ3LTYwMjgtZmZmOC1iMTAwLTFjYjk3Y2ViYmJhYSIsInNjb3BlcyI6WyJicmF3bHN0YXJzIl0sImxpbWl0cyI6W3sidGllciI6ImRldmVsb3Blci9zaWx2ZXIiLCJ0eXBlIjoidGhyb3R0bGluZyJ9LHsiY2lkcnMiOlsiMzcuMjA2LjE2LjE4MiIsIjkzLjYzLjEzOC4xNzAiLCIxNTEuOTUuMjQ3LjE0NCJdLCJ0eXBlIjoiY2xpZW50In1dfQ.C6RUpDKz0SOCybXbT5a66GqTU0YAnBw8xbFQXHAenkxM06mZLo_HEDrTf-IZYMRl5f5LA_y3a9JNnoPdGZ2TCA';
$apiBase  = 'https://api.brawlstars.com/v1';

function normalizeTag($tag) {
    $tag = strtoupper(trim(str_replace(' ', '', $tag)));
    if (empty($tag)) throw new Exception("Tag non inserito.");
    if ($tag[0] !== '#') $tag = '#' . $tag;
    return $tag;
}

function fetchPlayerFromApi($tag) {
    global $apiToken, $apiBase;

    $tag = normalizeTag($tag);

    $url = $apiBase . '/players/' . urlencode($tag);
    $ch  = curl_init($url);

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $apiToken,
        'Accept: application/json'
    ]);

    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        $err = curl_error($ch);
        curl_close($ch);
        throw new Exception("Errore cURL: $err");
    }

    curl_close($ch);

    if ($code !== 200) {
        $msg = json_decode($body, true)['reason'] ?? 'Errore sconosciuto';
        throw new Exception("Errore API $code: $msg");
    }

    return json_decode($body, true);
}

function searchPlayer($tag) {
    $tag  = normalizeTag($tag);
    $data = fetchPlayerFromApi($tag);
    upsertUser($data);
    return $data;
}

function login($tag) {
    session_start();

    $player = searchPlayer($tag);

    $_SESSION['user_tag']  = normalizeTag($player['tag']);
    $_SESSION['user_name'] = $player['name'];

    return $player;
}

function logout() {
    session_start();
    session_destroy();
}

function currentUser() {
    if (session_status() === PHP_SESSION_NONE) session_start();
    if (empty($_SESSION['user_tag'])) return null;

    return [
        'tag' => $_SESSION['user_tag'],
        'name' => $_SESSION['user_name']
    ];
}

function followPlayer($myTag, $targetTag) {
    $myTag = normalizeTag($myTag);
    $targetTag = normalizeTag($targetTag);

    searchPlayer($targetTag);

    $followed = followUser($myTag, $targetTag);

    return [
        'success' => true,
        'message' => $followed ? 'Giocatore aggiunto ai preferiti.' : 'Già nei preferiti.'
    ];
}

function unfollowPlayer($myTag, $targetTag) {
    $myTag = normalizeTag($myTag);
    $targetTag = normalizeTag($targetTag);

    $removed = unfollowUser($myTag, $targetTag);

    return [
        'success' => true,
        'message' => $removed ? 'Giocatore rimosso dai preferiti.' : 'Non era nei preferiti.'
    ];
}

function getFollowingList($myTag) {
    $myTag = normalizeTag($myTag);
    return getFollowing($myTag);
}