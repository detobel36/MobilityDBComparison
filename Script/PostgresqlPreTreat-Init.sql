CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;

----------- Bus Informations -----------

DROP TABLE IF EXISTS "busInformations" CASCADE;
DROP SEQUENCE IF EXISTS "bus_information_id_seq";
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


----------- Bus Déviation -----------

DROP TABLE IF EXISTS "busDeviation" CASCADE;
DROP SEQUENCE IF EXISTS "bus_deviation_id_seq";
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

----------- Temps par région -----------

DROP TABLE IF EXISTS "timeSpent2" CASCADE;
DROP TABLE IF EXISTS "time_spent_id_seq";
CREATE SEQUENCE time_spent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
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
