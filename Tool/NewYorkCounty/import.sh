#/bin/bash

if [ $# -ne 1 ]; then
    echo "Vous devez précisé la base de données"
    exit 1;
fi

/usr/bin/shp2pgsql -c -I USA_adm2.shp usa_adm > usa_adm.sql
psql -d $1 -f usa_adm.sql
