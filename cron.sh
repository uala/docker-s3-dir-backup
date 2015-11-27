sed -i "s,CRON_SCHEDULE*,${CRON_SCHEDULE},g" /etc/cron.d/backup-cron
cron && tail -f /var/log/cron.log
