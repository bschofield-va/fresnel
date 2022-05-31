#!/bin/sh
cd $(dirname $0)
. fresnel.env
fbin/fresnel-commander > $FRESNEL_EXCHANGE_DIR/commander.log &
docker compose exec fresnel bash -l
