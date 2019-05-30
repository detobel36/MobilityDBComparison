CREATE EXTENSION IF NOT EXISTS mobilitydb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

----------- Bus Informations -----------
-- Not available

----------- Bus Déviation -----------
-- Not available

----------- Temps par région -----------

DROP TABLE IF EXISTS "time_spent2_timescaledb" CASCADE;
CREATE TABLE "time_spent2_timescaledb" (
    vehicle_id character varying(25) NOT NULL,
    trip_id character varying(250) NOT NULL, 
    start_date timestamp NOT NULL,
    last_update timestamp NOT NULL,
    time_spent integer NOT NULL,
    gid integer NOT NULL,
    CONSTRAINT time_spent2_timescaledb_unique UNIQUE(gid, vehicle_id, start_date)
);
SELECT create_hypertable('time_spent2_timescaledb', 'start_date');
