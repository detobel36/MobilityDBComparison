<?php

function get_all_bus_route() {
    return bdd_query(
            'SELECT ST_AsGeoJSON(geom) AS route, route_id, direction_ '.
            'FROM "nyct_group_bus_routes" ' .
            'ORDER BY route_id'
        );
}
