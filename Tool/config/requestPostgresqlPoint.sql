INSERT INTO "mta_points"(id, trip, moment) VALUES (:id , tgeompointseq(tgeompointinst(ST_SetSRID(ST_GeomFromText(':point '), 4326), to_timestamp(':time '))), to_timestamp(':time '));
SELECT * FROM "mta_points" WHERE id = :id ;
