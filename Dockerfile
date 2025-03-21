#
# Base Image:
# - focal
#   - required for JDK 16 packages
# - jammy (latest)
#   - released 2022-04-22
#   - JDK 16 packages not available
#
FROM arm64v8/ubuntu:jammy

RUN apt-get update -y -q
RUN apt-get install -y -q software-properties-common
RUN apt-get install -y -q ca-certificates
RUN yes | unminimize

#
# ZScalar Nonsense
#
COPY <<EOF /bin/z-failer-strikes-again
#!/usr/bin/env bash
echo "Acquire::https::\$1::Verify-Peer \"false\";" > /etc/apt/apt.conf.d/\$1.conf
echo "Acquire::https::\$1::Verify-Host \"false\";" >> /etc/apt/apt.conf.d/\$1.conf
echo "Created /etc/apt/apt.conf.d/\$1.conf"
cat /etc/apt/apt.conf.d/\$1.conf
EOF

COPY certs/ZscalerRootCA.crt /usr/local/share/ca-certificates/

RUN chmod +x /bin/z-failer-strikes-again \
  && update-ca-certificates

#
# Essential packages
#
RUN apt-get install -y gnupg curl


#
# Java
#
RUN <<EOF
curl -kv https://apt.corretto.aws/corretto.key -o /tmp/corretto.key
z-failer-strikes-again apt.corretto.aws
apt-key add /tmp/corretto.key
add-apt-repository -S 'deb https://apt.corretto.aws stable main'
apt-get update -y -q
apt-get install -y java-17-amazon-corretto-jdk
EOF


#
# Docker and kubectl
#
RUN apt-get install -y -q docker docker-compose
RUN <<EOF
RELEASE=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -sL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$RELEASE/bin/linux/arm64/kubectl"
chmod +x /usr/local/bin/kubectl
# Argo Rollouts Kubectl Plugin
curl -sL -o /usr/local/bin/kubectl-argo-rollouts https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-arm64
chmod +x /usr/local/bin/kubectl-argo-rollouts
EOF


#
# Ubuntu doesn't have the latest Emacs, but Kevin Kelley does
# https://launchpad.net/~kelleyk/+archive/ubuntu/emacs
#
RUN z-failer-strikes-again ppa.launchpadcontent.net \
 && add-apt-repository -P ppa:kelleyk/emacs \
 && apt update -y -q \
 && apt-get install -y -q emacs28-nox


#
# X11 support
#
ARG INSTALL_X_TOOLS
RUN if [ "${INSTALL_X_TOOLS:-}" = "true" ]; then apt-get install -y -q xclip kdiff3; fi


#
# Base tools
#
RUN apt-get install -y -q \
  bash-completion \
  bc \
  curl \
  dos2unix \
  gettext-base \
  git \
  git-crypt \
  gpg \
  jq \
  less \
  openssl \
  make \
  man-db \
  ncal \
  sudo \
  tmux \
  tinyproxy \
  unzip \
  vim \
  libxml2-utils \
  zip

# Install talisman
RUN <<EOF
TALISMAN_URL="$(curl -Ls https://api.github.com/repos/thoughtworks/talisman/releases/latest | jq -r '.assets[].browser_download_url | select(contains("talisman_linux_amd64"))')"
curl --silent --insecure --location --output /usr/local/bin/talisman "${TALISMAN_URL}"
chmod +x /usr/local/bin/talisman
EOF


#
# Timezone
#
ARG FRESNEL_TIMEZONE
RUN if [ -n "$FRESNEL_TIMEZONE" ]; then ln -sf /usr/share/zoneinfo/$FRESNEL_TIMEZONE /etc/localtime; fi
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata


#
# YQ
#
RUN <<EOF
PACKAGE=yq_$(uname -sm | sed 's/aarch64/arm64/' | tr [:upper:] [:lower:] | tr ' ' _)
BINARY=/usr/local/bin/yq
curl -fs https://api.github.com/repos/mikefarah/yq/releases/latest \
  | jq '.assets[]|.name + " " + .url' -r \
  | grep -F $PACKAGE \
  | awk '{print $2}' \
  | xargs -t curl -sL -H "Accept: application/octet-stream" -o $BINARY
chmod 755 $BINARY
EOF


#
# GitHub CLI, which must be after base tools
#
RUN <<EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C99B11DEB97541F0
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  > /etc/apt/sources.list.d/github-cli.list
apt update
apt-get install -y -q gh
EOF


#
# AWS CLI
#
ARG AWS_CLI_ARCH=aarch64
ARG AWS_SSM_ARCH=arm64
RUN <<EOF
AWS_INSTALL_DIR=$(mktemp -d)
cd $AWS_INSTALL_DIR
curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
curl -sL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${AWS_SSM_ARCH}/session-manager-plugin.deb" \
  -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
cd /
rm -rf $AWS_INSTALL_DIR
EOF


#
# K9s
#
RUN <<EOF
PACKAGE=k9s_$(uname -sm | sed 's/aarch64/arm64/' | tr [:upper:] [:lower:] | tr ' ' _).tar.gz
BINARY=/usr/local/bin/k9s
curl -s https://api.github.com/repos/derailed/k9s/releases/latest \
  | jq '.assets[]|.name + " " + .url' -r \
  | grep -iF "$PACKAGE " \
  | awk '{print $2}' \
  | xargs -t curl -fsL -H "Accept: application/octet-stream" \
  | tar -xzO k9s > $BINARY
chmod 755 $BINARY
EOF


#
# Dev User
#
ARG FRESNEL_USER_ID

RUN if [ -z "$FRESNEL_USER_ID" ]; then echo "FRESNEL_USER_ID is not defined"; exit 1; fi \
  && useradd -ms /usr/bin/bash -u $FRESNEL_USER_ID dev \
  && echo "dev\ndev" | passwd dev \
  && usermod -aG sudo,docker dev \
  && echo 'dev ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers


#
# Maven
#
ARG MVN_VERSION=3.9.9
RUN <<EOF
curl -sL http://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz \
  | tar -xz -C /opt
ln -s /opt/apache-maven-$MVN_VERSION/bin/mvn /usr/local/bin/mvn
EOF


#
# Because I use the fastest terminal I can find, install Alacritty terminfo.
#
RUN curl -skL https://github.com/alacritty/alacritty/releases/latest/download/alacritty.info -o /tmp/alacritty.info \
 && tic -xe alacritty,alacritty-direct /tmp/alacritty.info \
 && rm /tmp/alacritty.info


#
# Fresnel provided tools and configuration
#
ENV FRESNEL_HOME=/opt/fresnel
ENV PATH=$FRESNEL_HOME/bin:$PATH
COPY etc/ $FRESNEL_HOME/etc
COPY bin/ $FRESNEL_HOME/bin
RUN ln -s $FRESNEL_HOME/bin/open $FRESNEL_HOME/bin/xdg-open \
 && find $FRESNEL_HOME/etc/profile.d/ -type f -exec ln -s {} /etc/profile.d/ \;

#
# SSH support, but sshd is not started by default.
#
#RUN <<EOF
#  apt-get install -y openssh-server
#  mkdir /var/run/sshd
#  sed -i 's/AcceptEnv .*/AcceptEnv no/' /etc/ssh/sshd_config
#  rm /etc/update-motd.d/10-help-text
#  sed -i 's/Welcome to /Welcome to Fresnel: /' /etc/update-motd.d/00-header
#EOF
# CMD exec /bin/bash -xc "sudo /usr/sbin/sshd -D"

CMD [ "/bin/bash", "-c", "echo ok; trap : TERM INT; sleep infinity & wait" ]
