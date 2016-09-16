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

if [ "$EXPECTED_CODE" = "" ]; then
    echo "EXPECTED_CODE env can not be found!"
    exit 1
elif [ "$URL" = "" ]; then
    echo "URL env can not be found!"
    exit 1
elif [ "$BROKER_SERVICE_NAME" = "" ]; then
    echo "BROKER_SERVICE_NAME env can not be found!"
    exit 1
fi

BROKER_SERVICE_NAME=$(echo $BROKER_SERVICE_NAME | sed 's/-/_/g')

host=${BROKER_SERVICE_NAME}_SERVICE_HOST
host=${host^^}
if [ "${!host}" = "" ]; then
    echo "${host} env can not be found!"
    exit 1
fi

port=${BROKER_SERVICE_NAME}_SERVICE_PORT
port=${port^^}
if [ "${!port}" = "" ]; then
    echo "${port} env can not be found!"
    exit 1
fi

ADDRESS="${!host}:${!port}"

CREDS=""
if [ "$BROKER_USERNAME" != "" ]; then
    CREDS="--user $BROKER_USERNAME:$BROKER_PASSWORD"
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
    echo "Bas response status! Code: $HTTP_STATUS Response: $HTTP_BODY"
    exit 1
fi

echo $HTTP_BODY