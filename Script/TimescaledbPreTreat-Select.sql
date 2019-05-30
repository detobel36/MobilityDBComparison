----------- Bus Informations -----------
-- Not available

----------- Bus Déviation -----------
-- Not available

----------- Temps par région -----------

SELECT SUM("time_spent2_timescaledb".time_spent) AS time_spent, 
    usa_adm.gid, usa_adm.name_0, usa_adm.name_1, usa_adm.name_2, usa_adm.geom
FROM "time_spent2_timescaledb"
    JOIN usa_adm
        ON usa_adm.gid = "time_spent2_timescaledb".gid
WHERE last_update > date_trunc('day', NOW())
GROUP BY usa_adm.gid, usa_adm.name_0, usa_adm.name_1, usa_adm.name_2, usa_adm.geom;
