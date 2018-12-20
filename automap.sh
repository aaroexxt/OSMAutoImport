#!/bin/bash




#USAGE: sudo bash /path/to/automap.sh /path/to/temporary/data/directory /path/to/pbf/file.pbf
abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred :( Exiting..." >&2
    exit 1;
}

if [[ $(id -u) -ne 0 ]]
  then echo "Sorry, but it appears that you didn't run this script as root. Please run it as a root user!";
  exit 1;
fi

#auto script for this awesome tutorial at https://tilemill-project.github.io/tilemill/docs/guides/osm-bright-mac-quickstart/

echo "Aaron's OSM Downloader utility, will download and configure a new OSM Bright template for use with TileMill";
echo "---------------------------------------"

echo "do you want to make the install directory $1 and use the .osm.pbf file provided at $2. if not press ctrl+z now";
read
#check validity of files
if [ ! -d "$1" ]; then
	echo "Directory specified is invalid";
	abort
fi

if [ ! -e "$2" ]; then
	echo "File specified is invalid";
	abort
fi

echo "creating folders"
cd $1;
sudo mkdir brightConfig
cd brightConfig

#stop all servers
#echo "Killing postgres processes...";

#HOW TO KILL POSTGRES
#sudo kill -kill $(sudo lsof -t -i:5432)

#HOW TO CREATE OSM DATABASE:
:'
create database osm;
\connect osm;
create extension postgis;
create role root;
alter role root with login;
grant all privileges on database osm to root;
quit;
'


echo "creating pgsql database from file at $2"
echo "IF THIS FAILS, GO TO https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e"
sudo osm2pgsql --number-processes 4 -C 10240 -cGs -d osm -S /usr/local/share/osm2pgsql/default.style $2 || exit 1
#using options: cache at 10gb, create new database, using multigeometry, slim mode, default stylesheet, use 4 processes
echo "downloading osm bright";
sudo curl -o osm-bright.zip -L https://github.com/mapbox/osm-bright/zipball/master
echo "extracting"
sudo unzip osm-bright.zip -d $1/brightConfig
#ok we now have osm bright
#download essential shapefiles
cd $1/brightConfig/mapbox-osm-bright-*
sudo mkdir shp
cd shp
sudo wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
sudo unzip simplified-land-polygons-complete-3857.zip -A -d $(pwd)
sudo wget http://data.openstreetmapdata.com/land-polygons-split-3857.zip
sudo unzip land-polygons-split-3857.zip -A -d $(pwd)
sudo mkdir ne_10m_populated_places;
cd ne_10m_populated_places;
sudo wget http://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_populated_places.shp
cd ..
cd ..
#copy config
sudo cp configure.py.sample configure.py
clear
echo "When you press enter, you will be modifying the configuration file for the postgis connection. Please enter it and then press ctrl+c and y and then enter";
read
sudo nano configure.py
echo "adding to mapbox projects"
sudo ./make.py #make and add

echo "setup done";
exit 0; #exit




sudo mkdir $1/brightConfig/statePBF

#old shit that I didn't need; downloads each state individually
cd $1/brightConfig/statePBF
echo "downloading to $dir"


echo "setting up url array...";

dir=$1;
baseurlUSA="https://download.geofabrik.de/north-america/us/"
baseurl="https://download.geofabrik.de/north-america/"
extension="-latest.osm.pbf"

states=("canada" "greenland" "mexico")
statesUSA=("alabama" "alaska" "arizona" "arkansas" "california" "colorado" "connecticut" "delaware" "district-of-columbia" "florida" "georgia" "hawaii" "idaho" "illinois" "indiana" "iowa" "kansas" "kentucky" "louisiana" "maine" "maryland" "massachusetts" "michigan" "minnesota" "mississippi" "missouri" "montana" "nebraska" "nevada" "new-hampshire" "new-jersey" "new-mexico" "new-york" "north-carolina" "north-dakota" "ohio" "oklahoma" "oregon" "pennsylvania" "puerto-rico" "rhode-island" "south-carolina" "south-dakota" "tennessee" "texas" "utah" "vermont" "virginia" "washington" "west-virginia" "wisconsin" "wyoming")


for u in ${states[@]}; do
	echo "creating folder for $u"
	sudo mkdir $u
	echo "downloading: $u"
	dl="$baseurl$u$extension"
	cd $u
	sudo curl -o "$u.osm.pbf" -L $dl
	echo "running osm2pgsql on downloaded file"
	osm2pgsql -cGs -d osm -S /usr/local/share/osm2pgsql/default.style "$u.osm.pbf"
	cd ..
done



