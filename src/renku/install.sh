#!/bin/bash -i
set -e

USER_ID=1000
USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}

echo "Activating feature Renku"

VERSION=${VERSION:-undefined}
if [ "${VERSION}" = "latest" ]; then
    VERSION=$(git ls-remote --tags "https://github.com/swissdatasciencecenter/renku-python" | grep -oP "tags/v\K[0-9]+\.[0-9]+\.[0-9]+$" | sort -rV | head -n 1)
fi
echo "The requested version is: $VERSION"

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

/usr/local/py-utils/bin/pipx install --from-spec "renku==${VERSION}"
