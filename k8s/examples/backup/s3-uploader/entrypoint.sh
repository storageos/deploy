#!/bin/bash

BIN_LOC=/opt
DATA_LOCATION=/tmp/$(date "+%Y%m%d-%H%M")
DATA_ENDPOINT_SVC="${1:-$RSYNC_SVC_NAME}"

$BIN_LOC/syncher.sh "$DATA_LOCATION" "$DATA_ENDPOINT_SVC"
if [ $? -ne 0 ]; then
    echo "Can't continue because the synch of the backup FAILED"
    exit 1
fi

$BIN_LOC/uploader.sh "$DATA_LOCATION"
if [ $? -ne 0 ]; then
    echo "Can't continue because the upload of the backup FAILED"
    exit 1
fi
