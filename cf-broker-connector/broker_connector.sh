#!/bin/bash
#
# Copyright (c) 2016 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

VAR_NAME_PREFIX=""

function check_if_exists() {
    NAME=$1
    VALUE=$2
    if [ "$VALUE" = "" ]; then
        echo "${VAR_NAME_PREFIX}${NAME} env cannot be found"
        exit 1
    fi
}

check_if_exists "ACTION" $ACTION
check_if_exists "BROKER_SERVICE_NAME" $BROKER_SERVICE_NAME

BROKER_SERVICE_NAME=$(echo $BROKER_SERVICE_NAME | sed 's/-/_/g')

host=${BROKER_SERVICE_NAME}_SERVICE_HOST
host=${host^^}
check_if_exists ${host} "${!host}"

port=${BROKER_SERVICE_NAME}_SERVICE_PORT
port=${port^^}
check_if_exists ${port} "${!port}"

ADDRESS="${!host}:${!port}"

CREDS=""
if [ "$BROKER_USERNAME" != "" ]; then
    CREDS="--user $BROKER_USERNAME:$BROKER_PASSWORD"
fi

function send_request() {
    ACTION=$1
    URL=$2
    BODY=$3
    EXPECTED_CODE=$4

    check_if_exists "EXPECTED_CODE" "$EXPECTED_CODE"
    check_if_exists "URL" "$URL"

    if [ "$ACTION" = "CREATE" ] || [ "$ACTION" = "BIND" ]; then
        check_if_exists "BODY" "$BODY"
    fi

    if [ "$ACTION" = "CREATE" ] || [ "$ACTION" = "BIND" ]; then
        echo "$BODY" > bodyfile.json
        HTTP_RESPONSE=$(curl -s --write-out "HTTPSTATUS:%{http_code}" -X PUT ${ADDRESS}${URL} ${CREDS} -d @bodyfile.json -H "X-Broker-API-Version: 2.10" -H "Content-Type: application/json")
    elif [ "$ACTION" = "UNBIND" ] || [ "$ACTION" = "DELETE" ] ; then
        HTTP_RESPONSE=$(curl -s --write-out "HTTPSTATUS:%{http_code}" -X DELETE ${ADDRESS}${URL} ${CREDS})
    else
        echo "Action not supported: $ACTION"
        exit 1
    fi

    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    if [ "$HTTP_STATUS" != "$EXPECTED_CODE" ]; then
        echo "Bad response status! Received code: $HTTP_STATUS, expected: $EXPECTED_CODE. Response body: $HTTP_BODY"
        exit 1
    fi

    echo $HTTP_BODY
}

if [ "$ACTION" = "CREATE" ] || [ "$ACTION" = "BIND" ] || [ "$ACTION" = "UNBIND" ] || [ "$ACTION" = "DELETE" ]; then

    HTTP_BODY=$(send_request "$ACTION" "$URL" "$BODY" "$EXPECTED_CODE")
    if [ $? != 0 ]; then
        echo $HTTP_BODY
        exit 1
    fi

elif [ "$ACTION" = "CREATE_AND_BIND" ]; then

    VAR_NAME_PREFIX="CREATE_"
    CREATE_RESULT=$(send_request "CREATE" "$CREATE_URL" "$CREATE_BODY" "$CREATE_EXPECTED_CODE")
    if [ $? != 0 ]; then
        echo $CREATE_RESULT
        exit 1
    fi
    VAR_NAME_PREFIX="BIND_"
    BIND_RESULT=$(send_request "BIND" "$BIND_URL" "$BIND_BODY" "$BIND_EXPECTED_CODE")
    if [ $? != 0 ]; then
        echo $BIND_RESULT
        exit 1
    fi
    VAR_NAME_PREFIX="UNBIND_"
    UNBIND_RESULT=$(send_request "UNBIND" "$UNBIND_URL" "" "$UNBIND_EXPECTED_CODE")
    if [ $? != 0 ]; then
        echo $UNBIND_RESULT
        exit 1
    fi

    HTTP_BODY="$BIND_RESULT"

else
    echo "Action not supported: $ACTION"
    exit 1
fi

echo $HTTP_BODY