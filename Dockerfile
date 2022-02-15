# Dockerfile to create an environment that contains the Nix package manager.

FROM alpine

# Enable HTTPS support in wget and set nsswitch.conf to make resolution work within containers
RUN apk add --no-cache --update openssl git \
  && echo hosts: files dns > /etc/nsswitch.conf

# Download Nix and install it into the system.
ARG NIX_VERSION=2.4
RUN wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
  && tar xf nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
  && addgroup -g 30000 -S nixbld \
  && for i in $(seq 1 30); do adduser -S -D -h /var/empty -g "Nix build user $i" -u $((30000 + i)) -G nixbld nixbld$i ; done \
  && mkdir -m 0755 /etc/nix \
  && echo 'sandbox = false' > /etc/nix/nix.conf \
  && mkdir -m 0755 /nix && USER=root sh nix-${NIX_VERSION}-$(uname -m)-linux/install \
  && ln -s /nix/var/nix/profiles/default/etc/profile.d/nix.sh /etc/profile.d/ \
  && rm -r /nix-${NIX_VERSION}-$(uname -m)-linux* \
  && rm -rf /var/cache/apk/* \
  && /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-old \
  && /nix/var/nix/profiles/default/bin/nix-store --optimise \
  && /nix/var/nix/profiles/default/bin/nix-store --verify --check-contents

ONBUILD ENV \
    ENV=/etc/profile \
    USER=root \
    PATH=/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

ENV \
    ENV=/etc/profile \
    USER=root \
    PATH=/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/root/channels

#### ----- everything above copied from https://github.com/NixOS/docker/blob/master/Dockerfile
## with the exception of the nix version update to the latest version

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

# https://nixos.org/manual/nix/unstable/installation/upgrading.html
RUN nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert

RUN nix upgrade-nix

RUN install -d /workspaces /root/.vscode-server/extensions /root/.config /root/.ssh /root/.secrets /workspaces/nix

COPY default.nix      /root/default.nix
COPY entrypoint.sh    /bin/entrypoint.sh
COPY bashrc           /root/.bashrc
COPY nix_sources.json /workspaces/nix/sources.json
COPY nix_sources.nix  /workspaces/nix/sources.nix
COPY workspace.nix    /workspaces/workspace.nix

WORKDIR /workspaces

RUN nix-shell workspace.nix --run "echo 'cache built...'"
