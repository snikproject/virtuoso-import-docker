FROM ubuntu:18.04

LABEL maintainer="Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>, Natanael Arndt <arndt@informatik.uni-leipzig.de>"
LABEL org.aksw.dld=true org.aksw.dld.type="import" org.aksw.dld.require.store="virtuoso" org.aksw.dld.config="{volumes_from: [store]}"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y git pigz pbzip2 unixodbc
RUN mkdir /virtuoso
RUN mkdir /virtuoso/local

ADD import.sh /virtuoso
ADD odbc.ini /etc/odbc.ini

WORKDIR /virtuoso

ENTRYPOINT ./import.sh
