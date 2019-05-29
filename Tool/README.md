# Tools
This folder contains files used in "production" to treat MTA data with a custom Barefoot version.

## MTABarefoot
This program uses Barefoot as a library to create a system to get MTA data (in several different ways), 
process these data and store them into a database (SQL queries can be completely customized).   
Available here: https://github.com/detobel36/MTABarefoot

### Command
To start and stop MTABarefoot, you can use the file `startMtaBarefoot.sh`.    
When the program is start you can execute different commands:
- `help`
    To display all informations
- `reload_output`
    To reload the output configuration (`map_server`)
- `view_query`
    To view all SQL queries
    

# Files descriptions

## [NewYorkCounty](./NewYorkCounty)
Contains data of New york city. These data must be import for some operation. Note that this folder
contains a script to update the data `import.sh`.

## [config](./config)
Contains three types of files:
- Barefoot Track server configuration
- Barefoot Map server configuration (*= SQL Server*)
- SQL Request file

## [tmp](./tmp)
Contains data archives

## [importGtfsMta.sh](./importGtfsMta.sh)
Import New York GTFS informations like bus road, bus stops...   
This script use the repository [gtfs_SQL_importer](https://github.com/detobel36/gtfs_SQL_importer)

## [main.sh](./main.sh)
Automaticaly fetch archive files, uncompress and store in the `tmp` folder. Possibility to launch
automaticaly MTABarefoot.

## mtabarefoot-jar-with-dependencies.jar
Program describe previously in the point "MTABarefoot"

## [readAndSendMta.py](readAndSendMta.py)
Allow to read GTFS data and send it to MTABarefoot/Barefoot (with socket protocol).

## [startMtaBarefoot.sh](startMtaBarefoot.sh)
This script allow to start (and stop) MTABarefoot in a _screen_.

## [switchConfig.sh](switchConfig.sh)
Script to switch easily configuration (between personal server and localhost).
