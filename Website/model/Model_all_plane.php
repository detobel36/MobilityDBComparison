<?php

function save_all_plane_info($allParameters) {

    $reqSQL = 'INSERT INTO "all_plane" ("id", "position", "airline", "callsign", ' . 
                '"flightStatus", "iataFlightNumber", "timestampProcessed", "flightPlanTimestamp", '. 
                '"departure_aerodrome_actual", "departure_aerodrome_scheduled", ' . 
                '"departure_gateTime_estimated", "departure_runwayTime_actual", ' . 
                '"departure_runwayTime_estimated", "departure_runwayTime_initial", ' . 
                '"arrival_aerodrome_scheduled", "arrival_aerodrome_initial", ' . 
                '"arrival_runwayTime_actual", "arrival_runwayTime_initial", ' . 
                '"arrival_runwayTime_estimated", "source", "track", "altitude", ' . 
                '"captureTimestamp", "aircraftCode", "aircraftRegistration") ' . 
                'VALUES($1, ST_MakePoint(' . $allParameters[1] . ', ' . $allParameters[2] . ')';

    $count = 0;
    $paramCount = 2;
    $params = array($allParameters[0]);
    foreach ($allParameters as $param) {
        if($count >= 3) { // On oublie le 1er paramètre (id) et les position (param 2 et 3)
            if($param === "NULL") {
                $reqSQL .= ', NULL';
            } else {
                $reqSQL .= ", $" . $paramCount;
                $params[] = $param;
                $paramCount += 1;
            }
        }
        $count += 1;
    }
    $reqSQL .= ');';

    $result = bdd_query($reqSQL, $params);
    return $result !== NULL;
}

function get_plane_info($planeId) {
    $reqSQL = 'SELECT * FROM "all_plane" WHERE "id" = $1';
    return bdd_query($reqSQL, array($planeId));
}


/*
-- Total of different plane
SELECT COUNT(DISTINCT id)
FROM all_plane;

-- Number of plane that we couldn't use
SELECT COUNT(DISTINCT pOne.id)
FROM all_plane pOne 
WHERE NOT EXISTS (
    SELECT *
    FROM all_plane pTwo
    WHERE
        pTwo.id = pOne.id AND
        ST_AsText(pTwo.position) != ST_AsText(pOne.position) 
)
GROUP BY pOne.id


 1,291 données inutilisable
84 603

*/