<?php
require_once __DIR__ . '/../config/Database.php';

/**
 * IMPORTANTE:
 * usa SEMPRE normalizeTag prima di chiamare queste funzioni
 */

function findUserByTag($tag) {
    global $db;

    $stmt = $db->prepare("SELECT * FROM users WHERE tag = ? LIMIT 1");
    $stmt->bind_param("s", $tag);
    $stmt->execute();

    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    return $row ?: null;
}

function upsertUser($data) {
    global $db;

    $tag = strtoupper(trim($data['tag']));
    if ($tag[0] !== '#') $tag = '#' . $tag;

    $name               = $data['name'];
    $trophies           = (int)($data['trophies'] ?? 0);
    $highestTrophies    = (int)($data['highestTrophies'] ?? 0);
    $totalPrestigeLevel = (int)($data['totalPrestigeLevel'] ?? 0);
    $expLevel           = (int)($data['expLevel'] ?? 0);
    $victories_3vs3     = (int)($data['3vs3Victories'] ?? $data['victories_3vs3'] ?? 0);
    $soloVictories      = (int)($data['soloVictories'] ?? 0);
    $duoVictories       = (int)($data['duoVictories'] ?? 0);

    $clubName = null;
    $clubTag  = null;

    if (!empty($data['club'])) {
        if (is_array($data['club'])) {
            $clubName = $data['club']['name'] ?? null;
            $clubTag  = $data['club']['tag']  ?? null;
        } else {
            $clubName = $data['club'];
        }
    }

    $sql = "INSERT INTO users 
        (tag, name, trophies, highestTrophies, totalPrestigeLevel, expLevel, victories_3vs3, soloVictories, duoVictories, club, club_tag)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            trophies = VALUES(trophies),
            highestTrophies = VALUES(highestTrophies),
            totalPrestigeLevel = VALUES(totalPrestigeLevel),
            expLevel = VALUES(expLevel),
            victories_3vs3 = VALUES(victories_3vs3),
            soloVictories = VALUES(soloVictories),
            duoVictories = VALUES(duoVictories),
            club = VALUES(club),
            club_tag = VALUES(club_tag)";

    $stmt = $db->prepare($sql);
    $stmt->bind_param(
        "ssiiiiiiiss",
        $tag,
        $name,
        $trophies,
        $highestTrophies,
        $totalPrestigeLevel,
        $expLevel,
        $victories_3vs3,
        $soloVictories,
        $duoVictories,
        $clubName,
        $clubTag
    );

    $stmt->execute();
    $stmt->close();

    return $tag;
}

function followUser($myTag, $targetTag) {
    global $db;

    if ($myTag === $targetTag) {
        throw new Exception("Non puoi seguire te stesso.");
    }

    if (!findUserByTag($myTag) || !findUserByTag($targetTag)) {
        throw new Exception("Tag non trovato.");
    }

    $stmt = $db->prepare("INSERT IGNORE INTO user_follows (my_tag, tag_followed) VALUES (?, ?)");
    $stmt->bind_param("ss", $myTag, $targetTag);
    $stmt->execute();

    $newRows = $stmt->affected_rows;
    $stmt->close();

    return $newRows > 0;
}

function unfollowUser($myTag, $targetTag) {
    global $db;

    $stmt = $db->prepare("DELETE FROM user_follows WHERE my_tag = ? AND tag_followed = ?");
    $stmt->bind_param("ss", $myTag, $targetTag);
    $stmt->execute();

    $deleted = $stmt->affected_rows;
    $stmt->close();

    return $deleted > 0;
}

function getFollowing($myTag) {
    global $db;

    $stmt = $db->prepare("
        SELECT u.*, uf.created_at AS followed_at
        FROM user_follows uf
        JOIN users u ON u.tag = uf.tag_followed
        WHERE uf.my_tag = ?
        ORDER BY uf.created_at DESC
    ");

    $stmt->bind_param("s", $myTag);
    $stmt->execute();

    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $stmt->close();

    return $rows;
}

function isFollowing($myTag, $targetTag) {
    global $db;

    $stmt = $db->prepare("SELECT 1 FROM user_follows WHERE my_tag = ? AND tag_followed = ? LIMIT 1");
    $stmt->bind_param("ss", $myTag, $targetTag);
    $stmt->execute();

    $found = $stmt->get_result()->num_rows > 0;
    $stmt->close();

    return $found;
}