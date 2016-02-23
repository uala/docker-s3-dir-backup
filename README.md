# Directory backup to S3
Backups a directory to S3 after gzipping it.

Image runs as a cron job by default evey minute. Period may be changed by tuning `BACKUP_CRON_SCHEDULE` environment variable.

May also be run as a one time backup job by using `backup.sh` script as command.

Following environemnt variables should be set for backup to work:
```
BACKUP_S3_BUCKET=		// no trailing slash at the end!
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

Following variables may be set for restore functionality (independently):
```
RESTORE_RESUME_BACKUP=1
RESTORE_FILE_PATH=
```

Flowing environment variables can be set to change the functionality:
```
BACKUP_CRON_SCHEDULE="* * * * *"
BACKUP_TGT_DIR=/backup/		// always with trailing slash at the end!
BACKUP_SRC_DIR=/data/		// always with trailing slash at the end!
BACKUP_FILE_NAME='$(date +%Y-%m-%d)/$(date +%Y-%m-%d-%H-%M-%S)'
```
## Usage
### Backup
If you want to keep the archive files created, mount a volume on `BACKUP_TGT_DIR`.

If you want to store files on S3 under a subdirectory, just add it to the `BACKUP_S3_BUCKET` like `BACKUP_S3_BUCKET=bucket_name/subdirectory_for_storage`. You can also add it to `BACKUP_FILE_NAME` but if you want to use the auto restore feature, it will be more efficient to add it to `BACKUP_S3_BUCKET`. However `BACKUP_FILE_NAME` can have dynamic parts like date and time inside.

Mount the dir you want to be backed up on `BACKUP_SRC_DIR` and run image as daemon for periodic backup:
```
$ docker run -d -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -v /dir/to/be/backedup/:/data/ mohamnag/s3-dir-backup
```

or for one time backup (using default values and not keeping the backup archive):
```
$ docker run --rm -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -v /dir/to/be/backedup/:/data/ mohamnag/s3-dir-backup /opt/backup.sh
```

### Restore
Restoring a backup from S3 bucket can be done in following ways:
- auto restore latest backup on start before starting backup crone job
- restore latest backup and exit
- restore an specific backup and exit

> Latest backup is considered the newest file inside `BACKUP_S3_BUCKET` and its subdirectories with a `*.gz` extension.

To run any of the restore tasks, proper environment variables shall be set and `/opt/restore.sh` shall be run as command. 

Restore an specific backup and exit:
```
$ docker run --rm -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -e RESTORE_FILE_PATH=2016-02-23/2016-02-23-12-00-01.tar.gz -v /dir/to/be/restored/:/data/ mohamnag/s3-dir-backup /opt/restore.sh
```

Restore latest backup and exit:
```
$ docker run --rm -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -v /dir/to/be/restored/:/data/ mohamnag/s3-dir-backup /opt/restore.sh
```

Restoring an specific backup and start scheduled backup:
```
$ docker run -d -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -e RESTORE_FILE_PATH=2016-02-23/2016-02-23-12-00-01.tar.gz -e RESTORE_RESUME_BACKUP=1 -v /dir/to/be/restored/:/data/ mohamnag/s3-dir-backup /opt/restore.sh
```

Restoring latest and starting scheduled backup:
```
$ docker run -d -e BACKUP_S3_BUCKET=bucket/directory -e AWS_DEFAULT_REGION=aws-region -e AWS_ACCESS_KEY_ID=awsid -e AWS_SECRET_ACCESS_KEY=awskey -e RESTORE_RESUME_BACKUP=1 -v /dir/to/be/restored/:/data/ mohamnag/s3-dir-backup /opt/restore.sh
```


### Auto restore
This functionality will find the latest backup and restore it on `BACKUP_SRC_DIR`. It will then start the backup cron job. This is mainly intended for environments where the backed up directory may move between machines.

Imagine you are backing up the data directory of a docker container running a database. If an automatic process (like ECS scheduler) stops the database container and starts is on a new machine, you dont want to have an empty database. In this case this image will restore the last backed up status of database and will also backu it up in future when new changes have happened.

### Restore latest backup
Works exactly like auto restore but container will stop after restoring and there will be no future backups.

### Restore an specific backup
If you know the file path of backup (relative to `BACKUP_S3_BUCKET`) you can use this functionality to restore that specific status. Container will stop after restoring and there will be no future backups.

