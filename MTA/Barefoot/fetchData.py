#!/usr/bin/python
from common.abstractFetchData import AbstractFetchData
from common.config import config

from datetime import datetime
import json
import subprocess


class fetchDataBarefoot(AbstractFetchData):

    def __init__(self):
        self.maxPoint = 100
        self.currentPoint = 0
        super().__init__(config(filename='Barefoot/config.ini', section='barefoot'), \
                logFile='barefoot.log', enableDatabase=False)

    def clearOldData(self):
        pass


    def processOnEntity(self, entity):
        #if self.currentPoint < self.maxPoint:
        #if str(entity.vehicle.vehicle.id) == "MTA NYCT_264":
            # Send to Barefoot
            vehicle = entity.vehicle
            newId = str(vehicle.vehicle.id)

            # {"time": "2014-09-10 06:54:07+0200", "id": "\\x0001", "point": "POINT(11.564388282625075 48.16350662940509)"}
            dateToStr = datetime.utcfromtimestamp(int(vehicle.timestamp)).strftime('%Y-%m-%d %H:%M:%S') + str("+0200")

            infos = {u'time': str(dateToStr), u'id': str(newId), u'point': u'POINT(' + \
                str(float(vehicle.position.longitude)) + ' ' + str(float(vehicle.position.latitude)) + ')'}

            self.printDebug("Json send to " + self.dbConfig['host'] + ":" + self.dbConfig['port'])
            self.printDebug(json.dumps(infos))
            self.printInfo("Update: " + str(newId) + " " + str(dateToStr))
            subprocess.call("echo '%s' | netcat %s %s" % (json.dumps(infos), self.dbConfig['host'], self.dbConfig['port']), shell=True)

            #self.currentPoint += 1

    def endLoop(self):
        pass
        #self.currentPoint = 0
