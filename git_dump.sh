#!/usr/bin/env bash

set -o nounset

${DLD_DEV:=}
[[ ! -z "$DLD_DEV" ]] && set -x #conditional debug output

dt=$(date '+%d/%m/%Y %H:%M:%S')

export_dir="${VIRTUOSO_DATA_DIR}"

# Setup of git
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"

cd $export_dir

# Check if already a repository
git status
status=$?

# Initialize the repository
if [ $status -ne 0 ]; then
    echo "[INFO] Repository is not a git directory."

    if [ -n "$(ls -A $export_dir)" ]; then
        echo "[ERROR] Target directory is not empty. Can't clone or initialize."
        exit 102
    fi

    # Git as target?
    if [ -z "$GIT_REPO" ]; then
        #data is in import volume
        echo "[INFO] $dt git repo URL not given. Initialize a new repo."
        git init $export_dir
    else
        echo "[INFO] $dt clone the repo from the remote location."
        git clone $GIT_REPO $export_dir
    fi
else
    echo "[INFO] Pull changes for the repository ..."
    git pull
fi

echo "[INFO] git repo now up to date. Dump new data."

/virtuoso/dump.sh

# Check if files changed
git status --porcelain | grep '^.[MTD] '
change_status=$?
# change_status is 0 if changes are detected and not 0 if no changes were detected

if [ $change_status -ne 0 ]; then
    echo "[INFO] Repository needs no update. Abort."
    exit 0
fi

echo "[INFO] Create new commit."
git commit -am "Automatic commit message from virtuoso-import-docker: Update of repository at $dt"

# Write current commit id to our local file to avoid reimporting it
git rev-parse HEAD > .virtuoso-import-last-commit

if [ -z $NO_PUSH ]; then
    git push
    push_status=$?

    if [ $push_status -ne 0 ]; then
        echo "[INFO] Could not push, but the data is commited within the container."
    fi
fi

echo "[INFO] Exit."
