#!/usr/bin/env bash

# Git as source?
if [ -z "$GIT_REPO" ]; then
	:
	#data is in import volume
    echo "[ERROR] git repo not given. Stop here."
else
	#clean the import folder
	rm -r $VIRTUOSO_IMPORT_DIR/*
	rm -r $VIRTUOSO_IMPORT_DIR/.git
	#git clone to import volume
	git clone $GIT_REPO $VIRTUOSO_IMPORT_DIR
    echo "[INFO] git repo cloned. Continue with import."
	ls -hal $VIRTUOSO_IMPORT_DIR
    /virtuoso/import.sh
fi
