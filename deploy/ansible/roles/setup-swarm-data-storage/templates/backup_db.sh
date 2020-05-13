#!/usr/bin/env bash

set -eaux

name_for_container() {
  docker ps | awk "/$1/  { print \$NF }"
}

gdrive() {
  /srv/gdrive --service-account ../../../../srv/service-account.json "$@"
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
  gdrive upload --delete "$BACKUPARCHIVE"


  gdrive list > .tmp-list.txt

  if (( "$(grep backup .tmp-list.txt -c)" > 2 )); then
    THIRD_OLDEST_BACKUP_ID=$(awk '/backup/ { if(NR == 3) { print $1 } }' .tmp-list.txt)
    gdrive delete "$THIRD_OLDEST_BACKUP_ID"
  fi

) >> /srv/cron_log.txt 2>&1
