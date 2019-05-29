# Processing a spatio-temporal data stream with PostgreSQL
This repository contain all code used to reply to this problem.

## General informations
Different tests (and so solution) have been set up during this work. 
Here is the different program that have been considered:
- PostgreSQL
- MobilityDB (extension PostgreSQL)
- TimescaleDB (extension PostgreSQL)
- PipelineDB (extension PostgreSQL)
- Barefoot

Three different server have been used:
- Geodata: ULB server in production to fetch and process data
- Tristan23: ULB server to set up solution (before to push it on Geodata)
- Detobel: Own server used to install web view


### Data source
The main source of data come from MTA (New York). But in general, all solution follow GTFS format.


# Differents programs/solutions in different folder
Each folder contain a README (if necessary) to explain more information about this program

## MTABarefoot
This program uses Barefoot as a library to create a system to get MTA data (in several different ways), process these data and store them into a database (SQL queries can be completely customized).   
Available here: https://github.com/detobel36/MTABarefoot


## Tools
The folder "Tools" contains files used in "production" to treat MTA data with a custom Barefoot version.


## Website
Contains all files used to display PostgreSQL content on web.


## MTA_Comparison
Multiple files to setup database and fetch data to make the comparison. Finally, it is not this code that was used to make the comparisons (many operations by hand) but 
it still contains the generation code.    
This code use another repository: https://github.com/detobel36/gtfs_SQL_importer


## barefoot.sh
Script to set up and launch barefoot


## readAndStore
Litle Java program to read GTFS backup file and execute SQL query


