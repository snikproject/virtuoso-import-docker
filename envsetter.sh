#!/usr/bin/env bash

if [ -n "$CRON_TIMES" ]; then
  sed -i "s/1,6,11,16,21,26,31,36,41,46,51,56 \* \* \* \*/$CRON_TIMES/" /etc/cron.d/cronfile
  crontab /etc/cron.d/cronfile # install new crontab
fi

printenv >> /etc/environment
cron -f
# execute right away
echo "Importing for the first time"
/virtuoso/cronscript.sh
