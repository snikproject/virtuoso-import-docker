FROM ubuntu:18.04

LABEL maintainer="Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>, Natanael Arndt <arndt@informatik.uni-leipzig.de>"
LABEL org.aksw.dld=true org.aksw.dld.type="import" org.aksw.dld.require.store="virtuoso" org.aksw.dld.config="{volumes_from: [store]}"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y git pigz pbzip2 virtuoso-opensource cron
RUN mkdir /virtuoso
RUN mkdir /virtuoso/git
RUN mkdir /virtuoso/data
RUN mkdir /root/.ssh && ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts && chmod 0644 /root/.ssh

ADD import.sh /virtuoso
ADD dump.sh /virtuoso
ADD git_import.sh /virtuoso
ADD git_dump.sh /virtuoso
ADD dump_one_graph.virtuoso /virtuoso
ADD cronscript.sh /virtuoso

RUN chmod 0744 /virtuoso/import.sh
RUN chmod 0744 /virtuoso/dump.sh
RUN chmod 0744 /virtuoso/git_import.sh
RUN chmod 0744 /virtuoso/git_dump.sh
RUN chmod 0744 /virtuoso/cronscript.sh

WORKDIR /virtuoso

#CRON
# Copy cronfile file to the cron.d directory
COPY cronfile /etc/cron.d/cronfile

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cronfile

# Apply cron job
RUN crontab /etc/cron.d/cronfile

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

ADD envsetter.sh /virtuoso
RUN chmod 0744 /virtuoso/envsetter.sh

# Run the command on container startup
CMD ["/virtuoso/envsetter.sh"]
