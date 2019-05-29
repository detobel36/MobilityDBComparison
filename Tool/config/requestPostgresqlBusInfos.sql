INSERT INTO "busInformations" (vehicle_id, trip_id, route_id, direction_id, start_date, last_update, distance, trip) 
VALUES (
    ':id ', 
    ':trip_id ', 
    ':route_id ', 
    :direction_id , 
    to_timestamp(':start_date ', 'YYYYMMDD'),
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
