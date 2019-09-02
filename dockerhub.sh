#!/bin/bash

# set username and password
API_URL_DEFAULT="https://hub.docker.com/v2"
USERNAME="${1?Need username}"
PASSWORD="${2?Need password}"
REPO="${3?Need repo name}"
README="${4?Need readme}"
API_URL="${5:-$API_URL_DEFAULT}"

# get token to be able to talk to Docker Hub
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${USERNAME}'", "password": "'${PASSWORD}'"}' ${API_URL}/users/login/ | sed -e 's/.*"token": "\(.*\)".*/\1/')

RESPONSE=$(curl -s --write-out %{response_code} --output /dev/null -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${README} ${API_URL}/repositories/${REPO}/)

if [[ ${RESPONSE} -eq 200 ]]; then
    exit 0
else
    echo USERNAME=${USERNAME}
    echo REPO=${REPO}
    echo README=${README}
    echo API_URL=${API_URL}
    echo "curl -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${README} ${API_URL}/repositories/${REPO}/"
    curl -v -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${README} ${API_URL}/repositories/${REPO}/
    exit 1
fi
