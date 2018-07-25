#!/bin/bash

mkdir -p /aem/crx-quickstart/logs

LOG=/aem/crx-quickstart/logs/start_history.log

function log() {
    echo "`date` $1">>"$LOG"
}

log "Checking If First Time"

# check if has been extracted earlier
#if [ ! -d "/aem/crx-quickstart/bin" ] ; then
#
#    log "===================================================="
#    log "Unpacking AEM Package"
#    cd /aem; java -jar cq-quickstart-6.jar -unpack >>"$LOG"
#    log "Unpacking Is DONE"
#    log "----------------------------------------------------"
#    log "Copying Configuration files"
#    mkdir -p /aem/crx-quickstart/install && cp -a /aem/install/. /aem/crx-quickstart/install/
#    log "===================================================="
#    log "Install DONE"
#
#fi

# Merged from /crx-quickstart/bin/start and /crx-quickstart/bin/quickstart
#
# This script configures the start information for this server.
#
# The following variables may be used to override the defaults.
# For one-time overrides the variable can be set as part of the command-line; e.g.,
#
#     % AEM_PORT=1234 ./start
#

#Force all ports
#AEM_PORT=8080
AEM_DEBUG_PORT=58242

# TCP port used for stop and status scripts
if [ -z "$AEM_PORT" ]; then
    AEM_PORT=4502
fi

# hostname of the interface that this server should listen to
if [ -z "$AEM_HOST" ]; then
    AEM_HOST=0.0.0.0
fi

# runmode(s)
# will not be used if repository is already present
if [ -z "$AEM_RUNMODE" ]; then
    AEM_RUNMODE='author'
fi

# name of the jarfile
if [ -z "$AEM_JARFILE" ]; then
    AEM_JARFILE=''
fi

# default JVM options
if [ -z "$AEM_JVM_OPTS" ]; then
    AEM_JVM_OPTS='-server -Xmx1024m -XX:MaxPermSize=256M -Djava.awt.headless=true'
fi

# file size limit (ulimit)
if [ -z "$AEM_FILE_SIZE_LIMIT" ]; then
    AEM_FILE_SIZE_LIMIT=8192
fi

# ------------------------------------------------------------------------------
# authentication
# ------------------------------------------------------------------------------
# when using oak (crx3) authentication must be configured using the
# Apache Felix JAAS Configuration Factory service via the Web Console
# see http://jackrabbit.apache.org/oak/docs/security/authentication/externalloginmodule.html

# use jaas.config (legacy: only used for crx2 persistence)
#if [ -z "$AEM_USE_JAAS" ]; then
#	AEM_USE_JAAS='true'
#fi

# config for jaas (legacy: only used for crx2 persistence)
#if [ -z "$AEM_JAAS_CONFIG" ]; then
#	AEM_JAAS_CONFIG='etc/jaas.config'
#fi

# ------------------------------------------------------------------------------
# persistence mode
# ------------------------------------------------------------------------------
# the persistence mode can not be switched for an existing repository
AEM_RUNMODE="${AEM_RUNMODE},crx3,crx3tar"
#AEM_RUNMODE="${AEM_RUNMODE},crx3,crx3mongo"

# settings for mongo db
#if [ -z "$AEM_MONGO_HOST" ]; then
#	AEM_MONGO_HOST=127.0.0.1
#fi
#if [ -z "$AEM_MONGO_PORT" ]; then
#	AEM_MONGO_PORT=27017
#fi
#if [ -z "$AEM_MONGO_DB" ]; then
#	AEM_MONGO_DB=aem6
#fi

# ------------------------------------------------------------------------------
# do not configure below this point
# ------------------------------------------------------------------------------

if [ $AEM_FILE_SIZE_LIMIT ]; then
    CURRENT_ULIMIT=`ulimit`
    if [ $CURRENT_ULIMIT != "unlimited" ]; then
        if [ $CURRENT_ULIMIT -lt $AEM_FILE_SIZE_LIMIT ]; then
            echo "ulimit ${CURRENT_ULIMIT} is too small (must be at least ${AEM_FILE_SIZE_LIMIT})"
            exit 1
        fi
    fi
fi

AEM_JARFILE=`find /aem/crx-quickstart/app/ -name "*quickstart.jar" -print -quit`
CURR_DIR="/aem/crx-quickstart"

