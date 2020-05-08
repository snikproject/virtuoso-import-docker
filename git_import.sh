#!/usr/bin/env bash

# Git as source?
if [ -z "$GIT_REPO" ]; then
	:
	#data is in import volume
    echo "[ERROR] git repo not given. Stop here."
else
	#clean the import folder
	rm -r $VIRTUOSO_IMPORT_DIR/*
	#git clone to import volume
	git clone $GIT_REPO $VIRTUOSO_IMPORT_DIR
    echo "[INFO] git repo cloned. Continue with import."
    /virtuoso/import.sh
fi
