#!/usr/bin/env bash

set -e

name_for_container() {
  sudo docker ps | awk "/$1/  { print \$NF }"
}

POSTGRES_CONTAINER="$(name_for_container postgres)"
MONGO_CONTAINER="$(name_for_container mongo)"

# Backup postgresql databases
sudo docker exec -u postgres "$POSTGRES_CONTAINER" \
  pg_dump -Fc resource_adaptor_production \
  > resource_adaptor.sql

# Backup postgresql databases
sudo docker exec -u postgres "$POSTGRES_CONTAINER" \
  pg_dump -Fc resource_cataloguer_production \
  > resource_cataloguer.sql

# backup mongodb 
sudo docker exec "$MONGO_CONTAINER" mongodump --gzip --archive=/srv/mongo_backup
sudo docker cp "$MONGO_CONTAINER":/srv/mongo_backup mongo.bson.gz
sudo docker exec "$MONGO_CONTAINER" rm /srv/mongo_backup

# Create defacto backup file
TIMESTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
BACKUPARCHIVE="$HOME/backup_$TIMESTAMP.tar.gz"
BACKUPFILES="resource_adaptor.sql resource_cataloguer.sql mongodb.bson.gz"

tar czf "$BACKUPARCHIVE" $BACKUPFILES

# Remove intermediary files
rm $BACKUPFILES

# Upload the file using gdrive or rclone
