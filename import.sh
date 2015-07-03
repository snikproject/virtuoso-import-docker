#!/usr/bin/env bash

set -o nounset

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}
cmd="${bin} ${host}:${port} ${user} ${password}"

store_import_dir='/import_store'

test_connection () {
    if [[ -z $1 ]]; then
        echo "[ERROR] missing argument: retry attempts"
        exit 1
    fi

    t=$1

    res=$( ${cmd} )
    while [[ $? -ne 0 ]] ;
    do
        echo -n "."
        sleep 1
        echo $t
        let "t=$t-1"
        if [ $t -eq 0 ]
        then
            echo "timeout"
            exit 2
        fi
        res=$( ${cmd} )
    done
}

bz2_to_gz () {
    if [[ -z "$1" || ! -d "$1"  ]]; then
        echo "[ERROR] not a valid directory path: $wd"
        exit 1
    fi

    wd="$1"
    bz2_archives=( "$wd"/*bz2 )
    bz2_archive_count=${#bz2_archives[@]}
    if [[ $bz2_archive_count -eq 0 || ( $bz2_archive_count -eq 1 && "$bz2_archives" == "${wd}/*bz2" ) ]]; then
        #nothing to convert
        exit 0
    else
        echo "[INFO] converting $bz2_archive_count bzip2 archives to gzip:"
        for archive in ${bz2_archives[@]}; do
            echo "[INFO] converting $archive"
            pbzip2 -dc $archive | pigz - > ${archive%bz2}gz
        done
    fi
}

echo "copying import files to store volume"
cp /import/* "$store_import_dir"

cd "$store_import_dir"

bz2_to_gz "$store_import_dir"

echo "[INFO] waiting for store to come online"
test_connection 10
if [ $? -eq 2 ]; then
    echo "[ERROR] store not reachable"
    exit 1
fi

for graph_file in *.graph; do
    graph=`head -n1 ${graph_file}`
    echo ${graph}
    ${cmd} exec="sparql CREATE SILENT GRAPH <${graph}>;"
done

#ensure that all supported formats get into the load list 
#(since we have to excluse graph-files *.* won't do the trick
for ext in nt nq owl rdf trig ttl xml gz; do
  ${cmd} exec="ld_dir ('/import_store', '*.${ext}', NULL);"
done

# For docker there is no job management by default to put multiple loaders to the background with "&"
${cmd} exec="rdf_loader_run();"

echo "done loading graphs (start hanging around idle)"

# idle because else docker compose would terminate all the other containers
# http://stackoverflow.com/questions/30811855/docker-compose-with-one-terminating-container
#
# is /dev/zero better for this?
tail -f /dev/null
