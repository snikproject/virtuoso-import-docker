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
command=`cat /virtuoso/dump_one_graph.virtuoso>&1`
run_virtuoso_cmd "$command"

echo "[INFO] $dt Starting dump process...";

echo "[INFO] initializing named graphs from *.graph files"
declare -A serializer=( ["nt"]="ntriples" ["rdf"]="rdfxml" ["xml"]="rdfxml" ["ttl"]="turtle")
for ext in nt rdf ttl xml; do
    for graph_file in *.${ext}.graph; do
        if [ ! -f ${graph_file} ]; then
            # skip when the loop iterates varbatom "*.xml.graph" files
            continue
        fi

        graph=`head -n1 ${graph_file}`

        echo "[INFO] dump graph $graph to ${graph_file%.graph}"
        # Now use it to dump
        run_virtuoso_cmd "dump_one_graph('${graph}', '${export_dir}/tmp_data_', 1000000000);"
        exportfile="tmp_data_000001.ttl"
        if [ -f ./normalize.sh ]; do
            mv $exportfile ${graph_file%.graph}
            ./normalize.sh ${graph_file%.graph}
        else
            rapper -q -i turtle -o ${serializer[$ext]} $exportfile | LC_ALL=C sort -u > ${graph_file%.graph}
        fi
        rm "$exportfile"
        rm "$exportfile.graph"
    done
done

echo "[INFO] dump done;"
