CREATE DATABASE mta_pipelinedb;
ALTER DATABASE mta_pipelinedb OWNER TO mtauser;
CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS pipelinedb CASCADE;

-- Stream without time diff
DROP FOREIGN TABLE IF EXISTS "busPosition_stream" CASCADE;
CREATE FOREIGN TABLE "busPosition_stream" (
    vehicle_id character varying(25),
    trip_id character varying(250),
    start_date integer,
    route_id character varying(25),
    direction_id integer,
    inst tgeompoint,
    bearing double precision,
    moment timestamp without time zone,
    stop_id integer)
SERVER pipelinedb;

-- Stream with time diff
DROP FOREIGN TABLE IF EXISTS "busPosition_stream" CASCADE;
CREATE FOREIGN TABLE "busPosition_stream" (
    vehicle_id character varying(25),
    trip_id character varying(250),
    start_date integer,
    route_id character varying(25),
    direction_id integer,
    inst tgeompoint,
    bearing double precision,
    moment timestamp without time zone,
    stop_id integer,
    timeDiff integer)
SERVER pipelinedb;


-- Source: https://github.com/JDBurnZ/postgresql-anyarray
DROP FUNCTION IF EXISTS anyarray_uniq(anyarray);
CREATE OR REPLACE FUNCTION anyarray_uniq(with_array anyarray)
    RETURNS anyarray AS
$BODY$
    DECLARE
        -- The variable used to track iteration over "with_array".
        loop_offset integer;

        -- The array to be returned by this function.
        return_array with_array%TYPE := '{}';
        last_insert timestamp with time zone := NULL;
    BEGIN
        IF with_array IS NULL THEN
            return NULL;
        END IF;
        
        IF with_array = '{}' THEN
            return return_array;
        END IF;

        -- Iterate over each element in "concat_array".
        FOR loop_offset IN ARRAY_LOWER(with_array, 1)..ARRAY_UPPER(with_array, 1) LOOP
            IF last_insert IS NULL OR startTimestamp(with_array[loop_offset]) > last_insert THEN
                return_array = ARRAY_APPEND(return_array, with_array[loop_offset]);
                last_insert = endTimestamp(with_array[loop_offset]);
            END IF;
        END LOOP;

    RETURN return_array;
END;
$BODY$ LANGUAGE plpgsql;

DROP VIEW IF EXISTS "busTrip" CASCADE;
CREATE VIEW "busTrip" WITH (action=materialize, ttl='1 day', ttl_column='start_date') AS
SELECT position.vehicle_id, 
    position.trip_id, 
    position.route_id, 
    position.direction_id, 
    min(position.moment) AS start_date,
    tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true)
FROM "busPosition_stream" AS position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;


DROP FUNCTION IF EXISTS anyarray_uniq_clean(anyarray);
CREATE OR REPLACE FUNCTION anyarray_uniq_clean(with_array anyarray)
    RETURNS anyarray AS
$BODY$
    DECLARE
        -- The variable used to track iteration over "with_array".
        loop_offset integer;

        -- The array to be returned by this function.
        return_array with_array%TYPE := '{}';
        last_location geometry := NULL;
        last_insert timestamp with time zone := NULL;
    BEGIN
        IF with_array IS NULL THEN
            return NULL;
        END IF;
        
        IF with_array = '{}' THEN
            return return_array;
        END IF;

        -- Iterate over each element in "concat_array".
        FOR loop_offset IN ARRAY_LOWER(with_array, 1)..ARRAY_UPPER(with_array, 1) LOOP
            IF (
                last_insert IS NULL OR startTimestamp(with_array[loop_offset]) > last_insert) 
                AND 
                (
                    last_location IS NULL OR 
                    ST_Distance(last_location, ST_Transform(endValue(with_array[loop_offset]), 3857)) > 5
                ) THEN
                    return_array = ARRAY_APPEND(return_array, with_array[loop_offset]);
                    last_insert = endTimestamp(with_array[loop_offset]);
                    last_location = ST_Transform(endValue(with_array[loop_offset]), 3857);
            END IF;
        END LOOP;

    RETURN return_array;
