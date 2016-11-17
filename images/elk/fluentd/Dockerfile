# based on https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Dockerfile
FROM gcr.io/google_containers/ubuntu-slim:0.4
MAINTAINER rafal.radecki@intel.com
RUN ulimit -n 65536
ENV DEBIAN_FRONTEND noninteractive
COPY td-agent.conf /etc/td-agent/td-agent.conf
COPY build.sh /tmp/build.sh
RUN chmod 777 /tmp/build.sh
RUN /tmp/build.sh
ENTRYPOINT ["td-agent"]
