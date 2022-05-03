# Fresnel

## Create
Provision (or reprovision) an environment
```
fresnel-start
```

## Use
Establish a session
```
fsh
```

## What's in the box?
- User `dev` linked to your Mac user ID to keep file permissions sane.
- `dev` password is `dev` (you shouldn't need it).
- Passwordless `sudo` capability.
- Host of utilities include Java, Maven, Git. See [fresnel.Dockerfile](fresnel.Dockerfile).
- Maven configuration for Lighthouse projects.
- Docker-in-docker support

### Special locations

| Fresnel       |  Real World        | Why |
|---------------|--------------------|-----|
| `/home/dev`   | `~/.fresnel/home`  | Allow you Fresnel home to be separate from your host OS, but still be shared across sessions. |
| `/va`         | `~/va`             | Allow source code to be shared with IDEs. |
| `/repository` | `~/.m2/repository` | ALlow Maven repository to be shared with IDEs. |


## Initialization
Additional initialization steps are required.
Utilities require certain environment variables and will complain if not set.

### `init-maven-settings`

Initialization variables
- `MVN_MASTER_PASSWORD` -(optional) - Used to encrypt Maven passwords
- `HEALTH_APIS_RELEASES_NEXUS_USERNAME` - User name for the Health APIs Nexus server
- `HEALTH_APIS_RELEASES_NEXUS_PASSWORD` - Password for the Health APIs Nexus server
- `GITHUB_USERNAME` - User name for GitHub Packages access
- `GITHUB_TOKEN` - GitHub access token to use for accessing GitHub packages


### `init-docker-sock-permissions`

Docker is available in Fresnel and can be used as is with `sudo`, e.g., `sudo docker ps -a`.
If you wish to use Docker without `sudo`, you can run this script to alter the Docker sock permissions on Mac hosts.

> NOTE: Restarting Docker Desktop will reset the Docker sock permissions and this script will need to be ran again.


## Performance
Performance is significantly improved by enabling Docker Desktop experimental features:
- Use the new Virtualization framework
- Enable VirtioFS accelerated directory sharing


## X Support
To gain access to X applications, like `kdiff3`.
- Install XQuartz
- Open XQuartz `>` Preferences `>` Security
  - Enable _Allow connections from network clients_
- When starting the Fresnel environment, if `xhost` is detected, the `localhost` will be granted access to X.

When X support is available, Fresnel provides mimics of `pbcopy` and `pbpaste` that take advantage of XQuartz clipboard support.


## Rough Edges, Annoying, or Completely Borked

- X support twins `pbcopy` and `pbpaste` will sometimes report an error until something has grabbed focus in X at least once.

- Sometimes shared GitHub repositories get confused and complain about the owner and suggest to mark it "safe".

- Sometimes Git gets weird and fails to commit changes. Retrying the command seems to work. _why!_
```
$ git commit -m .
fatal: loose object e9ec708332a9f3ef48a0bfc2cf9b67a5dda29915 (stored in .git/objects/e9/ec708332a9f3ef48a0bfc2cf9b67a5dda29915) is corrupt
$ git commit -m .
fatal: loose object e9ec708332a9f3ef48a0bfc2cf9b67a5dda29915 (stored in .git/objects/e9/ec708332a9f3ef48a0bfc2cf9b67a5dda29915) is corrupt
$ git commt -m .
[master d2aac3c] .
 2 files changed, 101 insertions(+)
 create mode 100755 .config/kdiff3rc
```

#### The Bottom Line
This environment is not and never will be as smooth and awesome as your native environment _could_ be.
But, it is relatively fast and easy to set up and works consistently across users.
It can also help keep your environment current to a psuedo-standard.
