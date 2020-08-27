# Virtuoso Import Docker

The purpose of this docker is to load graph dumps into a linked virtuoso store container.
Currently we are working to support the `tenforce/virtuoso` container.

Dump data can be inserted to the import container through an exposed volume or with a git repository declared as an environment variable.
To enable cloning of private git repositories the import container exposes its `/root/.ssh` folder for SSH key insertion.

The link alias for the import container has to be `virtuoso`.

# Usage instructions

`import.sh` is used to import directories of rdf graphs into virtuoso with the built-in loading process (http://vos.openlinksw.com/owiki/wiki/VOS/VirtBulkRDFLoader).
We currently support uncompressed graph files, but also gzip and bzip2 compressed graph files. You should prefer to use gzip, as the bzip2 files are transformed to gzip. xz does currently not work.

To start the container, it requires some environment variables (in an .env file):

- `DBA_PASSWORD`: The virtuoso password. It should be the same as what you provide to the `tenforce/virtuoso`.
- `VIRTUOSO_DATA_DIR`: The directory into which the data is cloned and from where it is imported into virtuoso. The location of this directory should be the same for this import container as for the virtuoso container.
- `GIT_REPO`: The URL of the repository used via `git clone` and SSH.
- `GIT_EMAIL`: The e-mail address of the user which should create and push commits.
- `GIT_NAME`: The name of the user which should create and push commits.
- `NO_PUSH`: Disable push operation
- `CRON_JOB`: 'dump' or 'import'

You can run the container with one of the following commands:

- `/virtuoso/import.sh` as command for importing data from VIRTUOSO_IMPORT_DIR or
- `/virtuoso/git_import.sh` for importing data one time from the repository or
- `/virtuoso/dump.sh` as command to dump data into VIRTUOSO_IMPORT_DIR or
- `/virtuoso/git_dump.sh` in order to dump the data from virtuoso into a repository, commit and push it or
- without any command (delete the whole `command` line) in order to enable cron. Cron executes `git_import` or `git_dump` (depending on the value of the variable `CRON_JOB`) every 5 minutes.

For the dump process the graphs are automatically detected based on the `*.graph` files in the `VIRTUOSO_DATA_DIR`.

# Normalize dump output

When dumping the the data and before commiting it to the repository it is desired to keep a minimal difference between commits to ease debug on the data.
For this purpose you are able to add a script called `normalize.sh` to your data repository.
This script will be executed by the `dump.sh` script for each graph that was dumped from virtuoso.
The script will receive the name of the dumped file as first argument (`$1`).
You can find an example for a normalize script here:

```
#!/usr/bin/env bash

ttl_file=$1
file_name=${ttl_file%.ttl}
tmp_nt="${ttl_file%.ttl}.tmp.nt"
tmp_ttl="${ttl_file%.ttl}.tmp.ttl"

cp prefixes.ttl ${tmp_nt}
rapper -q -i turtle -o ntriples ${ttl_file} | sort -u >> ${tmp_nt}
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
```

# Information for the future

If import of big files by splitting them into chunks is needed, go back to commit `28b2e322dd6b9373f8242398070eea87ac535862` and cherry-pick `virtload-classic.sh` and see how it works. Todo: Fix `file_to_string_output` error from virtload-classic.sh script.


An export of RDF out of Virtuoso results in files with uncommon datetime formats, unicode transformations and an unsorted list of triples.
Atm we just use sorting before updating the git repo.
