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

# Check if in a git repository
if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ] then
    echo 'Found source repo: '$(pwd)
else
    echo "::error:: Source repository not found"
    echo "::error:: You can checkout the source repository using a github action in the previous step of this workflow as follow:"
    echo "::error:: actions/checkout@v4"
fi

echo "[+] Git version"
git --version

echo "[+] Enable git lfs"
git lfs install

echo "[+] Pushing to target"
git config --global push.followTags true
git push "$DESTINATION_URL" --set-upstream "$TARGET_BRANCH"
git push "$DESTINATION_URL" --tags
