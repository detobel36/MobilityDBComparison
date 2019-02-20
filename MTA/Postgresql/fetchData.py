#!/usr/bin/python
from common.abstractFetchData import AbstractFetchData
from common.config import config


class fetchDataPostgresql(AbstractFetchData):

    def __init__(self):
        super().__init__(config(filename='Postgresql/config.ini'), logFile='fetchPostgresql.log')


    def clearOldData(self):
        requestSQL = 'DELETE FROM "busTrip" WHERE startTimestamp(trip) <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busPosition" WHERE moment <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))
        requestSQL = 'DELETE FROM "busTripClean" WHERE startTimestamp(trip) <= NOW()+ interval \'-1 day\';'
        self.database.req(requestSQL)
        self.printDebug("Delete data:" + str(requestSQL))


    def processOnEntity(self, entity):
        self.insertToBusPosition(entity)
        self.insertToBusTrip(entity)
        self.insertToBusTripClean(entity)


    def insertToBusTrip(self, entity):
        vehicle = entity.vehicle

        requestSQL = 'INSERT INTO "busTrip"(vehicle_id, trip_id, route_id, direction_id, trip) ' + \
            'VALUES (' + \
                "'" + str(vehicle.vehicle.id) + "', " + \
                "'" + str(vehicle.trip.trip_id) + "', " + \
                "'" + str(vehicle.trip.route_id) + "', " + \
                str(int(vehicle.trip.direction_id)) + ', ' + \
                'tgeompointseq(tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                    str(float(vehicle.position.latitude)) + ', ' + \
                    str(float(vehicle.position.longitude)) + \
                    '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + ')))' + \
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


    def insertToBusTripClean(self, entity):
        vehicle = entity.vehicle

        requestSQL = 'INSERT INTO "busTripClean"(vehicle_id, trip_id, route_id, direction_id, trip) ' + \
            'VALUES (' + \
                "'" + str(vehicle.vehicle.id) + "', " + \
                "'" + str(vehicle.trip.trip_id) + "', " + \
                "'" + str(vehicle.trip.route_id) + "', " + \
                str(int(vehicle.trip.direction_id)) + ', ' + \
                'tgeompointseq(tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                    str(float(vehicle.position.latitude)) + ', ' + \
                    str(float(vehicle.position.longitude)) + \
                    '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + ')))' + \
            ') ' + \
        'ON CONFLICT ON CONSTRAINT bustripcleanunique ' + \
        'DO ' + \
            'UPDATE ' + \
            'SET trip = tgeompointseq(tgeompoints(ARRAY[' + \
                'tgeompointseq("busTripClean".trip), ' + \
                'tgeompointseq( ' + \
                    'ARRAY[' + \
                        'endInstant(tgeompointseq("busTripClean".trip)), ' + \
                        'tgeompointinst(ST_SetSRID(ST_MakePoint(' + \
                            str(float(vehicle.position.latitude)) + ', ' + \
                            str(float(vehicle.position.longitude)) + \
                            '),4326), to_timestamp(' + str(int(vehicle.timestamp)) + ')) ' + \
                    '], false, true' + \
                ')' + \
            '])) ' + \
            'WHERE ' + \
                'endTimestamp(tgeompointseq("busTripClean".trip)) < to_timestamp(' + str(int(vehicle.timestamp)) + ') ' + \
            'AND ' + \
                'ST_Distance(' + \
                    'ST_Transform(endValue("busTripClean".trip), 3857), ' + \
                    'ST_Transform(ST_SetSRID(ST_MakePoint(' + str(float(vehicle.position.latitude)) + \
                        ', ' + str(float(vehicle.position.longitude)) + '),4326), 3857) ' + \
                ') > ' + str(self.mtaConfig['min_distance'])
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

