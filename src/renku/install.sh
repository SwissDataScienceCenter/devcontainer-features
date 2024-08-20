#!/bin/bash -i
set -ex

USER_ID=1000
USERNAME=${USERNAME:-${_REMOTE_USER}}

# create the user if missing
if ! id -u "${USERNAME}" >/dev/null 2>&1 && [ "$CREATEUSER" = "true" ]; then
    useradd -l -m -s /bin/bash -N -u 1000 "${USERNAME}"
fi

# install jupyter
if [ "${INSTALLJUPYTER}" = "true" ]; then
    /opt/conda/bin/mamba install -y jupyterlab
    ln -sf /opt/conda/bin/jupyter-server /opt/conda/bin/jupyter-notebook
fi

# install the renku CLI
curl -sfSL https://raw.githubusercontent.com/SwissDataScienceCenter/renku-cli/main/install.sh | bash -s -- -t nightly

chown -R ${USERNAME} /usr/local/py-utils
