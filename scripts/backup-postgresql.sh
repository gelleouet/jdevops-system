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
PG_DUMP="/usr/bin/pg_dump"
DATE_JOUR=`date +%Y-%m-%d`
PGCONNECT_TIMEOUT=10
DBFILE="/tmp/${DBNAME}_$DATE_JOUR.backup"

# Dump de la base
$PG_DUMP -U postgres -h localhost --format=c --file=$DBFILE $DBNAME

# Envoi du backup vers AWS S3
/root/.local/bin/aws s3 mv $DBFILE s3://bemyhomesmart/backup/

