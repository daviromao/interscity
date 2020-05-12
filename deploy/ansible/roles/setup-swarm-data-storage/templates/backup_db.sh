#!/usr/bin/env bash

set -eaux

name_for_container() {
  docker ps | awk "/$1/  { print \$NF }"
}

(
  POSTGRES_CONTAINER="$(name_for_container postgres)"
  MONGO_CONTAINER="$(name_for_container mongo)"

  # Backup postgresql databases
  docker exec -u postgres "$POSTGRES_CONTAINER" \
    pg_dump -Fc resource_adaptor_production \
    > resource_adaptor.sql

  # Backup postgresql databases
  docker exec -u postgres "$POSTGRES_CONTAINER" \
    pg_dump -Fc resource_cataloguer_production \
    > resource_cataloguer.sql

  # backup mongodb 
  docker exec "$MONGO_CONTAINER" mongodump --gzip --archive=/srv/mongo_backup
  docker cp "$MONGO_CONTAINER":/srv/mongo_backup mongodb.bson.gz
  docker exec "$MONGO_CONTAINER" rm /srv/mongo_backup

  # Create defacto backup file
  TIMESTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
  BACKUPARCHIVE="/srv/backup_$TIMESTAMP.tar.gz"
  BACKUPFILES="resource_adaptor.sql resource_cataloguer.sql mongodb.bson.gz"

  tar czf "$BACKUPARCHIVE" $BACKUPFILES

  # Remove intermediary files
  rm $BACKUPFILES

  # Upload the file using gdrive or rclone
  # I don't like those parent dirs, but I don't see a better way now
  /srv/gdrive --service-account ../../../../srv/service-account.json upload "$BACKUPARCHIVE"

  rm "$BACKUPARCHIVE"
) >> /srv/cron_log.txt 2>&1
