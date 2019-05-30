----------- Bus Informations -----------

SELECT *, calculSpeed(distance, last_update, start_date) * 3.6 AS speed_avg 
FROM "busInformations";


----------- Bus Déviation -----------

SELECT * 
FROM "busDeviation";


----------- Temps par région -----------

SELECT SUM("timeSpent2".time_spent) AS time_spent, 
    usa_adm.gid, usa_adm.name_0, usa_adm.name_1, usa_adm.name_2, usa_adm.geom
FROM "timeSpent2"
    JOIN usa_adm
        ON usa_adm.gid = "timeSpent2".gid
WHERE last_update > date_trunc('day', NOW())
GROUP BY usa_adm.gid, usa_adm.name_0, usa_adm.name_1, usa_adm.name_2, usa_adm.geom;
