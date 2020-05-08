#!/usr/bin/env bash

dt=$(date '+%d/%m/%Y %H:%M:%S')

# Git as source?
if [ -z "$GIT_REPO" ]; then
	#data is in import volume
    echo "[ERROR] $dt git repo not given. Stop here."
else
	cd "$VIRTUOSO_IMPORT_DIR"
	lines=`git pull | wc -l`
	lines=$(($lines + 1))
	
	if [ $lines -lt 3 ]; then
	    echo "[ERROR] $dt No new commits on repo. Abort."
	    exit 1
	fi
	
    echo "[INFO] $dt git repo now up to date. Continue with import."
    /virtuoso/import.sh
fi
