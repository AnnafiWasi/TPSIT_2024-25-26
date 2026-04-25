<?php
require_once __DIR__ . '/../config/Database.php';

function findCombination($brawlerId, $starpowerId, $gadgetId) {
    global $db;
    $spCond = $starpowerId === null ? "starpower_id IS NULL" : "starpower_id = ?";
    $gCond  = $gadgetId    === null ? "gadget_id IS NULL"    : "gadget_id = ?";
    $stmt = $db->prepare("SELECT id FROM brawler_build_combination WHERE brawler_id = ? AND $spCond AND $gCond LIMIT 1");
    if ($starpowerId !== null && $gadgetId !== null) $stmt->bind_param("iii", $brawlerId, $starpowerId, $gadgetId);
    elseif ($starpowerId !== null)                   $stmt->bind_param("ii",  $brawlerId, $starpowerId);
    elseif ($gadgetId !== null)                      $stmt->bind_param("ii",  $brawlerId, $gadgetId);
    else                                             $stmt->bind_param("i",   $brawlerId);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    return $row ? (int)$row['id'] : null;
}

function createCombination($brawlerId, $starpowerId, $gadgetId) {
    global $db;
    $stmt = $db->prepare("INSERT INTO brawler_build_combination (brawler_id, starpower_id, gadget_id) VALUES (?, ?, ?)");
    $stmt->bind_param("iii", $brawlerId, $starpowerId, $gadgetId);
    $stmt->execute();
    $newId = $db->insert_id;
    $stmt->close();
    return $newId;
}

function saveBuild($userTag, $brawlerId, $starpowerId = null, $gadgetId = null) {
    global $db;
    $comboId    = findCombination($brawlerId, $starpowerId, $gadgetId);
    $isNewCombo = false;
    if ($comboId === null) {
        $comboId    = createCombination($brawlerId, $starpowerId, $gadgetId);
        $isNewCombo = true;
    }
    $stmt = $db->prepare("INSERT IGNORE INTO user_combination (user_tag, combination_id) VALUES (?, ?)");
    $stmt->bind_param("si", $userTag, $comboId);
    $stmt->execute();
    $isNewForUser = $stmt->affected_rows > 0;
    $stmt->close();
    return ['combination_id' => $comboId, 'is_new_combo' => $isNewCombo, 'is_new_for_user' => $isNewForUser];
}

function removeBuild($userTag, $combinationId) {
    global $db;
    $stmt = $db->prepare("DELETE FROM user_combination WHERE user_tag = ? AND combination_id = ?");
    $stmt->bind_param("si", $userTag, $combinationId);
    $stmt->execute();
    $deleted = $stmt->affected_rows;
    $stmt->close();
    return $deleted > 0;
}

function getUserBuilds($userTag) {
    global $db;
    $stmt = $db->prepare("SELECT uc.combination_id, uc.saved_at, b.id AS brawler_id, b.name AS brawler_name, sp.id AS starpower_id, sp.name AS starpower_name, g.id AS gadget_id, g.name AS gadget_name FROM user_combination uc JOIN brawler_build_combination bbc ON bbc.id = uc.combination_id JOIN brawlers b ON b.id = bbc.brawler_id LEFT JOIN starpowers sp ON sp.id = bbc.starpower_id LEFT JOIN gadgets g ON g.id = bbc.gadget_id WHERE uc.user_tag = ? ORDER BY uc.saved_at DESC");
    $stmt->bind_param("s", $userTag);
    $stmt->execute();
    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $stmt->close();
    return $rows;
}

function getTopBuilds($limit = 10) {
    global $db;
    $stmt = $db->prepare("SELECT bbc.id AS combination_id, COUNT(uc.user_tag) AS users_count, b.name AS brawler_name, sp.name AS starpower_name, g.name AS gadget_name FROM brawler_build_combination bbc JOIN brawlers b ON b.id = bbc.brawler_id LEFT JOIN starpowers sp ON sp.id = bbc.starpower_id LEFT JOIN gadgets g ON g.id = bbc.gadget_id LEFT JOIN user_combination uc ON uc.combination_id = bbc.id GROUP BY bbc.id ORDER BY users_count DESC LIMIT ?");
    $stmt->bind_param("i", $limit);
    $stmt->execute();
    $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $stmt->close();
    return $rows;
}