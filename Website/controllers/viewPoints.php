<?php
// Controller
require_once('useful.php');

// Database mta
loadModel('Model_bus_route');
$data['allBusRoute'] = get_all_bus_route();

// Other Database
pg_pconnect("host=127.0.0.1 dbname=mta_postgresql user=mtauser password=x1Kokzgfarz67fcU");

$customRequest = 'SELECT *, ST_AsGeoJSON(getValues(trip)) AS tripJson FROM "busTrip" ORDER BY start_date ASC LIMIT 5';
$data['busTrip'] = bdd_query($customRequest);

$customRequest = 'SELECT *, ST_AsGeoJSON(getValues(trip)) AS tripJson FROM "busTripClean5" ORDER BY start_date ASC LIMIT 5';
$data['busTripClean5'] = bdd_query($customRequest);

$customRequest = 'SELECT *, ST_AsGeoJSON(getValues(trip)) AS tripJson FROM "busTripClean10" ORDER BY start_date ASC LIMIT 5';
$data['busTripClean10'] = bdd_query($customRequest);

$customRequest = 'SELECT *, ST_AsGeoJSON(getValues(trip)) AS tripJson FROM "busTripClean15" ORDER BY start_date ASC LIMIT 5';
$data['busTripClean15'] = bdd_query($customRequest);


// $data['busPosition'] = getBusPosition(50);

$data['ligneBus'] = array();
foreach ($data['busTrip'] as $busInfo) {
    if(!in_array($busInfo['route_id'], $data['ligneBus'])) {
        $data['ligneBus'][] = $busInfo['route_id'];
    }
}

loadHeader();
// echo '<pre>';
// print_r($data['busTripClean']);
// echo '</pre>';
loadView('map', $data);
loadFooter();
?>
