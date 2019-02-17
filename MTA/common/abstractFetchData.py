#!/usr/bin/python
from time import gmtime, strftime, sleep, time

from google.transit import gtfs_realtime_pb2
import urllib
import urllib.request

import abc

from common.config import config
from common.database import Database


class AbstractFetchData(abc.ABC):

    def __init__(self, dbConfig):
        self.mtaConfig = config(filename='common/config.ini', section='mta')
        self.minDistance = self.mtaConfig['min_distance']
        self.debug = str(self.mtaConfig['debug']).lower() == 'true'
        self.database = Database(dbConfig)
        self.loop()


    def printDebug(self, message):
        if self.debug:
            print('[DEBUG] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message))


    def printInfo(self, message):
        print('[INFO] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message))


    def loop(self):
        feed = gtfs_realtime_pb2.FeedMessage()
        try:
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
                    self.clearOldData()
                    compteur = 0

                sleep(int(self.mtaConfig['sleep_time']))
                self.printInfo("------------")


        except KeyboardInterrupt:
            pass # On arrête le programme

    def getApiUrl(self):
        return str(self.mtaConfig['api']) + str(self.mtaConfig['token'])

    def makeRequest(self, feed):
        response = urllib.request.urlopen(self.getApiUrl())
        feed.ParseFromString(response.read())
        return feed.entity


    @abc.abstractmethod
    def clearOldData(self):
        pass


    @abc.abstractmethod
    def processOnEntity(self, entity):
        pass

