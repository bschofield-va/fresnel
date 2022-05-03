#!/bin/sh

if [ "$(stat -c %a /var/run/docker.sock)" != 775 ]
then
  echo "Docker sock permissions are restrictive and will require sudo."
  echo "To relax this requirement, execute: "
  echo "sudo /opt/fresnel/bin/init-docker-sock-permissions"
fi
