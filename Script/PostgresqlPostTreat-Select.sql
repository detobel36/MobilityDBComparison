----------- Bus Informations -----------

SELECT
    position.vehicle_id, 
    position.trip_id, 
    position.route_id, 
    position.direction_id, 
    min(position.moment) AS start_date,
    max(position.moment) AS last_update,
    tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true) AS trip,
    length(transform(tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true), 3857)) AS distance,
    cumulativeSpeed(transform(tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true), 3857)) * 3.6 AS speed_avg
FROM vehicle_position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id
HAVING now()-max(position.moment) < '5 minutes';


----------- Bus Déviation -----------

SELECT
    vehicle_position.vehicle_id,
    vehicle_position.route_id,
    vehicle_position.direction_id,
    max(vehicle_position.moment) AS last_update,
    tgeompointseq(anyarray_uniq(array_agg(vehicle_position.inst))) AS trip
FROM vehicle_position
    JOIN gtfs_line_geoms bus_line
        ON bus_line.route_id = vehicle_position.route_id AND 
            bus_line.direction_id = vehicle_position.direction_id
WHERE 
    ST_Distance(ST_Transform(getValue(inst), 3857), ST_Transform(bus_line.the_geom, 3857)) > 10 
GROUP BY vehicle_position.vehicle_id, vehicle_position.route_id, vehicle_position.direction_id
HAVING now()-max(vehicle_position.moment) < '3 hours';


----------- Temps par région -----------

SELECT
    SUM(timediff) AS time_spent,
    gid,
    name_0, 
    name_1,
    name_2,
    geom,
    max(moment) AS moment
FROM vehicle_position
    JOIN usa_adm
        ON intersects(st_setsrid(geom, 4326), inst)
WHERE moment > date_trunc('day', NOW()) 
GROUP BY gid, name_0, name_1, name_2, geom;
