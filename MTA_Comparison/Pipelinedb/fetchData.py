#!/usr/bin/python
from common.abstractFetchData import AbstractFetchData
from common.config import config


class fetchDataPipelinedb(AbstractFetchData):

    def __init__(self):
        super().__init__(config(filename='Pipelinedb/config.ini'), logFile='fetchPipelinedb.log')


    def clearOldData(self):
        pass # Il faut remettre tout le stream a zéro je psen


    def processOnEntity(self, entity):
        self.insertToBusPositionStream(entity)


    def insertToBusPositionStream(self, entity):
        vehicle = entity.vehicle
        requestSQL = 'INSERT INTO "busPosition_stream" ' + \
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
                    ');'

        self.printDebug("Request:" + str(requestSQL))
        self.database.req(requestSQL)
        self.printDebug("Insert:" + str(vehicle.vehicle.id))
