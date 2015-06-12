#!/bin/bash

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}
cmd="${bin} ${host}:${port} ${user} ${password}"

if [ $1 == "" ]
then
    exit 1
fi

t=$1

res=$( ${cmd} )
while [[ $? != "0" ]] ;
do
    echo -n "."
    sleep 1
    echo $t
    let "t=$t-1"
    if [ $t == "0" ]
    then
        echo "timeout"
        exit 1
    fi
    res=$( ${cmd} )
done

echo "done"
