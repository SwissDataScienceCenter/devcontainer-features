#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "renku is available" bash -c "renku --help"
check "git-lfs is available" bash -c "git lfs --help"
check "conda is available" bash -c "conda --version"
check "/opt/conda/bin is on PATH" bash -c "grep -q '/opt/conda/bin' <<< '$PATH'"
check "jupyter notebook works" bash -c "jupyter notebook --help"

# check that the user is indeed jovyan
check "user is randomUser" bash -c "whoami | grep randomUser"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
