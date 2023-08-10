#!/bin/bash -i
set -ex

USER_ID=1000
USERNAME=${USERNAME:-${_REMOTE_USER}}

echo "Activating feature Renku"

VERSION=${VERSION:-undefined}
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(git ls-remote --tags "https://github.com/swissdatasciencecenter/renku-python" | grep -oP "tags/v\K[0-9]+\.[0-9]+\.[0-9]$" | sort -rV | head -n 1)
fi
echo "The requested version is: $VERSION"

# create the user if missing
if ! id -u "${USERNAME}" >/dev/null 2>&1 && [ "$CREATEUSER" = "true" ]; then
    useradd -l -m -s /bin/bash -N -u 1000 "${USERNAME}"
fi

# install jupyter
if [ "${INSTALLJUPYTER}" = "true" ]; then
    /opt/conda/bin/mamba install -y jupyterlab
    ln -sf /opt/conda/bin/jupyter-server /opt/conda/bin/jupyter-notebook
fi

pip install pipx
pipx install renku==${VERSION}
