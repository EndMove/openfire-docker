#!/bin/bash
set -e

# Initialization of the initialization
pre_initialization() {
  # remove default dir and rewire folders
  rm -rf /usr/share/openfire/{conf,resources/security,lib/log4j.xml}
  ln -sf ${OPENFIRE_DATA_DIR}/conf /usr/share/openfire/
  ln -sf ${OPENFIRE_DATA_DIR}/conf/security /usr/share/openfire/resources/
  ln -sf ${OPENFIRE_DATA_DIR}/conf/log4j.xml /usr/share/openfire/lib/
}

# Initialization of folders, links, ans more
initialization() {
  # creating main folder & perm & owner
  mkdir -p ${OPENFIRE_DATA_DIR}
  chmod -R 0750 ${OPENFIRE_DATA_DIR}
  chown -R ${OPENFIRE_USER}:${OPENFIRE_USER} ${OPENFIRE_DATA_DIR}

  # move existing folders
  [ -d ${OPENFIRE_DATA_DIR}/etc ] && mv ${OPENFIRE_DATA_DIR}/etc ${OPENFIRE_DATA_DIR}/conf
  [ -d ${OPENFIRE_DATA_DIR}/lib/plugins ] && mv ${OPENFIRE_DATA_DIR}/lib/plugins ${OPENFIRE_DATA_DIR}/plugins
  [ -d ${OPENFIRE_DATA_DIR}/lib/embedded-db ] && mv ${OPENFIRE_DATA_DIR}/lib/embedded-db ${OPENFIRE_DATA_DIR}/embedded-db
  rm -rf ${OPENFIRE_DATA_DIR}/lib

  # initialize the data volume
  if [ ! -d ${OPENFIRE_DATA_DIR}/conf ]; then
    sudo -HEu ${OPENFIRE_USER} cp -a /etc/openfire ${OPENFIRE_DATA_DIR}/conf
  fi
  sudo -HEu ${OPENFIRE_USER} mkdir -p ${OPENFIRE_DATA_DIR}/{plugins,embedded-db}
  sudo -HEu ${OPENFIRE_USER} rm -rf ${OPENFIRE_DATA_DIR}/plugins/admin
  sudo -HEu ${OPENFIRE_USER} ln -sf /usr/share/openfire/plugin-admin /var/lib/openfire/plugins/admin

  # creating log folder & perm & owner
  mkdir -p ${OPENFIRE_LOG_DIR}
  chmod -R 0755 ${OPENFIRE_LOG_DIR}
  chown -R ${OPENFIRE_USER}:${OPENFIRE_USER} ${OPENFIRE_LOG_DIR}

  # make a copy of all components and create folder of them
  [ ! -e ${OPENFIRE_DATA_DIR}/plugins/certificatemanager.jar ] && cp -rf ${OPENFIRE_CPNT_DIR}/plugins/certificatemanager.jar ${OPENFIRE_DATA_DIR}/plugins/certificatemanager.jar
  mkdir -p ${OPENFIRE_DATA_DIR}/conf/security/hotdeploy

  # manage SSL certificate if available (/!\ Doesn't work)
  # if [ -e /usr/share/openfire/ssl/ssl.pem ] && [ -e ${OPENFIRE_DATA_DIR}/conf/security/keystore ]; then
  #   if [ ${OPENFIRE_DATA_DIR}/conf/security/keystore -ot /usr/share/openfire/ssl/ssl.pem ] || [ ! -e ${OPENFIRE_DATA_DIR}/conf/security/ssl-tmp.pem ]; then
  #     [ -e ${OPENFIRE_DATA_DIR}/conf/security/ssl-tmp.pem ] && rm -f ${OPENFIRE_DATA_DIR}/conf/security/ssl-tmp.pem
  #     cp -f /usr/share/openfire/ssl/ssl.pem ${OPENFIRE_DATA_DIR}/conf/security/ssl-tmp.pem
  #     rm -f ${OPENFIRE_DATA_DIR}/conf/security/keystore
  #     cd ${OPENFIRE_DATA_DIR}/conf/security/
  #     printf "changeit\nchangeit\nyes" | keytool -import -keystore keystore -alias openfiredomain -file ssl-tmp.pem
  #   fi
  # fi

  # create build version file and update it
  CURRENT_VERSION=1.0.0
  [ -f ${OPENFIRE_DATA_DIR}/openfire_version ] && CURRENT_VERSION=$(cat ${OPENFIRE_DATA_DIR}/openfire_version)
  if [ ${OPENFIRE_VERSION} != ${CURRENT_VERSION} ]; then
    echo -n "${OPENFIRE_VERSION}" | sudo -HEu ${OPENFIRE_USER} tee ${OPENFIRE_DATA_DIR}/openfire_version >/dev/null
  fi

  # creating copyright file & license
  if [ ! -e ${OPENFIRE_DATA_DIR}/copyright ] || [ ! -e ${OPENFIRE_DATA_DIR}/LICENSE ]; then
    cp ${OPENFIRE_CPNT_DIR}/copyright ${OPENFIRE_DATA_DIR}/copyright
    cp ${OPENFIRE_CPNT_DIR}/LICENSE ${OPENFIRE_DATA_DIR}/LICENSE
  fi
}

# Start-Stop Openfire
post_initialization() {
  # get the openfire launch arguments
  if [ "${1:0:1}" = '-' ]; then
    EXTRA_ARGS="$@"
    set --
  fi

  # execution of the startup command (default) of openfire and launch services
  if [ -z ${1} ]; then
    exec start-stop-daemon --start --chuid ${OPENFIRE_USER}:${OPENFIRE_USER} --exec /usr/bin/java -- \
      -server \
      -DopenfireHome=/usr/share/openfire \
      -Dopenfire.lib.dir=/usr/share/openfire/lib \
      -classpath /usr/share/openfire/lib/startup.jar \
      -jar /usr/share/openfire/lib/startup.jar ${EXTRA_ARGS}
  else
    exec "$@"
  fi
}

pre_initialization
initialization
post_initialization