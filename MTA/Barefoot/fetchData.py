#!/usr/bin/python
from common.abstractFetchData import AbstractFetchData
from common.config import config

from datetime import datetime
import json
import subprocess


class fetchDataBarefoot(AbstractFetchData):

    def __init__(self):
        super().__init__(config(filename='Barefoot/config.ini', section='barefoot'), \
                logFile='barefoot.log', enableDatabase=False)


    def clearOldData(self):
        pass


    def processOnEntity(self, entity):
        # Send to Barefoot
        vehicle = entity.vehicle
        # {"time": "2014-09-10 06:54:07+0200", "id": "\\x0001", "point": "POINT(11.564388282625075 48.16350662940509)"}
        dateToStr = datetime.utcfromtimestamp(int(vehicle.timestamp)).strftime('%Y-%m-%d %H:%M:%S') + str("+0200")
        newId = str(vehicle.vehicle.id).replace("MTA NYCT_", '')

        infos = {u'time': str(dateToStr), u'id': str(newId), u'point': u'POINT(' + \
            str(float(vehicle.position.latitude)) + ' ' + str(float(vehicle.position.longitude)) + ')'}

        self.printDebug("Json send to " + self.dbConfig['host'] + ":" + self.dbConfig['port'])
        self.printDebug(json.dumps(infos))
        subprocess.call("echo '%s' | netcat %s %s" % (json.dumps(infos), self.dbConfig['host'], self.dbConfig['port']), shell=True)

