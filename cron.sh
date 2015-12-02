#!/bin/bash

# save env variables
set | grep "BACKUP_" > /root/env
set | grep "AWS_" >> /root/env 

# change cron schedule
sed -i "s,CRON_SCHEDULE*,${BACKUP_CRON_SCHEDULE},g" /etc/cron.d/backup-cron

# run cron and observe logs
cron && tail -f /var/log/cron.log
