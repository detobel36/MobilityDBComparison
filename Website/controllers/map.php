<?php
// Controller
require_once('useful.php');

loadModel('Model_bus_route');
loadModel('Model_position');


$data['allBusRoute'] = get_all_bus_route();
$data['busPosition'] = getBusPosition(50);

$data['ligneBus'] = array();
foreach ($data['busPosition'] as $busInfo) {
    if(!in_array($busInfo['route_id'], $data['ligneBus'])) {
        $data['ligneBus'][] = $busInfo['route_id'];
    }
}

loadHeader();
loadView('map', $data);
loadFooter();
?>