END;
$BODY$ LANGUAGE plpgsql;



DROP VIEW IF EXISTS "busTripClean" CASCADE;
CREATE VIEW "busTripClean" WITH (action=materialize, ttl='1 day', ttl_column='start_date') AS
SELECT position.vehicle_id, 
    position.trip_id, 
    position.route_id, 
    position.direction_id, 
    min(position.moment) AS start_date,
    tgeompointseq(anyarray_uniq_clean(array_agg(position.inst)), true, true)
FROM "busPosition_stream" AS position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;




----------- Bus Informations -----------

DROP FUNCTION IF EXISTS cumulativeSpeed(tgeompoint);
CREATE OR REPLACE FUNCTION cumulativeSpeed(list_points tgeompoint)
    RETURNS double precision AS
$BODY$
    DECLARE
        result double precision := 0;
        total_time integer := EXTRACT(epoch FROM (duration(list_points)));
        distance double precision := NULL;
    BEGIN

        IF total_time = 0 THEN
            return result;
        END IF;

        result = length(list_points)/total_time;
    RETURN result;
END;
$BODY$ LANGUAGE plpgsql;

DROP VIEW IF EXISTS "view_busInformations";
CREATE VIEW "view_busInformations" WITH (action=materialize, ttl='5 minutes', ttl_column='last_update') AS
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
FROM "busPosition_stream" AS position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;

-- -- SELECT
-- SELECT vehicle_id, trip_id, route_id, direction_id, start_date, last_update,
-- distance, speed_avg, numInstants(trip) AS nbrInstant
-- FROM "view_busInformations";


----------- Bus Déviation -----------
DROP VIEW IF EXISTS "view_busOutOfRoad" CASCADE;
CREATE VIEW "view_busOutOfRoad" WITH (action=materialize, ttl='3 hours', ttl_column='last_update') AS
SELECT
    stream.vehicle_id,
    stream.route_id,
    stream.direction_id,
    max(stream.moment) AS last_update,
    tgeompointseq(anyarray_uniq(array_agg(stream.inst))) AS trip
FROM "busPosition_stream" stream
    JOIN gtfs_line_geoms bus_line
        ON bus_line.route_id = stream.route_id AND bus_line.direction_id = stream.direction_id
WHERE 
    ST_Distance(ST_Transform(getValue(inst), 3857), ST_Transform(bus_line.the_geom, 3857)) > 10 
GROUP BY stream.vehicle_id, stream.route_id, stream.direction_id;

-- -- SELECT
-- SELECT vehicle_id, route_id, direction_id, last_update, numInstants(trip) AS nbrInstant
-- FROM "view_busOutOfRoad";



----------- Temps par région -----------

DROP VIEW IF EXISTS "view_timeSpent";
CREATE VIEW "view_timeSpent" WITH (action=materialize) AS 
SELECT
    SUM(timediff) AS time_spent,
    gid,
    name_0, 
    name_1,
    name_2,
    geom,
    max(moment) AS moment
FROM "busPosition_stream"
    JOIN usa_adm
        ON intersects(st_setsrid(geom, 4326), inst)
WHERE moment > date_trunc('day', NOW()) 
GROUP BY gid, name_0, name_1, name_2, geom;

-- -- SELECT
-- SELECT timeSpend, gid, name_0, name_1, name_2, moment 
-- FROM "view_timeSpent";






















