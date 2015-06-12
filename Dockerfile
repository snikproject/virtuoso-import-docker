FROM debian:jessie
MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>

ENV DEBIAN_FRONTEND noninteractive

ENV IMPORT_VOLUME="/import"

RUN apt-get update
RUN apt-get install -y git virtuoso-opensource

ADD import.sh /
ADD test_connection.sh /

VOLUME $IMPORT_VOLUME

WORKDIR $IMPORT_VOLUME

CMD ["/import.sh"]
