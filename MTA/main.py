#!/usr/bin/python
from sys import argv

from Postgresql.fetchDataObject import fetchDataPostgresql

# Permet d'activer des messages de débug
# DEBUG = False
# # Distance minimum entre deux points (pour qu'ils soient enregistré)
# MIN_DISTANCE=5 # En mètre
# # Temps entre deux récupération de données
# SLEEP_TIME=30  # En seconde
# # URL où l'on doit faire des appels
# API_URL='http://gtfsrt.prod.obanyc.com/vehiclePositions?key='


def main():
    if(len(argv) == 1):
        print("Il manque des paramètres.")
        printHelp()
    else:
        if(argv[1] == 'postgresql'):
            postgresql()
        elif(argv[1] == 'pipelinedb'):
            pipelinedb()


def postgresql():
    fetchDataPostgresql()


def pipelinedb():
    pass


def printHelp():
    print("Commande: python3 " + str(argv[0]) + " [param]")
    print("Paramètres possibles:")
    print("  postgresql")
    print("    Permet de lancer le test avec l'installation PostgreSQL")
    print("  pipelinedb")
    print("    Permet de lancer le test avec l'installation PipelineDB")

if __name__ == '__main__':
    main()