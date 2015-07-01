#!/usr/bin/env bash

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}
cmd="${bin} ${host}:${port} ${user} ${password}"

cp /import/* /import_store

cd /import_store

# wait for store to be available
ret=$( /test_connection.sh 10 )
if [ $? != "0" ]
then
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
