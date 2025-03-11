#!/bin/bash

#exec java $AEM_JVM_OPTS $AEM_RUNMODE -jar $AEM_JARFILE $AEM_START_OPTS
AEM_JARFILE=`find /aem/crx-quickstart/app/ -name "*quickstart*.jar" -print -quit`
trap '/aem/crx-quickstart/bin/stop' TERM INT
java $AEM_JVM_OPTS $AEM_RUNMODE -jar $AEM_JARFILE $AEM_START_OPTS &
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIS_STATUS=$?

echo $EXIS_STATUS
