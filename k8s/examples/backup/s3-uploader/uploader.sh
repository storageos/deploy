#!/bin/bash

DATA_LOC="${1:-$BACKUP_PATH}"
BUCKET="${2:-$BACKUP_BUCKET}"
REGION="$3"

upload() {
    timestamp=$(date "+%Y%m%d-%H%M")
    aws s3 cp --region "$REGION" --recursive $DATA_LOC/ s3://$BUCKET/$timestamp/
}

check_bucket_exists() {
    if [ $(aws s3 ls | grep -c "$BUCKET") -le 0 ]; then
        echo "Bucket $BUCKET can't be found among the following list"
        aws s3 ls
        exit 1
    fi
}

get_bucket_region() {
    reg=$(aws s3api get-bucket-location --bucket $BUCKET --output text)
    echo "$reg"
}

## Checks
if [ -z "$DATA_LOC" ]; then
    echo "Path to specify the backup location not set"
    exit 1
fi

if [ -z "$BUCKET" ]; then
    echo "Bucket to save the backup not set"
    exit 1
fi

check_bucket_exists

if [ -z "$REGION" ]; then
    REGION="$(get_bucket_region)"
fi


## Upload data to S3
echo "Uploading data to s3://$BUCKET/$timestamp"
upload
echo "Finished uploading data"
