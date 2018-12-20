# OSMAutoImport
By Aaron Becker

# Usage
General usage:
	sudo bash /path/to/automap.sh /path/to/temporary/data/directory /path/to/pbf/file.pbf

## Setting up a PostgreSQL Database
How to set up a postgres database:
Enter the following commands (after postgres is installed on your system)
	psql
	create database osm;
	\connect osm;
	create extension postgis;
	create role root;
	alter role root with login;
	grant all privileges on database osm to root;
	quit;
and you are ready to run the script. On Mac OSX, I use Postgres.app, but any postgres installation should work just fine

### Requirements

Requires osm2pgsql, a postgres database named "osm", and bash, as well as wget and unzip (and nano)