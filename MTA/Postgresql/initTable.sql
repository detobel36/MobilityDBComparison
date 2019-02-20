CREATE DATABASE mta_postgresql;
ALTER DATABASE mta_pipelinedb OWNER TO mtauser;
CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;

CREATE SEQUENCE bus_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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
    stop_id integer NOT NULL
);


CREATE SEQUENCE bus_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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