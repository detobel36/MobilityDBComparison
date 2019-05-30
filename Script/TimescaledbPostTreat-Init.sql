CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

----------- Bus Informations -----------
----------- Bus Déviation -----------
----------- Temps par région -----------

DROP TABLE IF EXISTS "vehicle_position_timescaledb" CASCADE;
CREATE TABLE vehicle_position_timescaledb (
    vehicle_id character varying(25),
    trip_id character varying(250),
    start_date integer,
    route_id character varying(25),
    direction_id integer,
    inst tgeompoint,
    bearing double precision,
    moment timestamp without time zone,
    stop_id integer,
    timeDiff integer,
    CONSTRAINT vehicle_position_timescaledb_unique UNIQUE(vehicle_id, trip_id, start_date, route_id, direction_id, moment)
);
SELECT create_hypertable('vehicle_position_timescaledb', 'moment');

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