#!/bin/bash

SERVER_PROPERTIES=$2
MAP_SERVER_PROPERTIES=$3
BAREFOOT_INPUT=socket
#BAREFOOT_INPUT=server
BAREFOOT_OUTPUT=sql

ME=`whoami`
SERVICE='mtabarefoot-jar-with-dependencies.jar'
SCREEN_HISTORY=2048 # Nombre de ligne visible dans le screen
MAXHEAP=10240 #4096 = 4 Go
MINHEAP=4096 # 2048 = 2Go
SCREEN_NAME=barefoot
JAVA_CMD="java -verbose:gc -Xmx${MAXHEAP}M -Xms${MINHEAP}M -jar $SERVICE $SERVER_PROPERTIES $MAP_SERVER_PROPERTIES $BAREFOOT_INPUT $BAREFOOT_OUTPUT"

status_barefoot() {
    if pgrep -u $ME -f $SERVICE > /dev/null
    then
        true
    else
        false
    fi
}

start_barefoot() {
    if status_barefoot
    then
        echo "$SERVICE est déjà lancé !"
    else
        echo "Démarrage de $SERVICE"
        screen -h $SCREEN_HISTORY -dmS $SCREEN_NAME $JAVA_CMD
        sleep 7
        if status_barefoot
        then
           echo -e "\e[32mDémarrage de $SERVICE réussi\e[0m"
        else
           echo -e "\e[91mImpossible de démarrer $SERVICE!\e[0m"
        fi
    fi
}


stop_barefoot() {
    if status_barefoot
    then
        echo "Arrêt de $SERVICE"
        screen -S $SCREEN_NAME -X quit
        sleep 7
        if status_barefoot
        then
           echo -e "\e[91mImpossible d'arrêter $SERVICE!\e[0m"
        else
           echo "$SERVICE a bien été arrêté"
        fi
    else
        echo "$SERVICE n'est pas démarré"
    fi
}

usage() {
    echo "Utilisation: $0 {start <serverConfig> <mapConfig>|stop|status|restart|console}"
}


case "$1" in
    start)
        if [ "$#" -ne 3 ]; then
            echo -e "\e[91mIl manque des paramètres\e[0m"
            usage
        else
            start_barefoot
        fi
        ;;

    stop)
        stop_barefoot
        ;;

   restart)
        stop_barefoot
        start_barefoot
        ;;

   status)
        if status_barefoot
        then
            echo -e "\e[32mEN COURS\e[0m"
        else
            echo -e "\e[91mETEINT\e[0m"
        fi
        ;;

    console)
        if status_barefoot
        then
            screen -r $SCREEN_NAME
        else
            echo -e "\e[91m$SERVICE n'est pas démarré\e[0m"
        fi
        ;;

    *)
        usage
        exit 1
esac
 
exit 0
