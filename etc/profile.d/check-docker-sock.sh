#!/bin/sh

if [ "$(stat -c %a /var/run/docker.sock)" != 775 ]
then
  echo "Fixing Docker sock permissions..."
  sudo /opt/fresnel/bin/init-docker-sock-permissions
fi
