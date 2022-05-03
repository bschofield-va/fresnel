#!/bin/sh
cd $(dirname $0)
. fresnel.env
docker compose exec fresnel bash -l
