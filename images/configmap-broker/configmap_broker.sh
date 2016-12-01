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

function check_if_exists() {
    NAME=$1
    VALUE=$2
    if [ "$VALUE" = "" ]; then
        echo "${NAME} env cannot be found"
        exit 1
    fi
}

check_if_exists "ACTION" $ACTION
check_if_exists "CONFIGMAP_NAME" $CONFIGMAP_NAME
check_if_exists "CONFIGMAP_SERVICE_NAME" $CONFIGMAP_SERVICE_NAME
check_if_exists "CONFIGMAP_SERVER_NAME" $CONFIGMAP_SERVER_NAME
check_if_exists "CONFIGMAP_SERVER_URL" $CONFIGMAP_SERVER_URL

CONFIGMAP_SERVER_NAME=$(echo $CONFIGMAP_SERVER_NAME | sed 's/-/_/g')

host=${CONFIGMAP_SERVER_NAME}_SERVICE_HOST
host=${host^^}
check_if_exists ${host} "${!host}"

port=${CONFIGMAP_SERVER_NAME}_SERVICE_PORT
port=${port^^}
check_if_exists ${port} "${!port}"

CONFIGMAP_SERVER_ADDRESS="${!host}:${!port}"

CREDS=""
if [ "$CONFIGMAP_SERVER_USER" != "" ]; then
    CREDS="--user $CONFIGMAP_SERVER_USER:$CONFIGMAP_SERVER_PASS"
fi

if [ "$ACTION" = "CREATE_DATAMAP" ] || [ "$ACTION" = "CREATE_VCAP" ] ; then

    EXPECTED_CODE=200
    HTTP_RESPONSE=$(curl -s --write-out "HTTPSTATUS:%{http_code}" $CREDS ${CONFIGMAP_SERVER_ADDRESS}${CONFIGMAP_SERVER_URL}/${CONFIGMAP_NAME})

    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    if [ "$HTTP_STATUS" != "$EXPECTED_CODE" ]; then
        echo "Bad response status! Received code: $HTTP_STATUS, expected: $EXPECTED_CODE. Response body: $HTTP_BODY"
        exit 1
    fi

    CONFIGMAP_DATA=$(echo $HTTP_BODY | jq ".data")

    if [ "$ACTION" = "CREATE_DATAMAP" ]; then

        function get_env_configmap() {
            echo $CONFIGMAP_DATA | jq -r 'keys[]' | while read key; do
                ENV_NAME=$(echo $key | awk '{ print toupper($1) }' | sed -e 's/[^A-Z0-9_]/_/g')
                ENV_VALUE=$(echo $CONFIGMAP_DATA | jq ".[\"$key\"]")
                echo \"${ENV_NAME}\": "${ENV_VALUE}",
            done
        }

        # we need to rebuild a JSON config data map because we need to convert keys to the ENV_VAR_NAME format
        echo "{" $(get_env_configmap | tr '\n' ' ' | sed 's/,\s$//') "}"

    else
        echo $CONFIGMAP_DATA | jq "{name: \"$CONFIGMAP_SERVICE_NAME\", credentials: .}"
    fi

else
    echo "Action not supported: $ACTION"
    exit 1
fi
