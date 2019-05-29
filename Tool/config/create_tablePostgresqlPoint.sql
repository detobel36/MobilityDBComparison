CREATE TABLE mta_points (
    id integer NOT NULL, 
    trip tgeompoint NOT NULL, 
    moment timestamp without time zone NOT NULL
);
