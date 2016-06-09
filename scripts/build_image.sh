#!/bin/bash -e
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

help() {
    echo -e "\nHelp documentation for build_image"
    echo "Script prepares dependencies and build docker image"
    echo "Basic usage: build_image.sh [OPTION] [ARGUMENT]..."
    echo "Parameters -d and -t are required"
    echo "-d | --dockerfile-dir: path to dir with Dockerfile"
    echo "-k | --kerberos-file-name: kerberos package file name"
    echo -e "-t | --tag: tag name in docker format: repository_name:tag\n"
    exit 1
}
#default kerberos package
KERBEROS_FILE_NAME=kerberos-jwt-1.1.tar.gz

while [[ $# > 1 ]]; do
key="$1"
case $key in
    -d|--dockerfile-dir)
    DOCKERFILE_DIR="$2"
    shift # past argument
    ;;
    -k|--kerberos-file-name)
    KERBEROS_FILE_NAME="$2"
    shift # past argument
    ;;
    -t|--tag)
    TAG="$2"
    shift # past argument
    ;;
    *)
    help
    ;;
esac
shift # past argument or value
done

if [ -z "$DOCKERFILE_DIR" ] || [ -z "$TAG" ]; then
    echo "Parameters -d and -t are required"
    help
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp ${SCRIPT_DIR}/../resources/${KERBEROS_FILE_NAME} ${DOCKERFILE_DIR}
docker build -t ${TAG} ${DOCKERFILE_DIR}
rm ${DOCKERFILE_DIR}/${KERBEROS_FILE_NAME}
