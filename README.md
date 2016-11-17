# tap-base-images
Dockerfiles with base images for TAP components

## Building images using Ansible

Prerequisites:
1. Docker.
2. docker-py (`pip install docker-py`).

Run `build.sh` in order to build all TAP base images. Modify `tap_base_images` list in `group_vars/all` file in order to
define specific images to build.

Run `push.sh`  in order to build all TAP base images and push them to Docker registry (by default: `localhost:5001`).
Registry host and port can be defined in `group_vars/all` file.
