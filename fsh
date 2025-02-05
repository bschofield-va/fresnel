#!/bin/sh
cd $(dirname $0)
. fresnel.conf
: ${FRESNEL_SESSION_ID:=fresnel}
export DOCKER_CLI_HINTS=false
docker exec -it $FRESNEL_SESSION_ID bash -l $@
