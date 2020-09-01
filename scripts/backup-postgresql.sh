#!/bin/bash

# Script pour faire des dump d'une base
#
# $1 dbname : nom de la base
#

# gestion des parametres
DBNAME="$1"
BACKUPFILE="$2"

if [ -z "$DBNAME" -o -z "$BACKUPFILE" ];
then
	echo "Usage : $0 dbname backupfile"
	exit 1
fi

# configuration
PG_DUMP="/usr/bin/pg_dump"
DATE_JOUR=`date +%Y-%m-%d`
PGCONNECT_TIMEOUT=10
DBFILE="/tmp/${BACKUPFILE}_$DATE_JOUR.backup"

# Dump de la base
$PG_DUMP -U postgres -v --format=c --file=$DBFILE $DBNAME

if [ ! "$?" = "0" ];
then
	echo "pg_dump error !"
	exit 1
fi

# Envoi du backup vers AWS S3
if [ -e "$DBFILE" ];
then
	/root/.local/bin/aws s3 mv $DBFILE s3://bemyhomesmart/backup/
else
	echo "Backup $DBFILE not exist !"
	exit 1
fi

exit 0

