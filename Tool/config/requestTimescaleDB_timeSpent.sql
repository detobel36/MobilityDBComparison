INSERT INTO "time_spent2_timescaledb" (vehicle_id, start_date, last_update, timespent, gid)
SELECT 
    ':id ',
    to_timestamp(':start_date ', 'YYYYMMDD'),
    to_timestamp(:time ),
    :timeDiff ,
    usa_adm.gid
FROM usa_adm
WHERE ST_Intersects(st_setsrid(geom, 4326), ST_SetSRID(ST_GeomFromText(':point '),4326))
ON CONFLICT (gid, vehicle_id, start_date) 
DO UPDATE SET 
    timespent = "time_spent2_timescaledb".timespent + :timeDiff ,
    last_update = to_timestamp(:time );

