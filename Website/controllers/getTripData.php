<?php
pg_pconnect("host=127.0.0.1 dbname=mta_pipelinedb user=mtauser password=x1Kokzgfarz67fcU");
pg_query("select st_point(0,0);"); // Update session to enable postgis

function bdd_query($request, $parameters = array()) {

    $result = NULL;
    if(count($parameters) == 0) {
        $result = @pg_query($request);
    } else {
        $result = @pg_query_params($request, $parameters);
    }

    if($result) {
        $returnResult = pg_fetch_all($result);
        return ($returnResult == NULL) ? array() : $returnResult;
    } else {
        return NULL;
        // Fetch error with: pg_last_error()
    }
}


$result = bdd_query('SELECT trip1.vehicle_id, trip1.trip_id, trip1.route_id, trip1.direction_id, '.
        'trip1.start_date, ST_asText(getValues(trip1.tgeompointseq)) AS trip '.
    'FROM "busTrip" trip1 ' . 
    'WHERE NOT EXISTS('.
        'SELECT * ' .
        'FROM "busTrip" trip2 ' .
        'WHERE trip2.vehicle_id = trip1.vehicle_id AND trip2.start_date > trip1.start_date ' .
    ');');


if(isset($_GET['display']) && $_GET['display'] == '1') {
    echo '<pre>';
    print_r($result);
    echo '</pre>';
} else {
    echo json_encode($result);
}
