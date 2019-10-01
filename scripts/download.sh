#!/bin/bash
set -e

# get current script location
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

    if [[ ! "$MODULE" == "" && ! "$MODULE" == "-" ]]; then
        MODULE_SCRIPT="${CURRENT_DIR}/$(echo $MODULE | sed -e 's/\(.*\):.*/\1/').py"
        echo "script: ${MODULE_SCRIPT}"

        if [[ ! -f "${MODULE_SCRIPT}" ]]; then
            echo "module: error, could not find module script"
            exit 0
        fi

        FILTER=$(echo $MODULE | sed -e 's/.*:\(.*\)/\1/')
        echo "filter: ${FILTER}"
        echo "url: ${FILEURL}"
        FILEURL_FILTER_URL=$(${MODULE_SCRIPT} ${FILTER} ${FILEURL})
        echo "FILEURL_FILTER_URL:"
        echo ${FILEURL_FILTER_URL}
        if [[ "${FILEURL_FILTER_URL}" == "" ]]; then
            echo "module: error, could not get url from module"
            exit 0
        fi
        FILENAME=$(basename "${FILEURL_FILTER_URL}")
        FILEURL=${FILEURL_FILTER_URL}
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
		-k \
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
