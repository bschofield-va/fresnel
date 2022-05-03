#
# Base Image:
# - focal
#   - required for JDK 16 packages
# - jammy (latest)
#   - released 2022-04-22
#   - JDK 16 packages not available
#
FROM arm64v8/ubuntu:focal

RUN apt-get update -y -q
RUN yes | unminimize

#
# Heavy downloads
#

RUN apt search openjdk-16

RUN apt-get install -y -q openjdk-16-jdk-headless
env JAVA_HOME=/usr/lib/jvm/java-16-openjdk-arm64

RUN apt-get install -y -q docker docker-compose

#
# Base tools
#
RUN apt-get install -y -q \
  bash-completion \
  curl \
  dos2unix \
  emacs-nox \
  git \
  git-crypt \
  gpg \
  jq \
  less \
  openssl \
  man-db \
  sudo \
  unzip \
  vim \
  zip

#
# GitHub CLI, which must be after base tools
#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C99B11DEB97541F0 \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update \
  && apt-get install -y -q gh


#
# AWS CLI
#
ARG AWS_CLI_ARCH=aarch64
ARG AWS_SSM_ARCH=arm64
RUN AWS_INSTALL_DIR=$(mktemp -d) \
  && cd $AWS_INSTALL_DIR \
  && curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && curl -sL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${AWS_SSM_ARCH}/session-manager-plugin.deb" -o "session-manager-plugin.deb" \
  && dpkg -i session-manager-plugin.deb \
  && cd / \
  && rm -rf $AWS_INSTALL_DIR


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
ARG MVN_VERSION=3.8.5
RUN curl -sL \
     http://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz \
     | tar -xz -C /opt \
  && ln -s /opt/apache-maven-$MVN_VERSION/bin/mvn /usr/local/bin/mvn


#
# X11 support
#
ARG INSTALL_X_TOOLS
RUN test "${INSTALL_X_TOOLS:-}" = "true" \
  && apt-get install -y -q \
  xclip \
  kdiff3


#
# Fresnel provided tools and configuration
#
env FRESNEL_HOME=/opt/fresnel
env PATH=$FRESNEL_HOME/bin:$PATH
COPY etc/ $FRESNEL_HOME/etc
COPY bin/ $FRESNEL_HOME/bin
RUN ln -s $FRESNEL_HOME/bin/open $FRESNEL_HOME/bin/xdg-open \
 && ln -s $FRESNEL_HOME/etc/profile.d/check-docker-sock.sh /etc/profile.d/


CMD exec /bin/bash -c "echo ok; trap : TERM INT; sleep infinity & wait"