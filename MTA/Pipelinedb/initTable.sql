CREATE DATABASE mta_pipelinedb;
ALTER DATABASE mta_pipelinedb OWNER TO mtauser;
CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS pipelinedb CASCADE;


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
        time_array timestamp with time zone[] := '{}';
    BEGIN
        IF with_array IS NULL THEN
            return NULL;
        END IF;
        
        IF with_array = '{}' THEN
            return return_array;
        END IF;

        -- Iterate over each element in "concat_array".
        FOR loop_offset IN ARRAY_LOWER(with_array, 1)..ARRAY_UPPER(with_array, 1) LOOP
            IF NOT(startTimestamp(with_array[loop_offset]) = ANY(time_array)) OR NOT(NULL IS DISTINCT FROM (startTimestamp(with_array[loop_offset]) = ANY(time_array))) THEN
                return_array = ARRAY_APPEND(return_array, with_array[loop_offset]);
                time_array = ARRAY_APPEND(time_array, startTimestamp(with_array[loop_offset]));
            END IF;
        END LOOP;

    RETURN return_array;
END;
$BODY$ LANGUAGE plpgsql;

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
        time_array timestamp with time zone[] := '{}';
        last_location geometry := NULL;
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
                    NOT(startTimestamp(with_array[loop_offset]) = ANY(time_array)) OR 
                    NOT(NULL IS DISTINCT FROM (startTimestamp(with_array[loop_offset]) = ANY(time_array)))
                ) AND (
                    last_location IS NULL OR 
                    ST_Distance(last_location, ST_Transform(endValue(with_array[loop_offset]), 3857)) > 5
                ) THEN
                    return_array = ARRAY_APPEND(return_array, with_array[loop_offset]);
                    time_array = ARRAY_APPEND(time_array, startTimestamp(with_array[loop_offset]));
                    last_location = ST_Transform(endValue(with_array[loop_offset]), 3857);
            END IF;
        END LOOP;

    RETURN return_array;
END;
$BODY$ LANGUAGE plpgsql;





CREATE VIEW "busTripClean" WITH (action=materialize, ttl='1 day', ttl_column='start_date') AS
SELECT position.vehicle_id, 
    position.trip_id, 
    position.route_id, 
    position.direction_id, 
    min(position.moment) AS start_date,
    tgeompointseq(anyarray_uniq_clean(array_agg(position.inst)), true, true)
FROM "busPosition_stream" AS position
GROUP BY position.vehicle_id, position.trip_id, position.route_id, position.direction_id;
