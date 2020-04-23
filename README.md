# Virtuoso Import Docker

The purpose of this docker is to load graph dumps into a linked virtuoso store container.

Dump data can be inserted to the import container through an exposed volume or with a git repository declared as an environment variable.
To enable cloning of private git repositories the import container exposes its `/root/.ssh` folder for SSH key insertion.

The link alias for the import container has to be `virtuoso`.

# Todo

- Fix `file_to_string_output` error from virtload-classic.sh script.

# Usage instructions

Coming soon
