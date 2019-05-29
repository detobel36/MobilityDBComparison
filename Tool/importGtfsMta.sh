#/bin/bash

if [ $# -ne 1 ]; then
    echo "Vous devez précisé la base de données"
    exit 1;
fi

echo "Set up repository:"
git clone https://github.com/detobel36/gtfs_SQL_importer.git
cd gtfs_SQL_importer
mkdir data
cd data

echo "Download Manhattan:"
wget http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip
unzip google_transit_manhattan.zip -d google_transit_manhattan

echo "Download Bronx:"
wget http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip
unzip google_transit_bronx.zip -d google_transit_bronx

echo "Download Brooklyn:"
wget http://web.mta.info/developers/data/nyct/bus/google_transit_brooklyn.zip
unzip google_transit_brooklyn.zip -d google_transit_brooklyn

echo "Download Queens:"
wget http://web.mta.info/developers/data/nyct/bus/google_transit_queens.zip
unzip google_transit_queens.zip -d google_transit_queens

echo "Download Staten Island:"
wget http://web.mta.info/developers/data/nyct/bus/google_transit_staten_island.zip
unzip google_transit_staten_island.zip -d google_transit_staten_island

cd ../src

cat gtfs_tables.sql \
  <(python import_gtfs_to_sql.py "../data/google_transit_manhattan/, ../data/google_transit_bronx/, ../data/google_transit_brooklyn/, ../data/google_transit_queens/, ../data/google_transit_staten_island/") \
  gtfs_tables_makespatial.sql \
  gtfs_add_shape_distance.sql \
  gtfs_add_stop_dist_along_shape.sql \
  gtfs_tables_makeindexes.sql \
  vacuumer.sql \
| psql -d $1


cd ../../
rm -rf gtfs_SQL_importer