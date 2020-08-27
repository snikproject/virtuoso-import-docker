#!/usr/bin/env bash

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

# First define the procedure
command=`cat ../dump_one_graph.virtuoso>&1`
run_virtuoso_cmd "$command"

echo "[INFO] $dt Starting dump process...";

# Now use it to dump
run_virtuoso_cmd "dump_one_graph('${GRAPH_URI}', '${export_dir}/data_', 1000000000);"

echo "[INFO] dump done;"
