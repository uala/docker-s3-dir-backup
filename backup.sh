#!/bin/bash

echo "creating archive..."

# this has to be executed like this, because we have two level expansion in variables
eval "export BACKUP_DST_FULL_PATH=${BACKUP_TGT_DIR}${BACKUP_FILE_NAME}.tar.gz"

BACKUP_DST_DIR=$(dirname "${BACKUP_DST_FULL_PATH}")

mkdir -p ${BACKUP_DST_DIR}
echo "Gzipping ${BACKUP_SRC_DIR} into ${BACKUP_DST_FULL_PATH}" 

tar -czf ${BACKUP_DST_FULL_PATH} -C ${BACKUP_SRC_DIR} .

echo "archive created, uploading..."
/usr/bin/aws s3 sync ${BACKUP_TGT_DIR} s3://${BACKUP_S3_BUCKET}

echo "backup finished"
