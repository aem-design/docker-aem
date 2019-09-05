#!/bin/bash
set -e

function help() {
echo "Usage:"
echo "  ./download.sh {[FILE NAME PREFIX] [AUTH] [URL]}..."
echo ""
echo "  FILENAME_PREFIX:"
echo "    - filename prefix to use [-] = none"
echo "  AUTH:"
echo "    - auth to use [-] = none"
echo "  URL:"
echo "    - url to get"
}

function download() {

    local FILENAME_PREFIX=${1?Need file name prefix}
    local FILEURL=${2?Need file url}
    echo "download: $FILEURL"

    local FILENAME=$(basename "$FILEURL")

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
    echo "download: $FILEURL"

    local FILENAME=$(basename "$FILEURL")

	echo "DOWNLOADING $FILENAME"
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
        local URL=${ACTIONS[$(($i + 2))]}

        if [[ ! $FILENAME_PREFIX == "" && ! $AUTH == "" && ! $URL == "" ]]; then

            if [[ $AUTH == "-" ]]; then
                download "$FILENAME_PREFIX" "$URL"
            else
                downloadAuth "$FILENAME_PREFIX" "$AUTH" "$URL"
            fi

        fi

     done


}


main "$@"
