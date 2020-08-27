#!/usr/bin/env bash

# Git as source?
if [ -z "$GIT_REPO" ]; then
    :
    #data is in import volume
    echo "[ERROR] git repo not given. Stop here."
    exit 101
fi

cd $VIRTUOSO_DATA_DIR

# Check if already a repository
git status
status=$?

if [ $status -ne 0 ]; then
    echo "[INFO] Repository is not a git directory. Clone now."
    if [ -n "$(ls -A $VIRTUOSO_DATA_DIR)" ]; then
        echo "[ERROR] Target directory is not empty. Can't clone."
        exit 102
    fi
    git clone $GIT_REPO $VIRTUOSO_DATA_DIR
else
    echo "[INFO] Update repository (git pull) ..."
    git pull

    # if not initial commit
    # check if .virtuoso-import-last-commit exitst
    # if it exists check if .virtuoso-import-last-commit == current HEAD
    # if yes abort
    if [ $lines -lt 3 ]; then
        echo "[INFO] $dt No new commits on repo. Abort."
        exit 0
    fi

    # if not initial commit compare what has changed and only import changes

    # if inition commit import anyways
fi

echo "[INFO] git repo cloned/pulled. Continue with import."
ls -hal $VIRTUOSO_DATA_DIR

/virtuoso/import.sh

# Write the last commit ID into our hidden file
git rev-parse HEAD > .virtuoso-import-last-commit
