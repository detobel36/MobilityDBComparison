from time import gmtime, strftime
from time import sleep

from google.transit import gtfs_realtime_pb2
import urllib
import urllib.request

from config import config
from database import Database


DEBUG = False
MIN_DISTANCE=5 # En metre
SLEEP_TIME=30  # En seconde


def printDebug(message):
    if DEBUG:
        print('[DEBUG] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message))

def printInfo(message):
    print('[INFO] ' + strftime("%d-%m-%Y %H:%M:%S", gmtime()) + ": " + str(message))


def makeRequest(feed, apiURL):
    response = urllib.request.urlopen(apiURL)
    feed.ParseFromString(response.read())
    return feed.entity


def insertToBusPositionStream(database, allEntity):
    nbrOfEntity = 0
    for entity in allEntity:
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

        nbrOfEntity += 1
        printDebug("Request:" + str(requestSQL))
        database.req(requestSQL)
        printDebug("Insert:" + str(vehicle.vehicle.id))

    return nbrOfEntity


def clearOldData(database):
    pass
    # requestSQL = 'DELETE FROM "busTrip" WHERE startTimestamp(trip) <= NOW()+ interval \'-1 day\';'
    # database.req(requestSQL)
    # printDebug("Delete data:" + str(requestSQL))


def mainLoop():
    configuration = config(section='mta')

    database = Database()
    apiURL = 'http://gtfsrt.prod.obanyc.com/vehiclePositions?key=' + str(configuration['token'])
    printInfo("Requête à l'addresse: " + str(apiURL))
    feed = gtfs_realtime_pb2.FeedMessage()
    clearOldData(database)
    
    try:
        # compteur = 0
        while True:
            printInfo("New request started")
            result = makeRequest(feed, apiURL)
            nbrEntry = insertToBusPositionStream(database, result)
            printInfo("Number of entry recieved: " + str(nbrEntry))

            # compteur += 1
            # if compteur == 120: # Toute les heures netoyage des données
            #     clearOldData(database)

            sleep(SLEEP_TIME)
            printInfo("------------")


    except KeyboardInterrupt:
        pass # On arrête le programme


if __name__ == '__main__':
    mainLoop()


"""
Examle of result given by API

    id: "MTABC_3756"
    vehicle {
      trip {
        trip_id: "21593971-JKPD8-JK_D8-Weekday-10-SDon"
        start_date: "20190102"
        route_id: "Q60"
        direction_id: 1
      }
      position {
        latitude: 40.70775604248047
        longitude: -73.8174819946289
        bearing: 124.2440185546875
      }
      timestamp: 1546441012
      stop_id: "505000"
      vehicle {
        id: "MTABC_3756"
      }
    }

"""
