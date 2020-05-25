# Virtuoso Import Docker

The purpose of this docker is to load graph dumps into a linked virtuoso store container.
Currently we are working to support the `tenforce/virtuoso` container.

Dump data can be inserted to the import container through an exposed volume or with a git repository declared as an environment variable.
To enable cloning of private git repositories the import container exposes its `/root/.ssh` folder for SSH key insertion.

The link alias for the import container has to be `virtuoso`.

# Usage instructions

`import.sh` is used to import directories of rdf graphs into virtuoso with the built-in loading process (http://vos.openlinksw.com/owiki/wiki/VOS/VirtBulkRDFLoader).
We currently support uncompressed graph files, but also gzip and bzip2 compressed graph files. You should prefer to use gzip, as the bzip2 files are transformed to gzip. xz does currently not work.

To start the container, it requires some environment variables:

- `DBA_PASSWORD`: The virtuoso password. It should be the same as what you provide to the `tenforce/virtuoso`.
- `VIRTUOSO_IMPORT_DIR`: The location of the models to be imported. It should be linked as a common volume to `tenforce/virtuoso` and the importer. The path should also be the same within both containers.
- `GIT_REPO`: The URL of the repository used via `git clone` and SSH.
- `GIT_EMAIL`: The e-mail address of the user which should create and push commits.
- `GIT_NAME`: The name of the user which should create and push commits.
- `GRAPH_URI`: The URI of the graph which should be copied into the repo.

Either you run the container 

- with /virtuoso/import.sh as command for importing data from the volume or
- /virtuoso/git_import.sh for importing data one time from the repository or
- /virtuoso/git_write.sh in order to use data from virtuoso and update with it the repository or
- without any command in order to enable cron for pulling the repository every 5 minutes and write it into virtuoso.

# Information for the future

If import of big files by splitting them into chunks is needed, go back to commit `28b2e322dd6b9373f8242398070eea87ac535862` and cherry-pick `virtload-classic.sh` and see how it works. Todo: Fix `file_to_string_output` error from virtload-classic.sh script.


An export of RDF out of Virtuoso results in files with uncommon datetime formats, unicode transformations and an unsorted list of triples.
Atm we just use sorting before updating the git repo.
