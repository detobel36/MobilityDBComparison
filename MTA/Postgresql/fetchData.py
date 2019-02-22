#!/usr/bin/python
from common.abstractFetchData import AbstractFetchData
from common.config import config


class fetchDataPostgresql(AbstractFetchData):

    def __init__(self):
        super().__init__(config(filename='Postgresql/config.ini'), logFile='fetchPostgresql.log')


    def clearOldData(self):
        requestSQL = 'DELETE FROM "busTrip" WHERE start_date <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busPosition" WHERE moment <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busTripClean5" WHERE start_date <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busTripClean10" WHERE start_date <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busTripClean15" WHERE start_date <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))


    def processOnEntity(self, entity):
        self.insertToBusPosition(entity)
        self.insertToBusTrip(entity)
        # Valeur par défaut:
        # self.mtaConfig['min_distance']
        self.insertToBusTripCleanWithDistance(entity, 5)
        self.insertToBusTripCleanWithDistance(entity, 10)
        self.insertToBusTripCleanWithDistance(entity, 15)


    def insertToBusTrip(self, entity):
        vehicle = entity.vehicle

        requestSQL = 'INSERT INTO "busTrip"(vehicle_id, trip_id, route_id, direction_id, trip, start_date) ' + \
            'VALUES (' + \
                "'" + str(vehicle.vehicle.id) + "', " + \
                "'" + str(vehicle.trip.trip_id) + "', " + \
                "'" + str(vehicle.trip.route_id) + "', " + \
                str(int(vehicle.trip.direction_id)) + ', ' + \
                'tgeompointseq(tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                    str(float(vehicle.position.latitude)) + ', ' + \
                    str(float(vehicle.position.longitude)) + \
                    '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + '))), ' + \
                'to_timestamp(' + str(int(vehicle.timestamp)) + ') ' + \
            ') ' + \
        'ON CONFLICT ON CONSTRAINT bustripunique ' + \
        'DO ' + \
            'UPDATE ' + \
            'SET trip = tgeompointseq(tgeompoints(ARRAY[' + \
                'tgeompointseq("busTrip".trip), ' + \
                'tgeompointseq( ' + \
                    'ARRAY[' + \
                        'endInstant(tgeompointseq("busTrip".trip)), ' + \
                        'tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                            str(float(vehicle.position.latitude)) + ', ' + \
                            str(float(vehicle.position.longitude)) + \
                            '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + ')) ' + \
                    '], false, true' + \
                ')' + \
            '])) ' + \
            'WHERE ' + \
                'endTimestamp(tgeompointseq("busTrip".trip)) < to_timestamp(' + str(int(vehicle.timestamp)) + ');'
        
        self.printDebug("Request:" + str(requestSQL))
        self.database.req(requestSQL)
        self.printDebug("Insert:" + str(vehicle.vehicle.id))


    def insertToBusTripCleanWithDistance(self, entity, minDistance):  
        vehicle = entity.vehicle

        requestSQL = 'INSERT INTO "busTripClean' + str(minDistance) + '"(vehicle_id, trip_id, route_id, direction_id, trip, start_date) ' + \
            'VALUES (' + \
                "'" + str(vehicle.vehicle.id) + "', " + \
                "'" + str(vehicle.trip.trip_id) + "', " + \
                "'" + str(vehicle.trip.route_id) + "', " + \
                str(int(vehicle.trip.direction_id)) + ', ' + \
                'tgeompointseq(tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                    str(float(vehicle.position.latitude)) + ', ' + \
                    str(float(vehicle.position.longitude)) + \
                    '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + '))), ' + \
                'to_timestamp(' + str(int(vehicle.timestamp)) + ') ' + \
            ') ' + \
        'ON CONFLICT ON CONSTRAINT bustripclean' + str(minDistance) + 'unique ' + \
        'DO ' + \
            'UPDATE ' + \
            'SET trip = tgeompointseq(tgeompoints(ARRAY[' + \
                'tgeompointseq("busTripClean' + str(minDistance) + '".trip), ' + \
                'tgeompointseq( ' + \
                    'ARRAY[' + \
                        'endInstant(tgeompointseq("busTripClean' + str(minDistance) + '".trip)), ' + \
                        'tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                            str(float(vehicle.position.latitude)) + ', ' + \
                            str(float(vehicle.position.longitude)) + \
                            '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + ')) ' + \
                    '], false, true' + \
                ')' + \
            '])) ' + \
            'WHERE ' + \
                'endTimestamp(tgeompointseq("busTripClean' + str(minDistance) + '".trip)) < to_timestamp(' + str(int(vehicle.timestamp)) + ') ' + \
            'AND ' + \
                'ST_Distance(' + \
                    'ST_Transform(endValue("busTripClean' + str(minDistance) + '".trip), 3857), ' + \
                    'ST_Transform(ST_SetSRID(ST_MakePoint(' + str(float(vehicle.position.latitude)) + \
                        ', ' + str(float(vehicle.position.longitude)) + '),4326), 3857) ' + \
                ') > ' + str(minDistance)

        self.printDebug("Request:" + str(requestSQL))
        self.database.req(requestSQL)
        self.printDebug("Insert:" + str(vehicle.vehicle.id)) 


    def insertToBusPosition(self, entity):
        vehicle = entity.vehicle
        requestSQL = 'INSERT INTO "busPosition" ' + \
                    '("vehicle_id", "trip_id", "start_date", "route_id", "direction_id", "inst", ' + \
                    '"bearing", "moment", "stop_id") ' + \
                    'VALUES(' + \
                        "'" + str(vehicle.vehicle.id) + "', " + \
                        "'" + str(vehicle.trip.trip_id) + "', " + \
                        str(int(vehicle.trip.start_date)) + ", " + \
                        "'" + str(vehicle.trip.route_id) + "', " + \
                        str(int(vehicle.trip.direction_id)) + ", " + \
                        "tgeompointinst(ST_SetSRID(ST_MakePoint(" + \
                            str(float(vehicle.position.latitude)) + "," + \
                            str(float(vehicle.position.longitude)) + "),4326), to_timestamp(" + str(int(vehicle.timestamp)) + ")), " + \
                        str(float(vehicle.position.bearing)) + ", " + \
                        "to_timestamp(" + str(int(vehicle.timestamp)) + "), " + \
                        str(int(vehicle.stop_id)) + \
                    ') ' + \
                    'ON CONFLICT ON CONSTRAINT unique_busposition ' + \
                    'DO NOTHING'

        self.printDebug("Request:" + str(requestSQL))
        self.database.req(requestSQL)
        self.printDebug("Insert:" + str(vehicle.vehicle.id))

