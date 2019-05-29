<?php

// WARNING ne pas refaire un 'pg_pconnect'
pg_pconnect("host=127.0.0.1 dbname=" . $db_name . " user=mtauser password=x1Kokzgfarz67fcU");

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

?>