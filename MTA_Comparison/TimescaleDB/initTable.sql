CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;


----------- Bus Informations -----------

DROP TABLE IF EXISTS "timesdb_bus_informations" CASCADE;
CREATE SEQUENCE timesdb_bus_information_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE "timesdb_bus_informations" (
    id integer DEFAULT nextval('timesdb_bus_information_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL, 
    route_id character varying(25) NOT NULL, 
    direction_id integer NOT NULL, 
    start_date timestamp NOT NULL, 
    last_update timestamp NOT NULL, 
    distance double precision NOT NULL,
    trip tgeompoint NOT NULL,
    CONSTRAINT timesdb_bus_info_unique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
ALTER TABLE "timesdb_bus_informations" OWNER TO osmuser;
SELECT create_hypertable('timesdb_bus_informations', 'last_update');

-- TEST
DROP TABLE IF EXISTS "timesdb_bus_informations" CASCADE;
CREATE TABLE "timesdb_bus_informations" (
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL, 
    route_id character varying(25) NOT NULL, 
    direction_id integer NOT NULL, 
    start_date TIMESTAMPTZ NOT NULL, 
    last_update TIMESTAMPTZ NOT NULL, 
    distance double precision NOT NULL,
    trip tgeompoint NOT NULL,
    CONSTRAINT timesdb_bus_info_unique UNIQUE(vehicle_id, trip_id, route_id, direction_id, last_update),
    CONSTRAINT timesdb_bus_info_unique_time UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
SELECT create_hypertable('timesdb_bus_informations', 'last_update');



DROP FUNCTION IF EXISTS calculSpeed(distance double precision, last_update timestamp, start_date timestamp);
CREATE OR REPLACE FUNCTION calculSpeed(distance double precision, last_update timestamp, start_date timestamp)
    RETURNS double precision AS
$BODY$
    DECLARE
        result double precision := 0;
        total_time integer := EXTRACT(epoch FROM (last_update-start_date));
    BEGIN

        IF total_time = 0 THEN
            return result;
        END IF;

        result = distance/total_time;
    RETURN result;
END;
$BODY$ LANGUAGE plpgsql;

SELECT *, calculSpeed(distance, last_update, start_date) * 3.6 AS speed_avg 
FROM "timesdb_bus_informations";


----------- Bus Déviation -----------

DROP TABLE IF EXISTS "timesdb_bus_deviation" CASCADE;
CREATE SEQUENCE timesdb_bus_deviation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE "timesdb_bus_deviation" (
    id integer DEFAULT nextval('timesdb_bus_deviation_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    route_id character varying(25) NOT NULL, 
    direction_id integer NOT NULL, 
    last_update timestamp NOT NULL, 
    trip tgeompoint NOT NULL,
    CONSTRAINT bus_deviation_unique UNIQUE(vehicle_id, route_id, direction_id)
);
ALTER TABLE "timesdb_bus_deviation" OWNER TO osmuser;

INSERT INTO "timesdb_bus_deviation" (vehicle_id, route_id, direction_id, last_update, trip)
SELECT 
    'MTA NYCT_438', 
    'B8', 
    1, 
    to_timestamp(1555400935),
    tgeompointseq(tgeompointinst(ST_SetSRID(
        ST_MakePoint(-73.986332, 40.622947),4326), 
        to_timestamp(1555400935))
    )
FROM gtfs_line_geoms bus_line
WHERE bus_line.direction_id = 1 AND bus_line.route_id = 'B8' AND 
    ST_Distance(
            ST_Transform(
                ST_SetSRID(ST_MakePoint(-73.986332, 40.622947),4326),
                3857),
            ST_Transform(bus_line.the_geom, 3857)
    ) > 10
ON CONFLICT ON CONSTRAINT bus_deviation_unique 
DO UPDATE SET 
    last_update = to_timestamp(1555400935),
    trip = tgeompointseq(tgeompoints(
        ARRAY[
            tgeompointseq("busDeviation".trip), 
            tgeompointseq( 
                ARRAY[
                    endInstant(tgeompointseq("busDeviation".trip)), 
                    tgeompointinst(ST_SetSRID(
                        ST_MakePoint(-73.986332, 40.622947),4326), 
                        to_timestamp(1555400935)) 
                ], false, true)
        ])
    );




----------- Temps par région -----------

DROP TABLE IF EXISTS "timeSpent" CASCADE;
CREATE SEQUENCE time_spent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE "timeSpent" (
    id integer DEFAULT nextval('time_spent_id_seq'::regclass) PRIMARY KEY,
    time_spent integer NOT NULL,
    gid integer NOT NULL,
    name_0 character varying(75), 
    name_1 character varying(75),
    name_2 character varying(75),
    geom geometry(MultiPolygon),
    CONSTRAINT time_spent_unique UNIQUE(gid)
);
ALTER TABLE "timeSpent" OWNER TO osmuser;

INSERT INTO "timeSpent" (time_spent, gid, name_0, name_1, name_2, geom)
SELECT 
    30,
    usa_adm.gid,
    usa_adm.name_0, 
    usa_adm.name_1, 
    usa_adm.name_2, 
    usa_adm.geom
FROM usa_adm
WHERE ST_Intersects(st_setsrid(geom, 4326), ST_SetSRID(ST_MakePoint(-73.986332, 40.622947),4326))
ON CONFLICT ON CONSTRAINT time_spent_unique
DO UPDATE SET 
    time_spent = "timeSpent".time_spent + 30;
-- Problème: pas de gestion du temps. Obligé de clear régulièrement


-------- Temps par région SOLUTION 2 --------
DROP TABLE IF EXISTS "timeSpent2" CASCADE;
CREATE TABLE "timeSpent2" (
    id integer DEFAULT nextval('time_spent_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    start_date timestamp NOT NULL,
    last_update timestamp NOT NULL,
    time_spent integer NOT NULL,
    gid integer NOT NULL,
    CONSTRAINT time_spent2_unique UNIQUE(gid, vehicle_id, start_date)
);
ALTER TABLE "timeSpent2" OWNER TO osmuser;
INSERT INTO "timeSpent2" (vehicle_id, start_date, last_update, time_spent, gid)
SELECT 
    'MTA NYCT_438',
    to_timestamp(1555400932),
    to_timestamp(1555400932),
    30,
    usa_adm.gid
FROM usa_adm
WHERE ST_Intersects(st_setsrid(geom, 4326), ST_SetSRID(ST_MakePoint(-74.02359771728516, 40.607906341552734),4326))
ON CONFLICT ON CONSTRAINT time_spent2_unique
DO UPDATE SET 
    time_spent = "timeSpent2".time_spent + 30,
    last_update = to_timestamp(1555400932);


SELECT SUM("timeSpent2".time_spent) AS time_spent, 
    usa_adm.gid, usa_adm.name_0, 
    usa_adm.name_1, usa_adm.name_2, usa_adm.geom
FROM "timeSpent2"
    JOIN usa_adm
        ON usa_adm.gid = "timeSpent2".gid
WHERE last_update > date_trunc('day', NOW())
GROUP BY usa_adm.gid, usa_adm.name_0, usa_adm.name_1, 
    usa_adm.name_2, usa_adm.geom;

