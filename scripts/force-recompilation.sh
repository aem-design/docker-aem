#!/bin/bash

if [[ $1 == "-h" ]]; then
    echo "Usage: force-recompilation.sh <user:password> <http://server:port>"
    echo
    echo "Example arguments: admin:admin http://localhost:8080"
    echo
    echo "This will force a recompilation of all Sling scripts (jsps, java, sightly etc.)."
    exit
fi

AEM_DIR="/aem/crx-quickstart"
AEM_URL="http://localhost:8080"
AEM_CREDS="admin:admin"

CREDS="${1:-$AEM_CREDS}"
HOST="${2:-$AEM_URL}"

if [[ ! -d "$AEM_DIR" ]]; then
    echo "No crx-quickstart directory found."
    exit
fi

echo "stopping the org.apache.sling.commons.fsclassloader bundle..."
BUNDLE="org.apache.sling.commons.fsclassloader"
curl -f -s -S -u $CREDS -F action=stop  $HOST/system/console/bundles/$BUNDLE > /dev/null
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo
    if [ $EXIT_CODE -eq 22 ]; then
        echo "Invalid admin password."
    fi
    echo "aborted.";
    exit
fi

cd "$AEM_DIR"

CLASS_DIRS=`find launchpad/felix -path "*/bundle*/data/classes" -type d`
if [[ -d "$CLASS_DIRS" ]]; then
    echo "deleting file sytem classes cache: `pwd`/$CLASS_DIRS ..."
    rm -rf "$CLASS_DIRS"
else
    echo "file system classes cache empty or already cleared"
fi

echo "deleting /var/classes in the JCR..."
curl -f -s -S -u $CREDS -X DELETE $HOST/var/classes > /dev/null

echo "starting the org.apache.sling.commons.fsclassloader bundle..."
curl -f -s -S -u $CREDS -F action=start $HOST/system/console/bundles/$BUNDLE > /dev/null
if [[ $? -ne 0 ]]; then
    echo
    echo "aborted, bundle was likely not restarted.";
    exit
fi

echo "done."