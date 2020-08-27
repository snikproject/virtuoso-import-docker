#!/usr/bin/env bash

ttl_file=$1
file_name=${ttl_file%.ttl}
tmp_nt="${ttl_file%.ttl}.tmp.nt"
tmp_ttl="${ttl_file%.ttl}.tmp.ttl"

cp prefixes.ttl ${tmp_nt}
rapper -q -i turtle -o ntriples ${ttl_file} | LC_ALL=C sort -u >> ${tmp_nt}
sed \
    -e 's/"\([0-9]\{4\}\)-\([0-9]\{1\}\)-\([0-9]\{1\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/"\1-0\2-0\3"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/g' \
    -e 's/"\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{1\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/"\1-\2-0\3"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/g' \
    -e 's/"\([0-9]\{4\}\)-\([0-9]\{1\}\)-\([0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/"\1-0\2-\3"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/g' \
    -e 's/"\([0-9]\{4\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYear>/"\1-01-01T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYear>/g' \
    -e 's/"\([0-9]\{4\}-[0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYearMonth>/"\1-01T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYearMonth>/g' \
    -e 's/"\([0-9]\{2\}-[0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gMonthDay>/"0001-\1T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gMonthDay>/g' \
    -e 's/"\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/"\1-\2-\3Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#date>/g' \
    ${tmp_nt} > ${file_name}.nt
rm ${tmp_nt}
rapper -q -i turtle -o turtle ${file_name}.nt > ${tmp_ttl}
sed\
    -e 's/hp:isPastor true/hp:isPastor 1/g' \
    ${tmp_ttl} > ${ttl_file}
rm ${tmp_ttl}

perl -i -CD -p encode.pl ${ttl_file}
