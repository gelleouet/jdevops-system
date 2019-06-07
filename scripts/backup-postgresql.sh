#!/bin/bash

# Script pour faire des dump d'une base
#
# $1 dbname : nom de la base
#

# gestion des parametres
DBNAME="$1"

if [ -z "$DBNAME" ]
then
	echo "Usage : $0 dbname"
	exit 1
fi

# configuration
PATH_DUMP="/tmp"
PG_DUMP="/usr/bin/pg_dump"
DATE_JOUR=`date +%Y-%m-%d`
PGCONNECT_TIMEOUT=10


# Dump de la base
$PG_DUMP -U postgres -h localhost --format=c --file=$PATH_DUMP/${DBNAME}_$DATE_JOUR.backup $DBNAME

