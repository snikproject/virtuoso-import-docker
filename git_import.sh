#!/usr/bin/env bash

# Git as source?
if [ -z "$GIT_REPO" ]; then
	:
	#data is in import volume
    echo "[ERROR] git repo not given. Stop here."
else
	#clean the import folder
	rm -r $GIT_DIRECTORY/*
	rm -r $GIT_DIRECTORY/.git
	#git clone to import volume
	git clone $GIT_REPO $GIT_DIRECTORY
    echo "[INFO] git repo cloned. Continue with import."
	ls -hal $GIT_DIRECTORY
	
	rm -rf $VIRTUOSO_DATA_DIR/*
	cp $GIT_DIRECTORY/* $VIRTUOSO_DATA_DIR/
	
    /virtuoso/import.sh
fi
