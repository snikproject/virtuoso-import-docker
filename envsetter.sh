#!/usr/bin/env bash

if [ -n $CRON_TIMES ]; then
  sed -i "s/1,6,11,16,21,26,31,36,41,46,51,56 \* \* \* \*/$CRON_TIMES/" /etc/cron.d/cronfile
fi

printenv >> /etc/environment
cron -f
