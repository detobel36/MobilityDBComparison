# Processing a spatio-temporal data stream with PostgreSQL
This repository contain all code used to reply to this problem.

# Table of contents

- [General informations](#general-informations)
    - [Data source](#data-source)
- [Differents programs/solutions in different folder](#differents-programssolutions-in-different-folder)
    - [MTA_Comparison](#mta_comparison)
    - [Report](#Report)
    - [Tool](#tool)
    - [Website](#website)
    - [readAndStore](#readandstore)
    - [barefoot.sh](#barefootsh)



## General informations
Different tests (and so solution) have been set up during this work. 
Here is the different program that have been considered:
- [PostgreSQL](https://www.postgresql.org/)
- [MobilityDB](https://github.com/ULB-CoDE-WIT/MobilityDB) (extension PostgreSQL)
- [TimescaleDB](https://timescale.com) (extension PostgreSQL)
- [PipelineDB](https://pipelinedb.com) (extension PostgreSQL)
- [Barefoot](https://github.com/bmwcarit/barefoot)

Three different server have been used:
- Geodata: ULB server in production to fetch and process data
- Tristan23: ULB server to set up solution (before to push it on Geodata)
- Detobel: Own server used to install web view


### Data source
The main source of data come from [MTA](http://web.mta.info/developers/) (New York). But in general, all solution follow GTFS format.


## Differents programs/solutions in different folder
Each folder contain a README (if necessary) to explain more information about this program

### [MTA_Comparison](./MTA_Comparison)
Multiple files to setup database and fetch data to make the comparison. Finally, it is not this 
code that was used to make the comparisons (many operations by hand) but it still contains the 
generation code.    
This code use another repository: https://github.com/detobel36/gtfs_SQL_importer

### [Report](./Report)
Contains report to explain how to use these files.

### [Tool](./Tool)
The folder "Tool" contains files used in "production" to treat MTA data with a custom Barefoot version.

### [Website](./Website)
Contains all files used to display PostgreSQL content on web.

### [readAndStore](./readAndStore)
Litle Java program to read GTFS backup file and execute SQL query

### [barefoot.sh](./barefoot.sh)
Script to set up and launch barefoot

