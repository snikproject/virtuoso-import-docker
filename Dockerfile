FROM debian:jessie

LABEL maintainer="Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>, Natanael Arndt <arndt@informatik.uni-leipzig.de>"
LABEL org.aksw.dld=true org.aksw.dld.type="import" org.aksw.dld.require.store="virtuoso" org.aksw.dld.config="{volumes_from: [store]}"

ENV DEBIAN_FRONTEND noninteractive

ENV IMPORT_VOLUME="/import"

RUN apt-get update
RUN apt-get install -y git virtuoso-opensource pigz pbzip2

ADD import.sh /

VOLUME $IMPORT_VOLUME

WORKDIR $IMPORT_VOLUME

CMD ["/import.sh"]
