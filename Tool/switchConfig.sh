rm ./config/map_server.properties

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <detobel36|local>"
else

    if [ "$1" == "detobel36" ]; then
        cp ./config/map_server_detobel36.properties ./config/map_server.properties
    elif [ "$1" == "local" ]
    then
        cp ./config/map_server_local.properties ./config/map_server.properties
    else
        echo "Erreur ('$1' est inconnu)  seulement: detobel36 ou local"
    fi

fi
