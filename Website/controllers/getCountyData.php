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

// Afficher les régions de New York
// $result = bdd_query('SELECT gid, name_0, name_1, ST_AsGeoJSON(geom) AS geo_json FROM usa_adm WHERE id_1 = 33;');

$result = bdd_query('SELECT gid, name_0, name_1, timespend, ST_AsGeoJSON(geom) AS geom FROM "view_timeSpend";');

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
