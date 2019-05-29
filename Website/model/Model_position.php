<?php

function getBusPosition($limite) {
    return bdd_query('SELECT DISTINCT ON(id) id, longitude, latitude, moment, vehicle_id, route_id, ' . 
            'ST_X(fixed_position) AS fix_position_longitude, ' . 
            'ST_Y(fixed_position) AS fix_position_latitude, ' . 
            'fixed_distance ' . /*   */
            'FROM view_mta_bus '.
            'ORDER BY id DESC, fixed_distance ASC ' . 
            'LIMIT ' . $limite);
}


// function addPlanePositions($id, $x, $y, $positionTime, $company) {
//     // Format of PositionTime -> YYYY-MM-DD HH:MM:SS

//     $reqSQL = 'INSERT INTO "PlanePosition" ("planeid", "position", "company") ' .
//                 'VALUES($1, tgeompoint \'[POINT(' . $x . ' ' . $y . ')@' . $positionTime . ']\', $2);';

//     // TODO update si pas insert
//     $params = array($id, $company);
//     $result = bdd_query($reqSQL, $params);
//     return $result !== NULL;
// }

// function getLastPlanePositions() {
//     $reqSQL = 'SELECT planeid, company, endTimestamp(position) AS last_update, st_asText(endValue(position)) AS last_position ' . 
//             'FROM "PlanePosition" ' . 
//             'WHERE endTimestamp(position) >= current_date::timestamp ' .
//             'ORDER BY last_update DESC;';
//     return bdd_query($reqSQL);
// }

// function getLastPlanePositionsCoordinate() {
//     $reqSQL = 'SELECT planeid, company, endTimestamp(position) AS last_update, ST_X(endValue(position)) AS last_position_x, ST_Y(endValue(position)) AS last_position_y ' . 
//             'FROM "PlanePosition" ' . 
//             'WHERE endTimestamp(position) >= current_date::timestamp ' .
//             'ORDER BY last_update DESC;';
//     return bdd_query($reqSQL);
// }

