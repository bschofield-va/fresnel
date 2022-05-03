Start a Java server attached to Unix domain (file) socket on host.
The socket can then be mounted as a docker volume (like docker.sock)
Java client in container to talk to the mounted sock.
This can be used to send command out of the container on to the host.