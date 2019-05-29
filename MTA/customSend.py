import subprocess
from datetime import datetime
from common.config import config
from time import time, sleep
import sys

dbConfig = config(filename='Barefoot/configGeodata.ini', section='barefoot')

def makeRequest(id, coordinateX, coordinateY):
    positionTime = datetime.utcfromtimestamp(time()).strftime('%Y-%m-%d %H:%M:%S') + str("+0200")
    jsonData = '{"id": "' + str(id) + '", "point": "POINT(' + str(coordinateX) + ' ' + str(coordinateY) + ')", "time": "' + str(positionTime) + '"}'
    print("Json: " + str(jsonData))

    subprocess.call("echo '%s' | netcat %s %s" % (jsonData, dbConfig['host'], dbConfig['port']), shell=True)



if len(sys.argv) > 1:

    if sys.argv[1] == "auto":
        makeRequest("NYCT_264", -73.84397888183594, 40.84199523925781) # 2019-03-04 13:39:37+0200
        print("Sleep 30")
        sleep(30)
        makeRequest("NYCT_264", -73.84542846679688, 40.8436279296875)  # 2019-03-04 13:40:08+0200
        print("Sleep 30")
        sleep(30)
        makeRequest("NYCT_264", -73.84579467773438, 40.84402084350586) # 2019-03-04 13:40:40+0200

    elif len(sys.argv) == 4:
        id = sys.argv[1]
        coordinateX = float(sys.argv[2])
        coordinateY = float(sys.argv[3])
        makeRequest(id, coordinateX, coordinateY)
    else:
         print("Le nombre de paramètre n'est pas bon: python3 " + str(sys.argv[0]) + " <id> <x> <y>")
         exit()

else:
    id = input("id: ")
    coordinateX = float(input("x (-73.96): "))
    coordinateY = float(input("y (40.693): "))
    makeRequest(id, coordinateX, coordinateY)

#print('{"id": "MTA NYCT_7283", "point": "POINT(-73.96578216552734 40.69345474243164)", "time": "2019-03-13 16:46:24+0200"}')
