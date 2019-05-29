# readAndStore
This code allow to open GTFS files contains in a folder `data` and to store data to database.

## Configuration
You have two files to configure.
- `config.properties`
    Which contains information to connect to database
- `request.sql`
    Which contain SQL request to store result. In this query you can use variable (which will be
    replaced):
    - stop_id
    - timeDiff
    - time
    - bearing
    - point (`POINT(X, Y)`)
    - direction_id
    - route_id
    - start_date
    - trip_id
    - id

## Data
Data are store into the folder `data`
