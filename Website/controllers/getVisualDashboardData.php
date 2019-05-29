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


$result = bdd_query('SELECT vehicle_id, route_id, direction_id, timezone(\'utc\', now())-start_date AS since_start, last_update, ' . 
            'speed_avg, distance, ST_asText(endValue(trip)) AS lastPos, ST_asText(getValues(trip)) AS traj_trip ' .
        'FROM "view_busInformations" WHERE timezone(\'utc\', now())-last_update < \'5 minutes\';');

// SELECT vehicle_id, route_id, direction_id, timezone('utc', now())-start_date AS since_start, last_update, 
//             speed_avg, distance, ST_asText(endValue(trip)) AS lastPos, ST_asText(getValues(trip)) AS traj_trip 
//         FROM "view_busInformations" WHERE timezone('utc', now())-last_update < '5 minutes';

// $result = bdd_query('SELECT vehicle_id, route_id, direction_id, timezone(\'utc\', now())-start_date AS since_start, last_update, ' . 
//             'speed_avg, distance, ST_asText(endValue(trip)) AS lastPos, ST_asText(getValues(trip)) AS traj_trip ' .
//         'FROM "view_busTripInformations" WHERE timezone(\'utc\', now())-last_update < \'5 minutes\';');


if(isset($_GET['display']) && $_GET['display'] == '1') {
    echo '<pre>';
    print_r($result);
    echo '</pre>';
} else {
    echo json_encode($result);
}

