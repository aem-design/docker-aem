#!/bin/bash
set -e

function help() {
echo "Usage:"
echo "  ./download.sh {[FILE NAME PREFIX] [AUTH] [MODULE] [URL]}..."
echo ""
echo "  FILENAME_PREFIX:"
echo "    - filename prefix to use, [-] = none"
echo "  AUTH:"
echo "    - auth to use, [-] = none"
echo "  MODULE:"
echo "    - module to use, [-] = none"
echo "  URL:"
echo "    - url to get"
}

function download() {

    local FILENAME_PREFIX=${1?Need file name prefix}
    local FILEURL=${2?Need file url}
    local MODULE=${3:-}
    echo "download: $FILEURL"
    echo "module: $MODULE"

    local FILENAME=$(basename "$FILEURL")

    if [[ "$MODULE" == *githublatest:* ]]; then
        FILEURL=$(curl -s -L ${FILEURL} | awk -v GITHUB_LATEST_FILTER=aemdesign-aem-core-deploy -f scripts/githublatest.awk)
        if [[ "$FILEURL" == "" ]]; then
            echo "module: error, could not get url from module"
            exit 0
        fi
        FILENAME=$(basename "$FILEURL")
    else
        echo "module: not supported"
    fi

    echo "DOWNLOADING $FILEURL to ${FILENAME_PREFIX}${FILENAME}"
    curl \
    --connect-timeout 30 \
    --retry 300 \
    --retry-delay 5 \
    -L "${FILEURL}" -o ${FILENAME_PREFIX}${FILENAME}

}

function downloadAuth() {

    local FILENAME_PREFIX=${1?Need file name prefix}
    local BASICCREDS=${2?Need username password}
    local FILEURL=${3?Need file url}
    local MODULE=${4:-}
    echo "download: $FILEURL"
    echo "module: not supported"

    local FILENAME=$(basename "$FILEURL")

	echo "DOWNLOADING $FILENAME into ${FILENAME_PREFIX}${FILENAME}"
    curl \
		--connect-timeout 30 \
		--retry 300 \
		--retry-delay 5 \
		-A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" \
		-k -v \
		-u "${BASICCREDS}" -L "${FILEURL}" -o ${FILENAME_PREFIX}${FILENAME}

}


function main() {

    if [[ $# -eq 0 ]]; then
        help
        exit 1
    fi

    local ACTIONS_COUNT=$#
    local ACTIONS=($@)

    for (( i=0; i<=$ACTIONS_COUNT; i+=3 ))
      do

        local FILENAME_PREFIX=${ACTIONS[$i]}
        local AUTH=${ACTIONS[$(($i + 1))]}
        local FLAGS=${ACTIONS[$(($i + 2))]}
        local URL=${ACTIONS[$(($i + 3))]}

        if [[ ! $FILENAME_PREFIX == "" && ! $AUTH == "" && ! $URL == "" ]]; then

            if [[ $AUTH == "-" ]]; then
                download "$FILENAME_PREFIX" "$URL" "$FLAGS"
            else
                downloadAuth "$FILENAME_PREFIX" "$AUTH" "$URL" "$FLAGS"
            fi

        fi

     done


}


main "$@"
