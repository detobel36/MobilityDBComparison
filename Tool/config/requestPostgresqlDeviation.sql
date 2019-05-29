INSERT INTO "busDeviation" (vehicle_id, route_id, direction_id, last_update, trip)
SELECT 
    ':id ', 
    ':route_id ', 
    :direction_id , 
    to_timestamp(:time ),
    tgeompointseq(tgeompointinst(ST_SetSRID(
        ST_GeomFromText(':point '),4326), 
        to_timestamp(:time ))
    )
FROM gtfs_line_geoms bus_line
WHERE bus_line.direction_id = :direction_id  AND bus_line.route_id = ':route_id ' AND 
    ST_Distance(
            ST_Transform(
                ST_SetSRID(ST_GeomFromText(':point '),4326),
                3857),
            ST_Transform(bus_line.the_geom, 3857)
    ) > 10
ON CONFLICT ON CONSTRAINT bus_deviation_unique 
DO UPDATE SET 
    last_update = to_timestamp(:time ),
    trip = tgeompointseq(tgeompoints(
        ARRAY[
            tgeompointseq("busDeviation".trip), 
            tgeompointseq( 
                ARRAY[
                    endInstant(tgeompointseq("busDeviation".trip)), 
                    tgeompointinst(ST_SetSRID(
                        ST_GeomFromText(':point '),4326), 
                        to_timestamp(:time )) 
                ], false, true)
        ])
    );
