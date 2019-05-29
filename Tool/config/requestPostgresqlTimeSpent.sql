INSERT INTO "timeSpent2" (vehicle_id, start_date, last_update, time_spent, gid)
SELECT 
    ':id ',
    to_timestamp(':start_date ', 'YYYYMMDD'),
    to_timestamp(:time ),
    :timeDiff ,
    usa_adm.gid
FROM usa_adm
WHERE ST_Intersects(st_setsrid(geom, 4326), ST_SetSRID(ST_GeomFromText(':point '),4326))
ON CONFLICT ON CONSTRAINT time_spent2_unique
DO UPDATE SET 
    time_spent = "timeSpent2".time_spent + :timeDiff ,
    last_update = to_timestamp(:time );