-- TODO
------------------ TEST --------------------
    DROP TABLE IF EXISTS "test_bus_position";
    CREATE TABLE "test_bus_position" (
        vehicle_id character varying(25),
        trip_id character varying(250),
        route_id character varying(25),
        direction_id integer,
        inst tgeompoint,
        moment timestamp without time zone);

    SELECT 
        position.vehicle_id, 
        position.trip_id, 
        position.route_id, 
        position.direction_id, 
        position.moment,
        position.inst
    FROM "test_bus_position" AS position
    WHERE NOT EXISTS (
        SELECT *
        FROM nyct_bus_routes route
        WHERE 
            route.route_id = REPLACE(position.route_id, '+', '') AND 
            route.direction_ = position.direction_id AND
     
    );


    SELECT DISTINCT position.route_id
    FROM "test_bus_position" AS position
    WHERE NOT EXISTS (
        SELECT *
        FROM gtfs_shape_geoms route
        WHERE 
            route.route_id = REPLACE(position.route_id, '+', '') AND 
            route.direction_id = position.direction_id
    );


    SELECT 
        position.vehicle_id, 
        position.trip_id, 
        position.route_id, 
        position.direction_id, 
        position.moment,
        position.inst,
        ST_Distance(getValue(position.inst), shape.the_geom) AS distance
    FROM "test_bus_position" AS position
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = position.route_id AND 
            shape.direction_id = position.direction_id AND 
            ST_Distance(getValue(position.inst), shape.the_geom) > 5;


    ------------------- TEST -------------------

    DROP VIEW IF EXISTS "testOutTrip";
    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT stream.vehicle_id, stream.inst, stream.route_id
    FROM "busPosition_stream" stream
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
    WHERE ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(the_geom, 3857)) > 5;


    DROP VIEW IF EXISTS "testOutTrip";
    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT 
        pointOutOfRoad.vehicle_id, 
        pointOutOfRoad.inst, 
        pointOutOfRoad.route_id, 
        pointOutOfRoad.direction_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.shape_id) AS shape_id
    FROM (
        SELECT stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id, shape.shape_id,
            ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(the_geom, 3857)) AS distance
        FROM "busPosition_stream" stream
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
        WHERE ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(the_geom, 3857)) > 5
    ) pointOutOfRoad
    GROUP BY pointOutOfRoad.vehicle_id, pointOutOfRoad.inst, pointOutOfRoad.route_id, pointOutOfRoad.direction_id;



    -- Pas d'aggrégation dans une sous requête
    -- 
    -- DROP VIEW IF EXISTS "testOutTrip";
    -- CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    -- SELECT pointOutOfRoad.vehicle_id, pointOutOfRoad.trip, pointOutOfRoad.route_id, pointOutOfRoad.direction_id
    -- FROM (
    --     SELECT position.vehicle_id, 
    --         position.trip_id, 
    --         position.route_id, 
    --         position.direction_id, 
    --         min(position.moment) AS start_date,
    --         tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true) AS trip
    --     FROM "busPosition_stream" AS position
    --     GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id
    -- ) pointOutOfRoad;







    CREATE VIEW "view_busOutOfRode" WITH (action=materialize, ttl='1 day', ttl_column='last_update') AS
    SELECT 
        position.vehicle_id, 
        position.trip_id, 
        position.route_id, 
        position.direction_id, 
        position.moment,
        position.inst
    FROM "busPosition_stream" AS position
        JOIN nyct_bus_routes route
            ON route.route_id = position.route_id AND route.direction_ = position.direction_id
    GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;



    SELECT basic.*
    FROM (SELECT 'M1' AS route_id, 1 AS direction) basic 
        LEFT JOIN gtfs_shape_geoms shape 
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction
    WHERE NOT EXISTS (
        SELECT *
        FROM gtfs_shape_geoms shape_out
        WHERE shape_out.shape_id = shape.shape_id
    )
    GROUP BY basic.route_id, basic.direction;


    SELECT *
    FROM (SELECT 'M1' AS route_id, 1 AS direction, ST_PointFromText('POINT(-73.997808 40.7206)', 4326) AS position) basic 
    WHERE EXISTS (
        SELECT shape.route_id
        FROM gtfs_shape_geoms shape shape
        WHERE shape.route_id = basic.route_id AND shape.direction_id = basic.direction
    )


    ST_distance(ST_PointFromText('POINT(-73.997808 40.7206)', 4326), the_geom)


    SELECT basic.*, ST_distance(ST_Transform(position, 3857), ST_Transform(the_geom, 3857))
    FROM (SELECT 'M1' AS route_id, 1 AS direction, ST_PointFromText('POINT(-73.997808 40.7207)', 4326) AS position) basic 
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction;



    SELECT basic.route_id, basic.direction, basic.position
    FROM (SELECT 'M1' AS route_id, 1 AS direction, ST_PointFromText('POINT(-73.997808 40.7207)', 4326) AS position) basic 
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction
    GROUP BY basic.route_id, basic.direction, basic.position
    HAVING min(ST_distance(ST_Transform(position, 3857), ST_Transform(the_geom, 3857))) > 5;


    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT basic.route_id, basic.direction_id, keyed_max(moment, inst) AS inst
    FROM "busPosition_stream" AS basic
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction_id
    GROUP BY basic.route_id, basic.direction_id
    HAVING min(ST_distance(ST_Transform(keyed_max(moment, getValue(inst)), 3857), ST_Transform(the_geom, 3857))) > 5;


    DROP VIEW IF EXISTS "testOutTrip";
    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT stream.vehicle_id, stream.inst, stream.route_id
    FROM "busPosition_stream" stream
    JOIN (
        SELECT basic.vehicle_id, basic.route_id, basic.direction_id, start_date, tgeompointseq
        FROM "busTrip" AS basic
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction_id
        WHERE ST_distance(ST_Transform(endValue(tgeompointseq), 3857), ST_Transform(the_geom, 3857)) > 5
        ) out_of_route
    ON out_of_route.vehicle_id = stream.vehicle_id;



    DROP VIEW IF EXISTS "testOutTrip";
    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT stream.vehicle_id, stream.inst, stream.route_id
    FROM "busPosition_stream" stream
        JOIN "busTrip" AS basic
            ON basic.vehicle_id = stream.vehicle_id;



    DROP VIEW IF EXISTS "testOutTrip";
    CREATE VIEW "testOutTrip" WITH (action=materialize) AS
    SELECT basic.vehicle_id, basic.route_id, basic.direction_id, basic.start_date, basic.tgeompointseq
    FROM "busTrip" AS basic
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction_id
        JOIN "busPosition_stream" busPos
            ON busPos.vehicle_id = basic.vehicle_id
    WHERE ST_distance(ST_Transform(endValue(basic.tgeompointseq), 3857), ST_Transform(the_geom, 3857)) > 5;




    SELECT position.vehicle_id, 
        position.trip_id, 
        position.route_id, 
        position.direction_id, 
        min(position.moment) AS start_date,
        tgeompointseq(anyarray_uniq(array_agg(position.inst)), true, true)
    FROM "busPosition_stream" AS position
    JOIN (
        SELECT basic.route_id, basic.direction_id, keyed_max(moment, endValue(inst)
        FROM "busPosition_stream" AS basic
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction_id
        GROUP BY basic.route_id, basic.direction_id
        HAVING min(ST_distance(ST_Transform(keyed_max(moment, endValue(inst)), 3857), ST_Transform(the_geom, 3857))) > 5
    )
    GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;





    SELECT basic.route_id, basic.direction, basic.trip
    FROM (SELECT 'M1' AS route_id, 1 AS direction, setSRID(tgeompoint('[POINT (-73.93141350005604 40.84836218120145)@2019-04-25 15:35:58,POINT (-73.997808 40.7207)@2019-04-25 15:36:31]'), 4326) AS trip) basic 
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = basic.route_id AND shape.direction_id = basic.direction
    GROUP BY basic.route_id, basic.direction, basic.trip
    HAVING min(ST_distance(ST_Transform(endValue(trip), 3857), ST_Transform(the_geom, 3857))) > 5;


    DROP VIEW IF EXISTS "test_trip_agg";
    CREATE VIEW "test_trip_agg" WITH (action=materialize) AS
    SELECT
        vehicle_id,
        set_agg(route_time) AS trip
    FROM "busTrip_stream" AS position
    GROUP BY position.vehicle_id;


    ----
    SELECT stream.vehicle_id, 
        stream.inst, 
        max(stream.moment) AS last_update,
        stream.route_id, 
        stream.direction_id,
        keyed_min(stream.distance, pointOutOfRoad.shape_id) AS shape_id
    FROM "busPosition_stream" stream
        JOIN gtfs_shape_geoms shape
            ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
    WHERE NOT EXISTS (
        SELECT shape.shape_id
        FROM gtfs_shape_geoms shape
        WHERE shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id AND
            ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) < 5
    )
    GROUP BY stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id;

    ----
    SELECT pointOutOfRoad.vehicle_id, 
        pointOutOfRoad.inst, 
        max(pointOutOfRoad.moment) AS last_update,
        pointOutOfRoad.route_id, 
        pointOutOfRoad.direction_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.shape_id) AS shape_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.the_geom) AS shape_geom
    FROM (
        SELECT stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id, shape.shape_id,
            stream.moment, shape.the_geom,
            ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) AS distance
        FROM "busPosition_stream" stream
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
        WHERE NOT EXISTS (
            SELECT shape.shape_id
            FROM gtfs_shape_geoms shape
            WHERE shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id AND
                ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) < 5
        )
    ) pointOutOfRoad
    GROUP BY pointOutOfRoad.vehicle_id, pointOutOfRoad.inst, pointOutOfRoad.route_id, pointOutOfRoad.direction_id;




    -- NOTICE:  consider creating an index on shape.route_id for improved stream-table join performance
    -- NOTICE:  consider creating an index on shape.direction_id for improved stream-table join performance
    -- NOTICE:  consider creating an index on shape.shape_id for improved stream-table join performance


    -- SELECT 
    --     pointOutOfRoad.vehicle_id, 
    --     pointOutOfRoad.inst, 
    --     max(pointOutOfRoad.moment) AS last_update,
    --     pointOutOfRoad.route_id, 
    --     pointOutOfRoad.direction_id,
    --     min(pointOutOfRoad.distance) AS distance,
    --     keyed_min(pointOutOfRoad.distance, pointOutOfRoad.shape_id) AS shape_id
    -- FROM (
    --     SELECT stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id, shape.shape_id,
    --         stream.moment, ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(the_geom, 3857)) AS distance
    --     FROM "busPosition_stream" stream
    --         JOIN gtfs_shape_geoms shape
    --             ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
    --     WHERE ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(the_geom, 3857)) > 5
    -- ) pointOutOfRoad
    -- GROUP BY pointOutOfRoad.vehicle_id, pointOutOfRoad.inst, pointOutOfRoad.route_id, pointOutOfRoad.direction_id;




    -- SELECT outOfRoad.vehicle_id, outOfRoad.shape_id, outOfRoad.last_update, 
    --     ST_asText(ST_Intersection(shape.the_geom, getValues(outOfRoad.tgeompointseq))) AS intersection
    -- FROM "view_busOutOfRoad" outOfRoad 
    --     JOIN "busTrip" busTrip1 
    --         ON busTrip1.vehicle_id = outOfRoad.vehicle_id 
    --     JOIN gtfs_shape_geoms shape
    --         ON shape.shape_id = outOfRoad.shape_id
    --     WHERE NOT EXISTS (
    --         SELECT * 
    --         FROM "busTrip" busTrip2 
    --         WHERE busTrip2.vehicle_id = busTrip1.vehicle_id AND busTrip2.start_date > busTrip1.start_date
    --     ) AND NOT EXISTS (
    --         SELECT * 
    --         FROM "view_busOutOfRoad" outOfRoad2 
    --         WHERE outOfRoad2.vehicle_id = outOfRoad.vehicle_id AND outOfRoad2.last_update > outOfRoad.last_update
    --     )
    -- ORDER BY outOfRoad.vehicle_id;

    -- OLD Bus Déviation
    DROP VIEW IF EXISTS "view_busOutOfRoad" CASCADE;
    CREATE VIEW "view_busOutOfRoad" WITH (action=materialize, ttl='3 hours', ttl_column='last_update') AS
    SELECT pointOutOfRoad.vehicle_id, 
        pointOutOfRoad.inst, 
        max(pointOutOfRoad.moment) AS last_update,
        pointOutOfRoad.route_id, 
        pointOutOfRoad.direction_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.shape_id) AS shape_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.the_geom) AS shape_geom,
        min(pointOutOfRoad.distance) AS distance
    FROM (
        SELECT stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id, shape.shape_id,
            stream.moment, shape.the_geom,
            ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) AS distance
        FROM "busPosition_stream" stream
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
        WHERE NOT EXISTS (
            SELECT shape.shape_id
            FROM gtfs_shape_geoms shape
            WHERE shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id AND
                ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) < 5
        )
    ) pointOutOfRoad
    GROUP BY pointOutOfRoad.vehicle_id, pointOutOfRoad.inst, pointOutOfRoad.route_id, pointOutOfRoad.direction_id;




    SELECT pointOutOfRoad.vehicle_id, 
        pointOutOfRoad.inst, 
        max(pointOutOfRoad.moment) AS last_update,
        pointOutOfRoad.route_id, 
        pointOutOfRoad.direction_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.shape_id) AS shape_id,
        keyed_min(pointOutOfRoad.distance, pointOutOfRoad.the_geom) AS shape_geom,
        min(pointOutOfRoad.distance) AS distance
    FROM (
        SELECT stream.vehicle_id, stream.inst, stream.route_id, stream.direction_id, shape.shape_id,
            stream.moment, shape.the_geom,
            ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) AS distance
        FROM "busPosition_stream" stream
            JOIN gtfs_shape_geoms shape
                ON shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id
        WHERE NOT EXISTS (
            SELECT shape.shape_id
            FROM gtfs_shape_geoms shape
            WHERE shape.route_id = stream.route_id AND shape.direction_id = stream.direction_id AND
                ST_distance(ST_Transform(getValue(inst), 3857), ST_Transform(shape.the_geom, 3857)) < 5
        )
    ) pointOutOfRoad
    GROUP BY pointOutOfRoad.vehicle_id, pointOutOfRoad.inst, pointOutOfRoad.route_id, pointOutOfRoad.direction_id;



    SELECT busPosition.vehicle_id, busPosition.route_id, busPosition.direction_id,
        min(busPosition.distance) AS distance,
        tgeompointseq(anyarray_uniq(array_agg(busPosition.inst))) AS route
    FROM (
        SELECT outOfRoad.vehicle_id, outOfRoad.inst, outOfRoad.route_id, 
            outOfRoad.direction_id, outOfRoad.shape_id, outOfRoad.distance
        FROM "view_busOutOfRoad" outOfRoad 
        ORDER BY outOfRoad.last_update
    ) busPosition
    GROUP BY busPosition.vehicle_id, busPosition.route_id, busPosition.direction_id;


---- ==========

CREATE FOREIGN TABLE "busTrip_stream" (
    vehicle_id character varying(25),
    trip_id character varying(250),
    start_date integer,
    route_id character varying(25),
    direction_id integer,
    route_time tgeompoint,
    bearing double precision,
    moment timestamp without time zone,
    stop_id integer)
SERVER pipelinedb;

DROP VIEW IF EXISTS "view_busTripInformations";
CREATE VIEW "view_busTripInformations" WITH (action=materialize, ttl='2 hours 2 minutes', ttl_column='last_update') AS
SELECT 
    position.vehicle_id, 
    position.trip_id, 
    position.route_id, 
    position.direction_id, 
    keyed_max(moment, route_time) AS trip,
    min(moment) AS start_date,
    max(moment) AS last_update,
    twAvg(speed(transform(setSRID(tgeompoint(keyed_max(moment, route_time)), 4326), 3857))) * 3.6 AS speed_avg,
    length(transform(setSRID(tgeompoint(keyed_max(moment, route_time)), 4326), 3857)) AS distance,
    arrival_timestamp
FROM "busTrip_stream" AS position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id, position.arrival_timestamp;