#BIN_PATH=$(dirname $0)
#cd $BIN_PATH/..
#if [ -z $AEM_JARFILE ]; then
#	AEM_JARFILE=`ls app/*.jar | head -1`
#fi
#CURR_DIR=$(basename $(pwd))
#cd ..

START_OPTS="start -c ${CURR_DIR} -i launchpad"
if [ $AEM_PORT ]; then
    START_OPTS="${START_OPTS} -p ${AEM_PORT}"
fi

#merged from quickstart
#if [ $AEM_GUI ]; then
#	START_OPTS="${START_OPTS} -gui"
#fi
if [ $AEM_VERBOSE ]; then
    START_OPTS="${START_OPTS} -verbose"
fi
if [ $AEM_NOFORK ]; then
    START_OPTS="${START_OPTS} -nofork"
fi
if [ $AEM_FORK ]; then
    START_OPTS="${START_OPTS} -fork"
fi
if [ $AEM_FORKARGS ]; then
    START_OPTS="${START_OPTS} -forkargs ${AEM_FORKARGS}"
fi
if [ $AEM_LOWMEMACTION ]; then
    START_OPTS="${START_OPTS} -low-mem-action ${AEM_LOWMEMACTION}"
fi

if [ $AEM_RUNMODE ]; then
    AEM_JVM_OPTS="${AEM_JVM_OPTS} -Dsling.run.modes=${AEM_RUNMODE}"
fi
if [ $AEM_HOST ]; then
    AEM_JVM_OPTS="${AEM_JVM_OPTS} -Dorg.apache.felix.http.host=${AEM_HOST}"
    START_OPTS="${START_OPTS} -a ${AEM_HOST}"
fi
if [ $AEM_MONGO_HOST ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.host=${AEM_MONGO_HOST}"
fi
if [ $AEM_MONGO_PORT ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.port=${AEM_MONGO_PORT}"
fi
if [ $AEM_MONGO_DB ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.db=${AEM_MONGO_DB}"
fi

if [ $AEM_USE_JAAS ]; then
    AEM_JVM_OPTS="${AEM_JVM_OPTS} -Djava.security.auth.login.config=${AEM_JAAS_CONFIG}"
fi
START_OPTS="${START_OPTS} -Dsling.properties=conf/sling.properties"

if [ $AEM_DEBUG ]; then
    AEM_JVM_OPTS="${AEM_JVM_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=${AEM_DEBUG_PORT},suspend=n"
fi

if [ $AEM_MONITOR ]; then
    if [ -z "$AEM_MONITOR_PORT" ]; then
        AEM_MONITOR_PORT=3333
    fi
    #allow visual VM to connect
    AEM_JVM_OPTS="${AEM_JVM_OPTS} -Dcom.sun.management.jmxremote.port=${AEM_MONITOR_PORT} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
fi

# timezone
if [ "$AEM_TZ" ]; then
     AEM_JVM_OPTS="${AEM_JVM_OPTS} -Duser.timezone=${AEM_TZ}"
fi

#allow override of everything!!!
AEM_JVM_OPTS=${AEM_JVM_OPTS_OVD:-$AEM_JVM_OPTS}
AEM_START_OPT=${AEM_START_OPTS_OVD:-$START_OPTS}


log "Starting..."

log "java $AEM_JVM_OPTS -jar $AEM_JARFILE $AEM_START_OPT"

##IF UPGRADE
if [ $AEM_UPGRADE ]; then
    AEM_START_OPT="-r"
fi

if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then

    exec java $AEM_JVM_OPTS -jar $AEM_JARFILE $AEM_START_OPT

fi

# As argument is not jenkins, assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"

#trap '/aem/crx-quickstart/bin/stop' TERM INT
#java $AEM_JVM_OPTS -jar $AEM_JARFILE $AEM_START_OPT &
#PID=$!
#wait $PID
#trap - TERM INT
#wait $PID
#EXIT_STATUS=$?

#(
#  (
#    java $AEM_JVM_OPTS -jar $CURR_DIR/$CQ_JARFILE $AEM_START_OPT &
#    echo $! > $CURR_DIR/conf/cq.pid
#  ) >> $CURR_DIR/logs/stdout.log 2>&1
#) &