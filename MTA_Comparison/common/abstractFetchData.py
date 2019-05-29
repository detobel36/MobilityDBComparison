#!/usr/bin/python
from time import gmtime, strftime, sleep, time

from google.transit import gtfs_realtime_pb2
import urllib
import urllib.request

import abc

from common.config import config
from common.database import Database


class AbstractFetchData(abc.ABC):

    def __init__(self, dbConfig, logFile='debug.log', enableDatabase=True):
        self.mtaConfig = config(filename='common/config.ini', section='mta')
        self.minDistance = self.mtaConfig['min_distance']
        self.debug = str(self.mtaConfig['debug']).lower() == 'true'
        self.logFileName = logFile
        self.dbConfig = dbConfig
        if(enableDatabase):
            self.database = Database(dbConfig)
        self.loop()


    def printDebug(self, message):
        if self.debug:
            logMessage = '[DEBUG] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message)
            with open(self.logFileName, "a") as f:
                f.write(logMessage + "\n")
            print(logMessage)


    def printInfo(self, message):
        logMessage = '[INFO] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message)
        with open(self.logFileName, "a") as f:
            f.write(logMessage + "\n")
        print(logMessage)


    def loop(self):
        self.printInfo("------ Start ------")
        feed = gtfs_realtime_pb2.FeedMessage()
        try:
            self.printInfo("Clear old data")
            self.clearOldData()

            compteur = 0
            while True:
                self.printInfo("New request started")
                result = self.makeRequest(feed)
                self.printInfo("Nombre d'entrée: " + str(len(result)))
                startProccessTime = time()
                for entity in result:
                    self.processOnEntity(entity)
                self.printInfo("Temps d'exécussion: " + str(time() - startProccessTime) + " sec")

                compteur += 1
                if compteur == 120: # Toute les heures netoyage des données
                    self.printInfo("Clear old data");
                    self.clearOldData()
                    compteur = 0

                sleepTime = int(self.mtaConfig['sleep_time'])
                if sleepTime > 0:
                    sleep(sleepTime)
                self.endLoop()
                self.printInfo("------------")


        except KeyboardInterrupt:
            pass # On arrête le programme

        self.printInfo("------ End ------")

    def getApiUrl(self):
        return str(self.mtaConfig['api']) + str(self.mtaConfig['token'])

    def makeRequest(self, feed):
        response = urllib.request.urlopen(self.getApiUrl())
        feed.ParseFromString(response.read())
        return feed.entity

    def endLoop(self):
        pass

    @abc.abstractmethod
    def clearOldData(self):
        pass


    @abc.abstractmethod
    def processOnEntity(self, entity):
        pass

