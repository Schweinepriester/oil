#!/usr/bin/env bash
#
# Manage container images for Toil
#
# Usage:
#   soil/images.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

build() {
  local name=${1:-dummy}

  # Uh BuildKit is not the default on Linux!
  # http://jpetazzo.github.io/2021/11/30/docker-build-container-images-antipatterns/
  #
  # It is more parallel and has colored output.
  sudo DOCKER_BUILDKIT=1 \
    docker build --tag oilshell/soil-$name --file soil/$name.Dockerfile .
}

push() {
  local name=${1:-dummy}
  sudo docker push oilshell/soil-$name
}

smoke() {
  ### Smoke test of container
  local name=${1:-dummy}
  sudo docker run oilshell/soil-$name
  sudo docker run oilshell/soil-$name python2 -c 'print("python2")'
}

cmd() {
  ### Run an arbitrary command
  local name=$1
  shift
  sudo docker run oilshell/soil-$name "$@"
}

mount-test() {
  local name=${1:-dummy}

  # mount Oil directory as /app
  sudo docker run \
    --mount "type=bind,source=$PWD/../,target=/app" \
    oilshell/soil-$name sh -c 'ls -l /app'
}

"$@"
