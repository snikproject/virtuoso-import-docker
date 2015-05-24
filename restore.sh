#!/bin/sh

echo "PASSWORD=$VIRTUOSO_ENV_PWDDBA" >> /etc/odbc.ini

if [ -z "$GIT_REPO" ]; then
	:
	#data is in import volume
else

	#git clone to import volume
	git clone $GIT_REPO $IMPORT_VOLUME

fi


