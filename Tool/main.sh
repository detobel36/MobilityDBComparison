#!/bin/bash

# Doc: https://www.computerhope.com/unix/bash/getopts.htm


# GLOBAL parameters
ARCHIVE_PATH=/var/mtagrab/archive
WORK_PATH=./tmp
NBR_ARCHIVE=3
DEBUG=false

# BAREFOOT parameters
BAREFOOT_HOST=127.0.0.1
BAREFOOT_PORT=1234
START_BAREFOOT=false
SERVER_PROPERTIES="config/tracker.properties"
MAP_SERVER_PROPERTIES="config/map_server.properties"


function usage {
    echo -e "Utilisation: $0 [ OPTIONS ]"
    echo -e ""
    echo -e "Option\t\t\tDescription"
    echo -e "-n <num>\t\tNombre d'archive à traiter"
    echo -e "-p <num>\t\tPort de communication avec Barefoot"
    echo -e "-b, --barefoot\t\tDémarrer barefoot également"
    echo -e "-d, --debug\t\tDebug mode"
    echo -e "-h, --help\t\tAfficher ce texte"
}

function exit_abnormal {
    usage
    exit 1
}

function fetchLastMta {
    ls $ARCHIVE_PATH -Art | tail -n $(($1+1)) | head -n $1
}

function debugMsg {
    if [ "$DEBUG" = true ]; then
        echo $1
    fi
}

function treatArgs {
    for p in "$@"; do
        case "${p}" in
            -h|--help)
                usage
                exit 0
                ;;

            -d|--debug)
                DEBUG=true
                ;;

            -b|--barefoot)
                START_BAREFOOT=true
                ;;

        esac
    done
}

function startMtaBarefootJar {
    debugMsg "Mise à jour du port barefoot: $BAREFOOT_PORT"
    sed -i 's/server\.port=[0-9]*/server\.port='"$BAREFOOT_PORT"'/' $SERVER_PROPERTIES
    ./startMtaBarefoot.sh start $SERVER_PROPERTIES $MAP_SERVER_PROPERTIES
}


#############################

treatArgs "${@:$?}"
while getopts ":n:p:" options; do
    case "${options}" in
        n)
            NBR_ARCHIVE=${OPTARG}
            re_isanum='^[0-9]+$'
            if ! [[ $NBR_ARCHIVE =~ $re_isanum ]] ; then
                echo "Erreur: le nombre d'archive récupéré doit être un nombre positif."
                exit_abnormally
                exit 1
            elif [ $NBR_ARCHIVE -eq "0" ]; then
                echo "Erreur: le nombre d'archive récupéré doit être suppérieur à zéro."
                exit_abnormal
            fi
            ;;

        p)
            BAREFOOT_PORT=${OPTARG}
            re_isanum='^[0-9]+$'
            if ! [[ $BAREFOOT_PORT =~ $re_isanum ]] ; then
                echo "Erreur: le port utilisé pour barefoot doit être un nombre positif."
                exit_abnormally
                exit 1
            elif [ $BAREFOOT_PORT -eq "0" ]; then
                echo "Erreur: le port utilisé pour barefoot doit être suppérieur à zéro."
                exit_abnormal
            fi
            ;;
    esac
done


archiveFile=`fetchLastMta $NBR_ARCHIVE`

debugMsg "Delete folder $WORK_PATH"
rm -rf $WORK_PATH
mkdir -p $WORK_PATH

debugMsg "Copy files: $archiveFile"

for file in $archiveFile; do
    cp $ARCHIVE_PATH"/"$file $WORK_PATH"/"$file
    unxz $WORK_PATH"/"$file
done

if [ "$START_BAREFOOT" = true ]; then
    startMtaBarefootJar
fi
# python3 readAndSendMta.py $WORK_PATH $BAREFOOT_HOST $BAREFOOT_PORT
