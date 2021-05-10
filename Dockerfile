# build OS
FROM ubuntu:18.04

# script creator
MAINTAINER endmove "contact@endmove.eu"

# vars
ENV OPENFIRE_VERSION=4.6.3 \
  OPENFIRE_USER=openfire \
  OPENFIRE_DATA_DIR=/var/lib/openfire \
  OPENFIRE_LOG_DIR=/var/log/openfire \
  OPENFIRE_CPNT_DIR=/usr/local/bin/openfire

# creat a new group and user
RUN groupadd -r ${OPENFIRE_USER}; \
  useradd -r -g ${OPENFIRE_USER} ${OPENFIRE_USER}

# install java 8 and Openfire
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get install -y sudo wget openjdk-8-jre \
  && apt-get clean \
  && wget "http://download.igniterealtime.org/openfire/openfire_${OPENFIRE_VERSION}_all.deb" -O /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
  && dpkg -i /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
  && mv /var/lib/openfire/plugins/admin /usr/share/openfire/plugin-admin \
  && rm -rf /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
  && rm -rf /var/lib/apt/lists/*

# make a copy of files to /sbin
COPY ["copyright", "LICENSE", "entrypoint.sh", "${OPENFIRE_CPNT_DIR}/"]
RUN chmod 755 ${OPENFIRE_CPNT_DIR}/entrypoint.sh

# make a copy of all components
COPY components/ ${OPENFIRE_CPNT_DIR}/

# create ssl folder
RUN mkdir /usr/share/openfire/ssl; \
  chmod -R 0750 /usr/share/openfire/ssl; \
  chown -R ${OPENFIRE_USER}:${OPENFIRE_USER} /usr/share/openfire/ssl

# expose ports
EXPOSE 5222/tcp 5223/tcp 5229/tcp 5262/tcp 5263/tcp 5269/tcp 5270/tcp 5275/tcp 5276/tcp 7070/tcp 7443/tcp 7777/tcp 9090/tcp 9091/tcp

# volume & entrypoint
VOLUME ${OPENFIRE_DATA_DIR}
ENTRYPOINT ["/usr/local/bin/openfire/entrypoint.sh"]