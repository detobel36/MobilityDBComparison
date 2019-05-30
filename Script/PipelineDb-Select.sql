----------- Bus Informations -----------
SELECT vehicle_id, trip_id, route_id, direction_id, start_date, last_update,
distance, speed_avg, numInstants(trip) AS nbrInstant
FROM "view_busInformations";

----------- Bus Déviation -----------
SELECT vehicle_id, route_id, direction_id, last_update, numInstants(trip) AS nbrInstant
FROM "view_busOutOfRoad";

----------- Temps par région -----------
SELECT timeSpend, gid, name_0, name_1, name_2, moment 
FROM "view_timeSpent";