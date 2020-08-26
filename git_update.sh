#!/usr/bin/env bash

dt=$(date '+%d/%m/%Y %H:%M:%S')

# Git as source?
if [ -z "$GIT_REPO" ]; then
    #data is in import volume
    echo "[ERROR] $dt git repo URL not given. Stop here."
else
    cd "$GIT_DIRECTORY"

    lines=`ls -hal | grep "\.git" | wc -l`
    lines=$(($lines + 1))

    if [ $lines -lt 2 ]; then
        echo "[INFO] Directory was not intialized with git. Deleting its content in the process."
        /virtuoso/git_write.sh
    else
        echo "[INFO] Repository update ..."

        lines=`git pull | wc -l`
        lines=$(($lines + 1))

        if [ $lines -lt 3 ]; then
            echo "[ERROR] $dt No new commits on repo. Abort."
            exit 1
        fi

        echo "[INFO] $dt git repo now up to date. Continue with update of virtuoso."
        /virtuoso/git_write.sh
    fi
fi
