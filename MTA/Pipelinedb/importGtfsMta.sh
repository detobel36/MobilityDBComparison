wget http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip
unzip google_transit_manhattan.zip -d google_transit_manhattan
rm google_transit_manhattan.zip
git clone https://github.com/detobel36/gtfs_SQL_importer.git
cd gtfs_SQL_importer/src

cat gtfs_tables.sql \
  <(python import_gtfs_to_sql.py ../../google_transit_manhattan/) \
  gtfs_tables_makespatial.sql \
  gtfs_add_shape_distance.sql \
  gtfs_add_stop_dist_along_shape.sql \
  gtfs_tables_makeindexes.sql \
  vacuumer.sql \
| psql -d mta_pipelinedb


rm -rf gtfs_SQL_importer
rm -rf google_transit_manhattan
