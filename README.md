# Virtuoso Import Docker

The purpose of this docker is to load graph dumps into a linked virtuoso store container.
Currently we are working to support a linke `tenforce/virtuoso` container.

Dump data can be inserted to the import container through an exposed volume or with a git repository declared as an environment variable.
To enable cloning of private git repositories the import container exposes its `/root/.ssh` folder for SSH key insertion.

The link alias for the import container has to be `virtuoso`.

# Todo

- Fix `file_to_string_output` error from virtload-classic.sh script.

`import.sh` is used to import directories of rdf graphs into virtuoso with the Build loading process (http://vos.openlinksw.com/owiki/wiki/VOS/VirtBulkRDFLoader).

`virtload-classic.sh` can import big files by splitting them into chunks

# Usage instructions

Coming soon

To start the container, it requires some environment variables:

- `DBA_PASSWORD`: The virtuoso password. It should be the same as what you provide to the `tenforce/virtuoso`.
- `VIRTUOSO_IMPORT_DIR`: The location of the models to be imported. It should be linked as a common volume to `tenforce/virtuoso` and the importer. The path should also be the same within both containers.
