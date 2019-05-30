----------- Bus Informations -----------
----------- Bus Déviation -----------
----------- Temps par région -----------

INSERT INTO "vehicle_position" (vehicle_id, trip_id, start_date, route_id, direction_id, inst, bearing, moment, stop_id, timediff)
VALUES (
    ':id ',
    ':trip_id ',
    :start_date ,
    ':route_id ',
    ':direction_id ',
    tgeompointinst(ST_SetSRID(ST_GeomFromText(':point '), 4326), to_timestamp(:time )),
    :bearing ,
    to_timestamp(':time '),
    :stop_id ,
    :timeDiff 
);
