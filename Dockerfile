FROM debian:jessie
MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>

ENV DEBIAN_FRONTEND noninteractive

ENV GIT_REPO ""
ENV IMPORT_VOLUME="/var/lib/import"

RUN apt-get update
RUN apt-get install -y git virtuoso-opensource bzip2 unzip raptor-utils

# We need the virtuoso package to run isql-vt, 
# but we do not need the server running
RUN /etc/init.d/virtuoso-opensource-6.1 stop


ADD restore.sh /usr/bin/
ADD virtload-classic.sh /usr/bin/

RUN chmod +x /usr/bin/restore.sh
RUN chmod +x /usr/bin/virtload-classic.sh

VOLUME $IMPORT_VOLUME
VOLUME "/root/.ssh"

CMD /usr/bin/restore.sh
