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
	echo "[INFO] Update repository ..."
	git pull
fi

echo "[INFO] git repo cloned. Continue with import."
ls -hal $VIRTUOSO_DATA_DIR

/virtuoso/import.sh
