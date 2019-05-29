<?php
require_once('useful.php');

loadModel('Model_position');


$zoom = 3; // Fixed value

if(isset($_GET['update']) && $_GET['update']) {
    $x = $_GET['x'];
    $y = $_GET['y'];

    $requestURL = $LAMINAR_URL . 'tiles/' . $zoom . '/' . $x . '/' . $y . '/flights?user_key=' . $USER_KEY;

    $data['url_request'] = $requestURL;

    $allResult = makeJsonRequestToArray($requestURL)['features'];

    if(empty($allResult)) {
        $data['error_msg'] = 'Aucune donnée n\'a pu être récupérée (<a href="' . $requestURL . '">Tester la requête</a>)';
    } else {
        $data['nbrUpdate'] = 0;

        foreach ($allResult as $result) {
            // print_r($result);
            $properties = $result['properties'];

            $id = $result['id'];
            $position = $result['geometry']['coordinates'];
            $positionTime = $properties['positionReport']['captureTimestamp'];
            $transformPositionTime = date('Y-m-d H:i:s', strtotime($positionTime));

            if(isset($properties['airline'])) {
                $company = $properties['airline'];
            } else {
                $company = '';
            }

            // properties > positionReport > altitude
            if(isset($properties['positionReport']) && isset($properties['positionReport']['altitude'])) {
                $altitude = $properties['positionReport']['altitude'];
            }

            // if(isset($properties['departure'])) {
            //     $departTime = $properties['departure']['runwayTime']['actual'];
            //     $departPoint = $properties['departure']['aerodrome']['actual'];
            // } else {
            //     $departTime = '';
            //     $departPoint = '';
            // }
            // if(isset($properties['arrival'])) {
            //     $arrivalPoint = $properties['arrival']['aerodrome']['initial'];
            // } else {
            //     $arrivalPoint = '';
            // }
            
            $res = addPlanePositions($id, $position[0], $position[1], $transformPositionTime, $company);
            if($res == 1) {
                $data['nbrUpdate'] += 1;
            }
            // echo "Result: " . $res . "<br />";

        }
    }

}

$data['allPlanePosition'] = getLastPlanePositions();

loadHeader();
loadView('position', $data);
loadFooter();
?>
