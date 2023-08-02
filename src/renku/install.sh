#!/bin/bash -i
set -e

USER_ID=1000
USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}

echo "Activating feature Renku"

source ./library_scripts.sh

ensure_nanolayer nanolayer_location "v0.4.45"

# install git
$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers/features/git:1"

VERSION=${VERSION:-undefined}
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(git ls-remote --tags "https://github.com/swissdatasciencecenter/renku-python" | grep -oP "tags/v\K[0-9]+\.[0-9]+\.[0-9]+$" | sort -rV | head -n 1)
fi
echo "The requested version is: $VERSION"

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
    "ghcr.io/devcontainers/features/git-lfs:1" \
    --option version="3.3.0"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/pipx-package:1" \
    --option package="renku" --option version="$VERSION"

# Determine the appropriate user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
elif ! id -u "${USERNAME}" >/dev/null 2>&1 && [ "$CREATEUSER" = "true" ]; then
    useradd -l -m -s /bin/bash -N -u 1000 "${USERNAME}"
fi

# install jupyter
if [ "${INSTALLJUPYTER}" = "true" ]; then
    /opt/conda/bin/mamba install -y jupyterlab
    ln -sf /opt/conda/bin/jupyter-server /opt/conda/bin/jupyter-notebook
fi
