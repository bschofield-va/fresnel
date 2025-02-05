#!/bin/sh
cd $(dirname $0)
. fresnel.conf
export DOCKER_CLI_HINTS=false
docker exec -it $FRESNEL_SESSION_ID bash -l $@
