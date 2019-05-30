CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS pipelinedb CASCADE;

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


----------- Bus Informations -----------

DROP VIEW IF EXISTS "view_busInformations" CASCADE;
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


----------- Temps par région -----------

DROP VIEW IF EXISTS "view_timeSpent" CASCADE;
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