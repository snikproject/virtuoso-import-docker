FROM debian:jessie

MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>
MAINTAINER Natanael Arndt <arndt@informatik.uni-leipzig.de>

LABEL org.aksw.dld=true org.aksw.dld.type="import" org.aksw.dld.require.store="virtuoso" org.aksw.dld.config="volumes_from: - store"

ENV DEBIAN_FRONTEND noninteractive

ENV IMPORT_VOLUME="/import"

RUN apt-get update
RUN apt-get install -y git virtuoso-opensource

ADD import.sh /
ADD test_connection.sh /

VOLUME $IMPORT_VOLUME

WORKDIR $IMPORT_VOLUME

CMD ["/import.sh"]
