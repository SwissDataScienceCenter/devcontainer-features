#!/bin/bash -i
set -ex

USER_ID=1000
USERNAME=${USERNAME:-${_REMOTE_USER}}

echo "Activating feature Renku"

VERSION=${VERSION:-"latest"}
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(curl -s https://pypi.org/pypi/renku/json | jq '.releases | keys | sort | .[]'  | grep -oP "\"[0-9]+\.[0-9]+\.[0-9]\"" | tr -d '"' | sort -rV | head -n 1)
fi
echo "The requested version is: $VERSION"

# create the user if missing
if ! id -u "${USERNAME}" >/dev/null 2>&1 && [ "$CREATEUSER" = "true" ] && ! getent passwd 1000 ; then
    useradd -l -m -s /bin/bash -N -u 1000 "${USERNAME}"
fi

# install jupyter
if [ "${INSTALLJUPYTER}" = "true" ]; then
    /opt/conda/bin/mamba install -y jupyterlab jupyter-server-proxy
    ln -sf /opt/conda/bin/jupyter-server /opt/conda/bin/jupyter-notebook
fi

/usr/local/py-utils/bin/pipx install renku==${VERSION}

chown -R ${USERNAME} /usr/local/py-utils
