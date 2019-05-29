INSERT INTO "busInformations" (vehicle_id, trip_id, route_id, direction_id, start_date, last_update, distance, trip) 
VALUES (
    ':id ', 
    ':trip_id ', 
    ':route_id ', 
    :direction_id , 
    to_timestamp(:time ),
    to_timestamp(:time ),
    0,
    tgeompointseq(tgeompointinst(ST_SetSRID(
        ST_GeomFromText(':point '),4326), 
        to_timestamp(:time ))
    )
) 
ON CONFLICT ON CONSTRAINT bus_info_unique 
DO UPDATE SET 
    last_update = to_timestamp(:time ),
    trip = tgeompointseq(tgeompoints(
        ARRAY[
            tgeompointseq("busInformations".trip), 
            tgeompointseq( 
                ARRAY[
                    endInstant(tgeompointseq("busInformations".trip)), 
                    tgeompointinst(ST_SetSRID(
                        ST_GeomFromText(':point '),4326), 
                        to_timestamp(:time )) 
                ], false, true)
        ])
    ),
    distance = "busInformations".distance + ST_Distance(
        ST_Transform(endValue(tgeompointseq("busInformations".trip)), 3857),
        ST_Transform(ST_SetSRID(ST_GeomFromText(':point '),4326), 3857)
    )
WHERE endTimestamp(tgeompointseq("busInformations".trip)) < to_timestamp(:time );
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
INSERT INTO "timeSpent2" (vehicle_id, start_date, last_update, time_spent, gid)
SELECT 
    ':id ',
    to_timestamp(':start_date ', 'YYYYMMDD'),
    to_timestamp(:time ),
    :timeDiff ,
    usa_adm.gid
FROM usa_adm
WHERE ST_Intersects(st_setsrid(geom, 4326), ST_SetSRID(ST_GeomFromText(':point '),4326))
ON CONFLICT ON CONSTRAINT time_spent2_unique
DO UPDATE SET 
    time_spent = "timeSpent2".time_spent + :timeDiff ,
    last_update = to_timestamp(:time );
