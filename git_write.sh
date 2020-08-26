#!/usr/bin/env bash

set -o nounset

${DLD_DEV:=}
[[ ! -z "$DLD_DEV" ]] && set -x #conditional debug output

dt=$(date '+%d/%m/%Y %H:%M:%S')

# http://docs.openlinksw.com/virtuoso/rdfperfdumpandreloadgraphs/

# Definition of the isql connection to Virtuoso
bin="isql-vt"
host="virtuoso"
port=1111
user="dba"
password=${DBA_PASSWORD}

export_dir="${VIRTUOSO_DATA_DIR}"

# Wrap the execution of isql commands to receive the return code and output
run_virtuoso_cmd () {
    VIRT_OUTPUT=`echo "$1" | "$bin" -H "$host" -S "$port" -U "$user" -P "$password" 2>&1`
    VIRT_RETCODE=$?
    if [[ $VIRT_RETCODE -eq 0 ]]; then
        echo "$VIRT_OUTPUT" | tail -n+5 | perl -pe 's|^SQL> ||g'
        return 0
    else
        echo -e "[ERROR] running the these commands in virtuoso:\n$1\nerror code: $VIRT_RETCODE\noutput:"
        echo "$VIRT_OUTPUT"
        let 'ret = VIRT_RETCODE + 128'
        return $ret
    fi
}

# Check if the virtuoso is up and running
# This is needed during the bootstrapping process in a docker setup
test_connection () {
    if [[ -z $1 ]]; then
        echo "[ERROR] missing argument: retry attempts"
        exit 1
    fi

    t=$1

    run_virtuoso_cmd 'status();'
    while [[ $? -ne 0 ]] ;
    do
        echo -n "."
        sleep 1
        echo $t
        let "t=$t-1"
        if [ $t -eq 0 ]
        then
            echo "timeout"
            return 2
        fi
        run_virtuoso_cmd 'status();'
    done
}

cd "$export_dir"

echo "[INFO] waiting for store to come online"

: ${CONNECTION_ATTEMPTS:=60}
test_connection "${CONNECTION_ATTEMPTS}"
if [ $? -eq 2 ]; then
    echo "[ERROR] store not reachable"
    exit 1
fi

# Give some more seconds to the virtuoso to really accept updates
sleep 3

echo "[INFO] $dt Starting dump process...";
# clean working dir
rm -rf $export_dir/*
mkdir $export_dir/tmp

# First define the procedure
command=`cat ../dump_one_graph.virtuoso>&1`
run_virtuoso_cmd "$command"

# Now use it to dump
run_virtuoso_cmd "dump_one_graph('${GRAPH_URI}', '${export_dir}/data_', 1000000000);"

echo "[INFO] dump done;"


# Sorting of triples
for file in *.ttl*; do
    cat $file | LC_ALL=C sort -u > $export_dir/tmp/$file
done

# Create dir if not existing
if [ -d "$GIT_DIRECTORY" ]; then
  :
else
    ###  Control will jump here if $DIR does NOT exists ###
    mkdir -p $GIT_DIRECTORY
fi

# Setup of git
cd $GIT_DIRECTORY
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"
chmod 600 /root/.ssh/id_rsa

# Check if valid repository - if not clone
lines=`git status | wc -l`
lines=$(($lines + 1))

if [ $lines -lt 3 ]; then
    echo "[INFO] Repository is not a git directory. Clone now"
    rm -rf $GIT_DIRECTORY/*
    rm -rf $GIT_DIRECTORY/.git
    git clone $GIT_REPO $GIT_DIRECTORY
else
    echo "[INFO] Repository update ..."
    git pull
fi

echo "[INFO] git repo now up to date. Copy now files and create a commit."

cp $export_dir/tmp/* $GIT_DIRECTORY/

rm -rf $export_dir/tmp

# Check if files changed
lines=`git status | grep .ttl | wc -l`
lines=$(($lines + 1))
if [ $lines -lt 2 ]; then
    echo "[INFO] Repository needs no update. Abort."
    exit
fi

git add .
git commit -am "Automatic commit message from virtuoso-import-docker: Update of repository at $dt"
git push

echo "[INFO] Exit."
