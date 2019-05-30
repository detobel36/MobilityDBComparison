# MTA_Comparison
The goal of these files are to set up automatic tests with MTA data. But finally, most of the tests were done by hand.

## General architecture
The file `main.py` allows you to choose a solution to test and launch the tests. Each folder contains
file configuration and some code to process tests. Obviously the test consist of send GTFS data (from MTA) 
to a system.

You can test:
- Barefoot
- Pipelinedb
- Postgresql
- TimescaleDB (just table structure, no Python code)


# Files descriptions

## [Barefoot](./Barefoot)
This folder contains the python script used to process fetch data and send it to Barefoot (with socket)

## [common](./common)
This folder contains all logical/useful code which will be used by other component. It is in this folder
that request is made.

## [Pipelinedb](./Pipelinedb)
This folder contains the python script used to process fetch data and send it to Pipelinedb (SQL Query)

## [Postgresql](./Postgresql)
This folder contains the python script used to process fetch data and send it to Postgresql (SQL Query)

## [TimescaleDB](./TimescaleDB)
This folder contains only the SQL structure to test TimescaleDB

## [customSend.py](./customSend.py)
This file allow to directly send "fake" MTA Data to Barefoot. This is useful to test a solution with
a small number of constent data.

## [main.py](./main.py)
File used to launch other. Execute:
```BASH
python3 main.py
```

