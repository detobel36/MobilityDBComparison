#!/usr/bin/python

from sys import argv
import os
import json
import socket
import time
from datetime import datetime
from google.transit import gtfs_realtime_pb2

feed = gtfs_realtime_pb2.FeedMessage()

def netcat(host, port, content):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, int(port)))
    s.sendall(content.encode())
    s.shutdown(socket.SHUT_WR)
    res = ""
    while True:
        data = s.recv(4096)
        if not data:
            break
        res += data.decode()
        # print(repr(data))
    s.close()
    return res.strip()


if(len(argv) != 4):
    print("Erreur: Tous les parametres n'ont pas ete specifie: <dossier archive> <barefoot host> <barefoot port>")
else:
    archive_folder = argv[1]
    barefoot_host = argv[2]
    barefoot_port = argv[3]

    averageTime = 0
    countTest = 0
    pathToArchive = os.getcwd() + "/" + archive_folder
    lastTime = -1
    vehicle_id = ""

    # TODO ordonner l'odre des fichiers
    for filename in os.listdir(pathToArchive):
        print("Read file: " + filename)
        fichier = open(pathToArchive + "/" + filename, "rb")
        feed.ParseFromString(fichier.read())
        fichier.close()
        for entity in feed.entity:
            vehicle = entity.vehicle

            dateToStr = datetime.utcfromtimestamp(int(vehicle.timestamp)).strftime('%Y-%m-%d %H:%M:%S') + str("+0200")
            trip = vehicle.trip;
            if(vehicle_id == ""):
                vehicle_id = str(vehicle.vehicle.id)
            elif(vehicle_id != str(vehicle.vehicle.id)):
                continue

            #newId = str(vehicle.vehicle.id).replace("MTA NYCT_", '100')
            #newId = newId.replace("MTABC_", '200')
            infos = {u'time': str(dateToStr), \
                    u'id': str(vehicle.vehicle.id), \
                    u'point': u'POINT(' + str(float(vehicle.position.longitude)) + ' ' + str(float(vehicle.position.latitude)) + ')', \
                    u'trip_id': str(trip.trip_id), \
                    u'start_date': str(trip.start_date), \
                    u'route_id': str(trip.route_id), \
                    u'direction_id': str(trip.direction_id), \
                    u'bearing': str(float(vehicle.position.bearing)),
                    u'stop_id': str(vehicle.stop_id)}
            
            print("Send data: " + json.dumps(infos))
            startTime = time.time()
            result = netcat(barefoot_host, int(barefoot_port), json.dumps(infos))
            print("Result: " + result)
            diffTime = time.time()-startTime
            print("Execution time: " + str(diffTime))
            if(result == "SUCCESS"):
                countTest += 1
                averageTime = (averageTime*(countTest-1) + diffTime)/countTest
                print("Moyenne: " + str(averageTime))
                print("")
                
            input("enter to continue")
            # time.sleep(0.5)


