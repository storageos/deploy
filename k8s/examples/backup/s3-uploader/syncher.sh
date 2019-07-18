#!/bin/bash

DATA_LOC="${1:-$BACKUP_PATH}"
SVC="${2:-$RSYNC_SVC_NAME}"

rsync_creds_file="${RSYNC_CREDS_FILE:-/etc/rsyncd.secrets}"
pass_file="/opt/password-rsync.txt"

username="$(cut -d':' -f1 $rsync_creds_file)"
password="$(cut -d':' -f2 $rsync_creds_file)"

echo "$password" >> ./$pass_file
chmod 400 ./$pass_file

synch_backup_files() {
    mkdir -p $DATA_LOC
    rsync --exclude "lost+found" --password-file $pass_file -a rsync://$username@$SVC/share $DATA_LOC/
}

if [ -z "$SVC" ]; then
    echo "Service name to connect to Rsync daemon not set"
    exit 1
fi

if [ -z "$DATA_LOC" ]; then
    echo "Path to specify the backup location not set" 1>&2
    exit 1
fi

## Rsync the data from the source
echo "Start syncing data from $SVC/share"
synch_backup_files
echo "Finish syncing data"
