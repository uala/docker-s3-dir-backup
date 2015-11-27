FROM mohamnag/aws-cli

# change these to fit your need
ENV BACKUP_DIR=/backup/
ENV DATA_DIR=/data/
# m h  dom mon dow
ENV CRON_SCHEDULE="* * * * *"

ADD crontab /etc/cron.d/backup-cron
ADD backup.sh /opt/backup.sh
ADD restore.sh /opt/restore.sh
ADD cron.sh /opt/cron.sh

RUN chmod 0644 /etc/cron.d/backup-cron
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
RUN chmod +x /opt/*.sh

VOLUME $BACKUP_DIR
VOLUME $DATA_DIR

WORKDIR /opt/

CMD cron.sh
