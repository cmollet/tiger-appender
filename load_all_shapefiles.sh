#!/bin/bash
# usage: ./shaper.sh *.shp

# numeric EPSG code of the shapefile
EPSG=
# Name of the PostGIS database
DB=

for SHP in $*
do
  shp2pgsql -s $EPSG -g the_geom -I $SHP > $SHP.sql
  if (( $? ))
  then
    shp2pgsql -s $EPSG -g the_geom -W LATIN1 -I $SHP > $SHP.sql
  fi
  psql -d $DB -f $SHP.sql -q
done
