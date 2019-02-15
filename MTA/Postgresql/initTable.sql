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
    CONSTRAINT busTripUnique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);


CREATE SEQUENCE bus_trip_clean_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "busTripClean" (
    id integer DEFAULT nextval('bus_trip_clean_id_seq'::regclass) PRIMARY KEY,
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL,
    route_id character varying(25) NOT NULL,
    direction_id integer NOT NULL,
    trip tgeompoint NOT NULL,
    CONSTRAINT busTripCleanUnique UNIQUE(vehicle_id, trip_id, route_id, direction_id)
);