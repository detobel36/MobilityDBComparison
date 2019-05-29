<?php
// Controller
require_once('useful.php');

// Database mta
loadModel('Model_bus_route');
$data['allBusRoute'] = get_all_bus_route();

// Other Database
pg_pconnect("host=127.0.0.1 dbname=mta_postgresql user=mtauser_readonly password=wr8qudd3wplrv874");

$data['allRequest'] = array();

/*
json_point
json_line
description
bus_line
*/

$compteur = 1;
while(isset($_POST['request' . $compteur])) {
    if($_POST['request' . $compteur] != "") {
        $data['allRequest'][] = array(
            'query' => $_POST['request' . $compteur],
            'result' => '',
            'color' => $_POST['reqColor' . $compteur],
            'type' => array()
        );
    }

    $compteur += 1;
}

if(count($data['allRequest']) == 0) {
    $data['allRequest'][] = array(
            'query' => 'SELECT route_id AS bus_line, route_id || \' (\' || direction_id || \')\' AS description, ST_AsGeoJSON(getValues(trip)) AS json_line, ST_AsGeoJSON(getValues(trip)) AS json_point 
FROM "busTrip" ORDER BY start_date ASC LIMIT 5;',
            'result' => '',
            'color' => '#808080',
            'type' => array()
        );

    $data['allRequest'][] = array(
            'query' => 'SELECT route_id AS bus_line, \'Points 5m\' AS description, ST_AsGeoJSON(getValues(trip)) AS json_point 
FROM "busTripClean5" ORDER BY start_date ASC LIMIT 5;',
            'result' => '',
            'color' => '#008000',
            'type' => array()
        );

    $data['allRequest'][] = array(
            'query' => 'SELECT route_id AS bus_line, \'Points 10m\' AS description, ST_AsGeoJSON(getValues(trip)) AS json_point 
FROM "busTripClean10" ORDER BY start_date ASC LIMIT 5;',
            'result' => '',
            'color' => '#ff00eb',
            'type' => array()
        );

    $data['allRequest'][] = array(
            'query' => 'SELECT route_id AS bus_line, \'Points 15m\' AS description, ST_AsGeoJSON(getValues(trip)) AS json_point 
FROM "busTripClean15" ORDER BY start_date ASC LIMIT 5;',
            'result' => '',
            'color' => '#0095fe',
            'type' => array()
        );
}


foreach ($data['allRequest'] as &$request) {
    $request['result'] = bdd_query($request['query']);
}


$data['ligneBus'] = array();
foreach ($data['allRequest'] as &$request) {
    if(isset($request['result']) && !empty($request['result'])) {
        foreach($request['result'] as $oneResult) {
            if(isset($oneResult['bus_line']) && !in_array($oneResult['bus_line'], $data['ligneBus'])) {
                $data['ligneBus'][] = $oneResult['bus_line'];
            }

            if(isset($oneResult['json_line'])) {
                $request['type'][] = 'Line';
            }
            if(isset($oneResult['json_point'])) {
                $request['type'][] = 'Point';
            }
        }
    }
}

// $customRequest = ;
// $data['busTripClean5'] = bdd_query($customRequest);

// $customRequest = 'SELECT *, ST_AsGeoJSON(getValues(trip)) AS tripJson FROM "busTripClean10" ORDER BY start_date ASC LIMIT 5';
// $data['busTripClean10'] = bdd_query($customRequest);

// $customRequest = ;
// $data['busTripClean15'] = bdd_query($customRequest);


// $data['busPosition'] = getBusPosition(50);

// foreach ($data['busTrip'] as $busInfo) {
//     if(!in_array($busInfo['route_id'], $data['ligneBus'])) {
//         $data['ligneBus'][] = $busInfo['route_id'];
//     }
// }

loadHeader();
// echo '<pre>';
// print_r($data['busTripClean']);
// echo '</pre>';
loadView('mapCustom', $data);
loadFooter();
?>
