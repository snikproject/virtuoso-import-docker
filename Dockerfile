FROM debian:jessie
MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>

ENV GIT_REPO ""
ENV IMPORT_VOLUME="/var/lib/import"

RUN apt-get update
RUN apt-get install -y git libldap-2.4-2 libssl1.0.0 unixodbc bzip2 unzip raptor-utils

# Add virtuoso odbc dependency
ADD libvirtodbc0_7.2_amd64.deb /
RUN dpkg -i libvirtodbc0_7.2_amd64.deb

# Configure odbc for virtuoso
ADD odbc.ini /etc/
ADD odbcinst.ini /etc/

ADD restore.sh /usr/bin/
ADD virtload-classic.sh /usr/bin/

RUN chmod +x /usr/bin/restore.sh
RUN chmod +x /usr/bin/virtload-classic.sh

VOLUME $IMPORT_VOLUME
VOLUME "/root/.ssh"

CMD /usr/bin/restore.sh
