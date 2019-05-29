# Tools
This folder contains files used in "production" to treat MTA data with a custom Barefoot version.

# Files descriptions

## MTABarefoot
This program uses Barefoot as a library to create a system to get MTA data (in several different ways), process these data and store them into a database (SQL queries can be completely customized).   
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
    
## startMtaBarefoot.sh

