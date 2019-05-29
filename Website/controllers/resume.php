<?php
require_once('useful.php');

// Stats
// loadModel('Model_trains');
// loadModel('Model_stations');

// $data['nbrStations'] = getNbrStations();
// $data['nbrTrains'] = getNbrTrains(date('Y-m-d'));

loadHeader();
loadView('resume', $data);
loadFooter();
?>

