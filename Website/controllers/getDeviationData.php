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

// $result = bdd_query('SELECT ST_asText(shape.the_geom) AS lineRoad, ' .
//     'shape.route_id, shape.direction_id ' .
// 'FROM gtfs_shape_geoms shape LIMIT 50');


// $result = bdd_query('SELECT outOfRoad.vehicle_id, outOfRoad.shape_id, outOfRoad.last_update,  ' .
//     'ST_asText(shape.the_geom) AS lineRoad, ST_asText(getValues(busTrip1.tgeompointseq)) AS busRoad, ' .
//     'shape.route_id, shape.direction_id ' .
// 'FROM "view_busOutOfRoad" outOfRoad  ' .
//     'JOIN "busTrip" busTrip1  ' .
//         'ON busTrip1.vehicle_id = outOfRoad.vehicle_id  ' .
//     'JOIN gtfs_shape_geoms shape ' .
//         'ON shape.shape_id = outOfRoad.shape_id ' .
//     'WHERE NOT EXISTS ( ' .
//         'SELECT *  ' .
//         'FROM "busTrip" busTrip2  ' .
//         'WHERE busTrip2.vehicle_id = busTrip1.vehicle_id AND busTrip2.start_date > busTrip1.start_date ' .
//     ') AND NOT EXISTS ( ' .
//         'SELECT *  ' .
//         'FROM "view_busOutOfRoad" outOfRoad2  ' .
//         'WHERE outOfRoad2.vehicle_id = outOfRoad.vehicle_id AND outOfRoad2.last_update > outOfRoad.last_update ' .
//     ') ' .
// 'WHERE intersects(shape.the_geom, busTrip1.tgeompointseq) '.
// 'ORDER BY outOfRoad.vehicle_id;');

// SELECT outOfRoad.vehicle_id, outOfRoad.shape_id, outOfRoad.last_update, 
//     ST_asText(shape.the_geom) AS lineRoad, ST_asText(getValues(busTrip1.tgeompointseq)) AS busRoad,
//     ST_asText(ST_Intersection(shape.the_geom, getValues(busTrip1.tgeompointseq))) AS intersection
// FROM "view_busOutOfRoad" outOfRoad 
//     JOIN "busTrip" busTrip1 
//         ON busTrip1.vehicle_id = outOfRoad.vehicle_id 
//     JOIN gtfs_shape_geoms shape
//         ON shape.shape_id = outOfRoad.shape_id
//     WHERE NOT EXISTS (
//         SELECT * 
//         FROM "busTrip" busTrip2 
//         WHERE busTrip2.vehicle_id = busTrip1.vehicle_id AND busTrip2.start_date > busTrip1.start_date
//     ) AND NOT EXISTS (
//         SELECT * 
//         FROM "view_busOutOfRoad" outOfRoad2 
//         WHERE outOfRoad2.vehicle_id = outOfRoad.vehicle_id AND outOfRoad2.last_update > outOfRoad.last_update
//     )
// ORDER BY outOfRoad.vehicle_id;



$result = bdd_query('SELECT vehicle_id, route_id, direction_id, ST_asText(getValues(inst)) AS busPosition '.
    'FROM "view_busOutOfRoad" LIMIT 50;');


if($result == NULL) {
    $result = array();
}

if(isset($_GET['display']) && $_GET['display'] == '1') {
    echo '<pre>';
    print_r($result);
    echo '</pre>';
} else {
    echo json_encode($result);
}
