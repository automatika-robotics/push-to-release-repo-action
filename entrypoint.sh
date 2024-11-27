#!/bin/sh -l

set -e  # Exit on failure
set -u  # Exit on access to undefined variable

echo "[+] Starting push to release action"
DESTINATION_USERNAME="${1}"
ACCESS_TOKEN="${2}"
DESTINATION_REPOSITORY="${3}"
GIT_SERVER="${4}"
TARGET_BRANCH="${5}"

DESTINATION_URL="https://$DESTINATION_USERNAME:$ACCESS_TOKEN@$GIT_SERVER/$DESTINATION_REPOSITORY.git"

echo "[+] Git version"
git --version

echo "[+] Enable git lfs"
git lfs install

echo "[+] Adds github specific config exception"
git config --global --add safe.directory /github/workspace

echo "[+] Following files exist in current location:"
ls -la

# Check if in a git repository
if [ -d .git ]
then
    echo '[+] Found source repo: '$(pwd)
else
    echo "::error:: Source repository not found"
    echo "::error:: You can checkout the source repository using a github action in the previous step of this workflow as follow:"
    echo "::error:: actions/checkout@v4"
    exit 1
fi

echo "[+] Applying github specific fix to push to external repos"
git config --unset-all http.https://github.com/.extraheader

echo "[+] Pushing to target"
git push --follow-tags $DESTINATION_URL --set-upstream $TARGET_BRANCH
