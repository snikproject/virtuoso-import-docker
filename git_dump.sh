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

# Check if files changed or commits need to be pushed
git status --porcelain | grep '^.[MTD] '
change_status=$((1-$?))

git status --porcelain -b | grep '^## .*ahead'
need_push=$((1-$?))
# grep returns 0 if something was found and 1 otherwise (2 on error)
# so we have to revert the value for change_status and need_push

if [ $change_status -eq 0 ] && [ $need_push -eq 0 ]; then
    echo "[INFO] Repository needs no update. Abort."
    exit 0
fi

if [ $change_status -ne 0 ]; then
    echo "[INFO] Create new commit."
    git commit -am "Automatic commit message from virtuoso-import-docker: Update of repository at $dt"

    # Write current commit id to our local file to avoid reimporting it
    git rev-parse HEAD > .virtuoso-import-last-commit
    need_push=1
fi

# Because we have `set -o nounset` in the beginning of the script we can not reference unset variables.
# So we have to check of $NO_PUSH with a default value, wihc is done with ${var-default}, in this case we leave the default value empty:
# ${NO_PUSH-}
if [ -z "${NO_PUSH-}" ] && [ $need_push -ne 0 ]; then
    git push
    push_status=$?

    if [ $push_status -ne 0 ]; then
        echo "[INFO] Could not push, but the data is commited within the container."
    fi
fi

echo "[INFO] Exit."
