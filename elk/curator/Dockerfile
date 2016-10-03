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

FROM tapimages.us.enableiot.com:8080/tap-base-python:python2.7-jessie
MAINTAINER mariusz.klonowski@intel.com

RUN mkdir /build
COPY requirements.txt /build/requirements.txt
COPY vendor /build/vendor
COPY curator.yml /curator.yml
COPY delete_indices.yml /delete_indices.yml
COPY loop.sh /loop.sh

RUN pip install --no-index --find-links=/build/vendor -r /build/requirements.txt \
    && rm -rf /build

ENTRYPOINT [ "/usr/local/bin/curator" ]
CMD ["--config", "/curator.yml", "/delete_indices.yml"]
