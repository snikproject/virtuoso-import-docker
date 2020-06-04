#!/usr/bin/env bash

echo "CRON_JOB=$CRON_JOB"
if [ $CRON_JOB = "update" ]; then
    /virtuoso/git_update.sh
else
    /virtuoso/git_import.sh
fi
