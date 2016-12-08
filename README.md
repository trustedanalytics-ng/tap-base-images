# tap-base-images
Dockerfiles with base images for TAP components

## Adding a new base image
1. Create a new directory for your image in `images` directory (e.g. `mkdir ./images/my_image`).
2. Place `Dockerfile`, `build.sh` script and all other required files in your image directory.
3. Add a new entry to `tap_base_images` list in `group_vars/all` file (e.g. `- { name: "my_image", tag: "my_tag", path: "/images/my_image"`).

## Building images using Ansible

Prerequisites:
1. Docker.
2. docker-py (`pip install docker-py`).

Run `build.sh` in order to build all TAP base images. Modify `tap_base_images` list in `group_vars/all` file in order to
define specific images to build.

Run `tag.sh`  in order to build all TAP base images and tag them with `tapimages:8080` prefix, so thay can be used during
build of TAP compoments.
Registry host and port can be defined in `group_vars/all` file.

## Images 

### Base images used for TAP applications

* [Binary image based on debian:jesse](/images/binary/binary-jessie)
* [Python 2.7 image based on python:2.7.11-slim](/images/python/python2.7-jessie)
* [Python 3.4 image based on python:3.4.5-slim](/images/python/python3.4)
* [NodeJS image based on node:4.4.5-slim](/images/nodejs/node4.4-jessie)
* [Java image based on java:openjdk-8u91-jre](/images/java/java8-jessie)

### Images used in core TAP

* [cf broker connector for porting cloud foundry](/images/cf-broker-connector)
* [Elastic Search, Kibana, FluentD](/images/elk)
* [Nginx with SSL](/images/nginx-ssl)
