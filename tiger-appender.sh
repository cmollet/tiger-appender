#!/usr/bin/zsh
# pgshpend: a script to create a single PostGIS table from
# multiple shapefiles that all have the same structure.
# Typical use includes creating nationwide datasets from 
# Census TIGER/Line shapefiles
#
# TODO: Drop and re-create unique ID field

dflag=
fflag=
tflag=
nflag=
sflag=
aflag=

while getopts "d:t:ns:f:a" OPTION
do
    case $OPTION in
        d) dflag=1
            dflag="$OPTARG"
            ;;
        t) tflag=1
            tflag="$OPTARG"
            ;;
        n) nflag=1
            nflag="$OPTARG"
            ;;
        s) sflag=1
            sflag="$OPTARG"
            ;;
        f) fflag=1
            fflag="$OPTARG"
            ;;
        a) aflag=1
            aflag="$OPTARG"
            ;;
        ?) printf "Usage: %s [-d database] [-t table] [-n schema] [-s SRID] [-a convert to SRID] [-f shapefile]\n" $(basename $0) >&2
            exit 2
            ;;
    esac
done
shift $(($OPTIND - 1))


if [ "$dflag" -a "$tflag" -a "$sflag" ]  
then
    shp2pgsql -D -d -s $sflag -g the_geom -I -W LATIN1 $fflag | psql -d $dflag
    psql -d $dflag -c "DROP TABLE IF EXISTS $tflag;"
    psql -d $dflag -c "SELECT * INTO ${tflag} FROM ${fflag/.shp/};"
    psql -d $dflag -c "DELETE FROM $tflag;"
    for i in *.shp;
    do;
        shp2pgsql -D -s $sflag -g the_geom -W LATIN1 -a $i $tflag | psql -d $dflag
    done;
    psql -d $dflag -c "CREATE INDEX $tflag_geom_gist ON $tflag USING GIST(the_geom);"
    psql -d $dflag -c "DROP TABLE ${fflag/.shp/};"
fi
