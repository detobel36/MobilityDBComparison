# Webiste
This folder contains files to set up web server (to display database content).

## Config
You need to update the file `controller/useful.php` to adapt with your own settings (Google API, Webiste URL, ...)

## Structure
Globally, files follow an MVC structure.

## Requirement
A web server on PHP 7.0 (or upper). This system was test on an Apache2 configuration with PHP 7.0


# Files descriptions

## [assets](./assets)
This folder contains "ressource" files like Javascript code, CSS and Images.

## [controllers](./controllers)
Contains files that make "logical" part of website. These files use files contained in "model" folder 
to fetch data and use files in "view" to display result.    
Notice that sometime controller directly display informations (without using "view" folder)

## [model](./model)
This folder contains files linked to database. In other words, these files control data.

## [test](./test)
This folder contains test code linked to "Leaflet".

## [views](./views)
Contains HTML files which will be displayed.
