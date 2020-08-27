#!/usr/bin/env bash

echo "CRON_JOB=$CRON_JOB"
if [ $CRON_JOB = "dump" ]; then
    /virtuoso/git_dump.sh
else
    /virtuoso/git_import.sh
fi
