CREATE DATABASE mta_postgresql;
ALTER DATABASE mta_pipelinedb OWNER TO mtauser;
CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;


DROP SEQUENCE IF EXISTS "bus_position_id_seq" CASCADE;
CREATE SEQUENCE bus_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP TABLE IF EXISTS "busPosition" CASCADE;
CREATE TABLE "busPosition" (
    id integer DEFAULT nextval('bus_position_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    start_date integer NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    inst tgeompoint NOT NULL,
    bearing double precision NOT NULL,
    moment timestamp without time zone NOT NULL,
    stop_id integer NOT NULL,
    CONSTRAINT unique_busposition UNIQUE(vehicle_id, trip_id, start_date, route_id, direction_id, moment)
);

DROP SEQUENCE IF EXISTS "bus_trip_id_seq" CASCADE;
CREATE SEQUENCE bus_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP TABLE IF EXISTS "busTrip" CASCADE;
CREATE TABLE "busTrip" (
    id integer DEFAULT nextval('bus_trip_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    trip tgeompoint NOT NULL,
    start_date timestamp NOT NULL,
    CONSTRAINT busTripUnique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
CREATE INDEX ON "busTrip" (start_date);


CREATE SEQUENCE bus_trip_clean5_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "busTripClean5" (
    id integer DEFAULT nextval('bus_trip_clean5_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    trip tgeompoint NOT NULL,
    start_date timestamp NOT NULL,
    CONSTRAINT busTripClean5Unique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
CREATE INDEX ON "busTripClean5" (start_date);


CREATE SEQUENCE bus_trip_clean10_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "busTripClean10" (
    id integer DEFAULT nextval('bus_trip_clean10_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    trip tgeompoint NOT NULL,
    start_date timestamp NOT NULL,
    CONSTRAINT busTripClean10Unique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
CREATE INDEX ON "busTripClean10" (start_date);


CREATE SEQUENCE bus_trip_clean15_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "busTripClean15" (
    id integer DEFAULT nextval('bus_trip_clean15_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    trip tgeompoint NOT NULL,
    start_date timestamp NOT NULL,
    CONSTRAINT busTripClean15Unique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
CREATE INDEX ON "busTripClean15" (start_date);


----------- Bus Informations -----------

DROP TABLE IF EXISTS "busInformations" CASCADE;
CREATE SEQUENCE bus_information_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE "busInformations" (
    id integer DEFAULT nextval('bus_information_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL, 
    route_id character varying(25) NOT NULL, 
    direction_id integer NOT NULL, 
    start_date timestamp NOT NULL, 
    last_update timestamp NOT NULL, 
    distance double precision NOT NULL,
    trip tgeompoint NOT NULL,
    CONSTRAINT bus_info_unique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);
ALTER TABLE "busInformations" OWNER TO osmuser;


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
FROM "busInformations";

-- -- Exemple d'insertion
-- INSERT INTO "busInformations" (vehicle_id, trip_id, route_id, direction_id, start_date, last_update, distance, trip) 
-- VALUES (
--     'MTA NYCT_438', 
--     'JG_E9-Weekday-SDon-017800_B8_1', 
--     'B8', 
--     1, 
--     to_timestamp('20190416', 'YYYYMMDD'),
--     to_timestamp(1555400932),
--     0,
--     tgeompointseq(tgeompointinst(ST_SetSRID(
--         ST_MakePoint(40.607906341552734, -74.02359771728516),4326), 
--         to_timestamp(1555400932))
--     )
-- ) 
-- ON CONFLICT ON CONSTRAINT bus_info_unique 
-- DO UPDATE SET 
--     last_update = to_timestamp(1555400932),
--     trip = tgeompointseq(tgeompoints(
--         ARRAY[
--             tgeompointseq("busInformations".trip), 
--             tgeompointseq( 
--                 ARRAY[
--                     endInstant(tgeompointseq("busInformations".trip)), 
--                     tgeompointinst(ST_SetSRID(
--                         ST_MakePoint(40.607906341552734, -74.02359771728516),4326), 
--                         to_timestamp(1555400932)) 
--                 ], false, true)
--         ])
--     ),
--     distance = "busInformations".distance + ST_Distance(
--         ST_Transform(endValue(tgeompointseq("busInformations".trip)), 3857),
--         ST_Transform(ST_SetSRID(ST_MakePoint(40.607906341552734, -74.02359771728516),4326), 3857)
--     )
-- WHERE endTimestamp(tgeompointseq("busInformations".trip)) < to_timestamp(1555400932);



----------- Bus Déviation -----------

DROP TABLE IF EXISTS "busDeviation" CASCADE;
CREATE SEQUENCE bus_deviation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE "busDeviation" (
    id integer DEFAULT nextval('bus_deviation_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    route_id character varying(25) NOT NULL, 
    direction_id integer NOT NULL, 
    last_update timestamp NOT NULL, 
    trip tgeompoint NOT NULL,
    CONSTRAINT bus_deviation_unique UNIQUE(vehicle_id, route_id, direction_id)
);
ALTER TABLE "busDeviation" OWNER TO osmuser;

INSERT INTO "busDeviation" (vehicle_id, route_id, direction_id, last_update, trip)
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
    trip_id character varying(250) NOT NULL, 
    start_date timestamp NOT NULL,
    last_update timestamp NOT NULL,
    time_spent integer NOT NULL,
    gid integer NOT NULL,
    CONSTRAINT time_spent2_unique UNIQUE(gid, vehicle_id, trip_id, start_date)
);
ALTER TABLE "timeSpent2" OWNER TO osmuser;
INSERT INTO "timeSpent2" (vehicle_id, trip_id, start_date, last_update, time_spent, gid)
SELECT 
    'MTA NYCT_438',
    'JG_E9-Weekday-SDon-017800_B8_1',
    to_timestamp('20190416', 'YYYYMMDD'),
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


----- TODO

-- DROP VIEW IF EXISTS "view_timeSpent";
-- CREATE VIEW "view_timeSpent" WITH (action=materialize) AS 
-- SELECT
--     SUM(timediff) AS timeSpent,
--     gid,
--     name_0, 
--     name_1,
--     name_2,
--     geom,
--     max(moment) AS moment
-- FROM "busPosition_stream"
--     JOIN usa_adm
--         ON intersects(st_setsrid(geom, 4326), inst)
-- WHERE moment > date_trunc('day', NOW()) 
-- GROUP BY gid, name_0, name_1, name_2, geom;





-- INSERT INTO "busTrip" (vehicle_id, trip_id, route_id, direction_id, trip, start_date) 
-- VALUES (
--     'MTA NYCT_438', 
--     'JG_E9-Weekday-SDon-017800_B8_1', 
--     'B8', 
--     1, 
--     tgeompointseq(tgeompointinst(ST_SetSRID(
--         ST_MakePoint(40.607906341552734, -74.02359771728516),4326), 
--         to_timestamp(1555400932))), 
--     to_timestamp(1555400932) 
-- ) 
-- ON CONFLICT ON CONSTRAINT bustripunique 
-- DO UPDATE SET 
--     trip = tgeompointseq(tgeompoints(
--         ARRAY[
--             tgeompointseq("busTrip".trip), 
--             tgeompointseq( 
--                 ARRAY[
--                     endInstant(tgeompointseq("busTrip".trip)), 
--                     tgeompointinst(ST_SetSRID(
--                         ST_MakePoint(40.607906341552734, -74.02359771728516),4326), 
--                         to_timestamp(1555400932)) 
--                 ], false, true)
--         ])) 
-- WHERE endTimestamp(tgeompointseq("busTrip".trip)) < to_timestamp(1555400932);
