<?php
require_once __DIR__ . '/../models/BuildModel.php';
require_once __DIR__ . '/../controllers/PlayerController.php';

function saveBuildForUser($brawlerId, $starpowerId, $gadgetId) {
    $user = currentUser();
    
    if (!$user) {
        return ['success' => false, 'message' => 'Non sei loggato.'];
    }
    
    $result = saveBuild($user['tag'], $brawlerId, $starpowerId, $gadgetId);
    
    if ($result['is_new_for_user']) {
        $messaggio = 'Build salvata!';
    } else {
        $messaggio = 'Hai già questa build salvata.';
    }
    
    return array_merge($result, ['success' => true, 'message' => $messaggio]);
}

function removeBuildForUser($combinationId) {
    $user = currentUser();
    
    if (!$user) {
        return ['success' => false, 'message' => 'Non sei loggato.'];
    }
    
    $rimossa = removeBuild($user['tag'], $combinationId);
    
    if ($rimossa) {
        return ['success' => true, 'message' => 'Build rimossa.'];
    } else {
        return ['success' => false, 'message' => 'Build non trovata.'];
    }
}

function myBuilds() {
    $user = currentUser();
    
    if ($user) {
        return getUserBuilds($user['tag']);
    } else {
        return [];
    }
}

function topBuilds($limit = 10) {
    return getTopBuilds($limit);
}