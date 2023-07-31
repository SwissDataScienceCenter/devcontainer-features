#!/bin/bash -i
set -e
 
NB_UID=1000
NB_USER=jovyan

echo "Activating feature 'renku CLI'"

VERSION=${VERSION:-undefined}
echo "The requested version is: $VERSION"

source ./library_scripts.sh

ensure_nanolayer nanolayer_location "v0.4.45"

# install apt packages
apt-get update --fix-missing && \
    apt-get install -yq --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    gpg-agent \
    gnupg \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    rclone \
    tini \
    wget \
    vim && \
    apt-get purge && \
    apt-get clean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/* && \

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/rocker-org/devcontainer-features/miniforge:1"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers/features/git:1"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers/features/git-lfs:1"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/pipx-package:1" \
    --option package="renku" --option version="$VERSION"

# handle the NB_USER setup
# id -u ${NB_USER} || useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" 