INSERT INTO "busTrip_stream" ("vehicle_id", "trip_id", "start_date", "route_id", "direction_id", "route_time", "bearing", "moment", "stop_id") 
VALUES(
    ':id ',
    ':trip_id ',
    :start_date ,
    ':route_id ',
    :direction_id ,
    tgeompoint(':route_time '),
    :bearing ,
    to_timestamp(':time '),
    ':stop_id '
);
