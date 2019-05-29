<?php
require_once('useful.php');

loadModel('Model_all_plane');


$zoom = 3; // DEFAULT VALUE (mandatory by the API)
$X = 4;
$Y = 1;

function printLog($type, $message) {
    echo date('Y/m/d H:i:s') . ' [' . $type . '] ' . $message . "<br />\n";
}

function printLogError($message) {
    printLog('ERROR', $message);
}

function printLogInfo($message) {
    printLog('INFO', $message);
}

printLogInfo("Appel du fichier !");

function getIfExist($data, $key) {
    if(is_array($key)) {
        foreach ($key as $elem) {
            if(isset($data[$elem])) {
                $data = $data[$elem];
            } else {
                return 'NULL';
            }
        }
        return $data;
    } else if(isset($data[$key])) {
        return $data[$key];
    }
    return 'NULL';
}

$requestURL = $LAMINAR_URL . 'tiles/' . $zoom . '/' . $X . '/' . $Y . '/flights?user_key=' . $USER_KEY;
$allResult = makeJsonRequestToArray($requestURL)['features'];

if(empty($allResult)) {
    printLogError("No result !");
    // TODO ajouter un système de log 
} else {
    
    $nbrUpdate = 0;

    foreach ($allResult as $result) {
        // echo "Get:<br /><pre>";
        // print_r($result); // DEBUG
        // echo "</pre><br /><br />";

        $id = $result['id'];
        $position = getIfExist($result, array('geometry', 'coordinates'));
        $position_x = $position[0];
        $position_y = $position[1];
        $airline = getIfExist($result, array('properties', 'airline'));
        $callsign = getIfExist($result, array('properties', 'callsign'));
        $flightStatus = getIfExist($result, array('properties', 'flightStatus'));
        $iataFlightNumber = getIfExist($result, array('properties', 'iataFlightNumber'));
        $timestampProcessed = getIfExist($result, array('properties', 'timestampProcessed'));
        $flightPlanTimestamp = getIfExist($result, array('properties', 'flightPlanTimestamp'));
        // Departure
        $departure_aerodrome_actual = getIfExist($result, array('properties', 'departure', 'aerodrome', 'actual'));
        $departure_aerodrome_scheduled = getIfExist($result, array('properties', 'departure', 'aerodrome', 'scheduled'));
        $departure_gateTime_estimated = getIfExist($result, array('properties', 'departure', 'gateTime', 'estimated'));
        $departure_runwayTime_actual = getIfExist($result, array('properties', 'departure', 'runwayTime', 'actual'));
        $departure_runwayTime_estimated = getIfExist($result, array('properties', 'departure', 'runwayTime', 'estimated'));
        $departure_runwayTime_initial = getIfExist($result, array('properties', 'departure', 'runwayTime', 'initial'));
        // Arrival
        $arrival_aerodrome_scheduled = getIfExist($result, array('properties', 'arrival', 'aerodrome', 'scheduled'));
        $arrival_aerodrome_initial = getIfExist($result, array('properties', 'arrival', 'aerodrome', 'initial'));
        $arrival_runwayTime_actual = getIfExist($result, array('properties', 'arrival', 'runwayTime', 'actual'));
        $arrival_runwayTime_initial = getIfExist($result, array('properties', 'arrival', 'runwayTime', 'initial'));
        $arrival_runwayTime_estimated = getIfExist($result, array('properties', 'arrival', 'runwayTime', 'estimated'));
        // Other informations
        $source = getIfExist($result, array('properties', 'positionReport', 'source'));
        $track = getIfExist($result, array('properties', 'positionReport', 'track'));
        $altitude = getIfExist($result, array('properties', 'positionReport', 'altitude'));
        $captureTimestamp = getIfExist($result, array('properties', 'positionReport', 'captureTimestamp'));
        // aircraftDescription
        $aircraftCode = getIfExist($result, array('properties', 'aircraftDescription', 'aircraftCode'));
        $aircraftRegistration = getIfExist($result, array('properties', 'aircraftDescription', 'aircraftRegistration'));


        $res = save_all_plane_info(array($id, $position_x, $position_y, $airline, $callsign, $flightStatus, $iataFlightNumber, $timestampProcessed, $flightPlanTimestamp, $departure_aerodrome_actual, $departure_aerodrome_scheduled, $departure_gateTime_estimated, $departure_runwayTime_actual, $departure_runwayTime_estimated, $departure_runwayTime_initial, $arrival_aerodrome_scheduled, $arrival_aerodrome_initial, $arrival_runwayTime_actual, $arrival_runwayTime_initial, $arrival_runwayTime_estimated, $source, $track, $altitude, $captureTimestamp, $aircraftCode, $aircraftRegistration));
        if($res == 1) {
            $nbrUpdate += 1;
        }

        // Properties
        // $properties = $result['properties'];
        
        // if(isset($properties['airline'])) {
        //     $company = $properties['airline'];
        // } else {
        //     $company = '';
        // }


        // $positionTime = $properties['positionReport']['captureTimestamp'];
        // $transformPositionTime = date('Y-m-d H:i:s', strtotime($positionTime));


        // // properties > positionReport > altitude
        // if(isset($properties['positionReport']) && isset($properties['positionReport']['altitude'])) {
        //     $altitude = $properties['positionReport']['altitude'];
        // }

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
        
        // $res = addPlanePositions($id, $position[0], $position[1], $transformPositionTime, $company);
        // if($res == 1) {
        //     $nbrUpdate += 1;
        // }
        // echo "Result: " . $res . "<br />";

    }
    printLogInfo("Nbr update: " . $nbrUpdate);

}

/*
Structure a sauvegardée:

https://github.com/laminardata/schemas
https://github.com/laminardata/schemas/blob/master/jsonSchemas/flight_summary_geojson_schema.json


{
  "type": "FeatureCollection",
  "features": [
    {
      "id": "0ddd833b-79a0-488c-847d-e5d99474cb75",
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          -17.0709,
          14.6712
        ]
      },
      "properties": {
        "callsign": "V5WAU",
        "flightStatus": "AIRBORNE",
        "positionReport": {
          "track": 5,
          "source": "ADS-B",
          "altitude": 0,
          "captureTimestamp": "2018-11-30T18:21:15Z"
        },
        "timestampProcessed": "2018-11-30T18:21:25Z",
        "aircraftDescription": {
          "aircraftCode": "B350",
          "aircraftRegistration": "V5-WAU"
        }
      }
    }
  ],
  "results": {
    "publishTime": "2018-11-30T20:32:10.061Z",
    "status": "ok",
    "total": 42
  }
}



*/

