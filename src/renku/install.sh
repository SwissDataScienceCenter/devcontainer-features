#!/bin/bash -i
set -e

echo "Activating feature 'renku CLI'"

VERSION=${VERSION:-undefined}
echo "The requested version is: $VERSION"

source ./library_scripts.sh

ensure_nanolayer nanolayer_location "v0.4.45"

$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-contrib/features/pipx-package:1" \
    --option package="renku" --option version="$VERSION"
    
    