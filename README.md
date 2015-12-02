# Directory backup to S3
Backups a directory to S3 after gzipping it.

Image runs as a cron job by default evey minute. Period may be changed
by tuning `BACKUP_CRON_SCHEDULE` environment variable.

May also be run as a one time backup job by using `backup.sh` script as command.

Following environemnt variables should be set for backup to work:
```
BACKUP_S3_BUCKET=
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

Following environment variables can be set to change the functionality:
```
BACKUP_CRON_SCHEDULE="* * * * *"
BACKUP_TGT_DIR=/backup/
BACKUP_SRC_DIR=/data/
BACKUP_FILE_NAME='$(date +%Y-%m-%d)/$(date +%Y-%m-%d-%H-%M-%S)'
```
## Usage
Mount the dir you want to be backed up on `BACKUP_TGT_DIR` and run image as 
daemon for periodic backup:
```
$ docker run -d -e BACKUP_S3_BUCKET=bucket/directory/ -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -v /dir/on/host/:/backup/ mohamnag/s3-dir-backup
```

or for one time backup:
```
$ docker run --rm -e BACKUP_S3_BUCKET=bucket/directory/ -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=aws
key -v /dir/on/host/:/backup/ mohamnag/s3-dir-backup backup.sh
```

## TODO
Implement restore functionality. 
