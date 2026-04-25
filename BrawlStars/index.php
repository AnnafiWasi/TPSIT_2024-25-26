<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/config/Database.php';
require_once __DIR__ . '/models/UserModel.php';
require_once __DIR__ . '/models/BrawlerModel.php';
require_once __DIR__ . '/models/BuildModel.php';
require_once __DIR__ . '/controllers/PlayerController.php';
require_once __DIR__ . '/controllers/BuildController.php';

header('Content-Type: application/json; charset=utf-8');

$action = $_GET['action'] ?? $_POST['action'] ?? '';

function respond($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

try {
    switch ($action) {

        case 'login':
            $player = login($_GET['tag'] ?? '');
            respond(['success' => true, 'player' => $player]);
            break;

        case 'logout':
            logout();
            respond(['success' => true, 'message' => 'Logout effettuato.']);
            break;

        case 'search':
            $player = searchPlayer($_GET['tag'] ?? '');
            respond(['success' => true, 'player' => $player]);
            break;

        case 'follow':
            respond(followPlayer($_POST['my_tag'] ?? '', $_POST['target_tag'] ?? ''));
            break;

        case 'unfollow':
            respond(unfollowPlayer($_POST['my_tag'] ?? '', $_POST['target_tag'] ?? ''));
            break;

        case 'following':
            respond(['success' => true, 'following' => getFollowingList($_GET['tag'] ?? '')]);
            break;

        case 'import_brawlers':
            respond(['success' => true, 'result' => importBrawlersFromApi()]);
            break;

        case 'brawlers':
            respond(['success' => true, 'brawlers' => getAllBrawlers()]);
            break;

        case 'brawler':
            $b = getBrawlerById((int)($_GET['id'] ?? 0));
            if (!$b) respond(['success' => false, 'message' => 'Brawler non trovato.'], 404);
            respond(['success' => true, 'brawler' => $b]);
            break;

        case 'club_members':
            $result = getClubMembers($_GET['tag'] ?? '');
            respond(['success' => true, 'club' => $result['club'], 'members' => $result['members']]);
            break;

        case 'save_build':
            $res = saveBuildForUser(
                (int)($_POST['brawler_id'] ?? 0),
                isset($_POST['starpower_id']) ? (int)$_POST['starpower_id'] : null,
                isset($_POST['gadget_id'])    ? (int)$_POST['gadget_id']    : null
            );
            respond($res, $res['success'] ? 200 : 400);
            break;

        case 'remove_build':
            $res = removeBuildForUser((int)($_POST['combination_id'] ?? 0));
            respond($res, $res['success'] ? 200 : 400);
            break;

        case 'my_builds':
            respond(['success' => true, 'builds' => myBuilds()]);
            break;

        case 'top_builds':
            respond(['success' => true, 'builds' => topBuilds((int)($_GET['limit'] ?? 10))]);
            break;

        default:
            respond(['success' => false, 'message' => 'Azione non riconosciuta.'], 400);
    }

} catch (Exception $e) {
    respond(['success' => false, 'message' => $e->getMessage()], 500);
}