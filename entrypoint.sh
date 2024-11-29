#!/bin/sh -l

set -e  # Exit on failure
set -u  # Exit on access to undefined variable

echo "[+] Starting push to release action"
DESTINATION_USERNAME="${1}"
ACCESS_TOKEN="${2}"
DESTINATION_REPOSITORY="${3}"
GIT_SERVER="${4}"
TARGET_BRANCH="${5}"
SOURCE_FOLDER=${6}
COMMIT_EMAIL="${7:-$DESTINATION_USERNAME@$GIT_SERVER}"
COMMIT_MESSAGE="${8}"

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


# Check if source folder exists in repo
if [ -d $SOURCE_FOLDER ]
then
    echo '[+] Found source folder: '$SOURCE_FOLDER
else
    echo "::error:: Source folder not found in the repository"
    echo "::error:: Make sure you have checked out the correct branch of the source repository using the checkout action as follows:"
    echo "::error:: actions/checkout@v4"
    echo "::error:: with:"
    echo "::error::   ref: branch-name"
    exit 1
fi

echo "[+] Applying github specific fix to push to external repos"
git config --unset-all http.https://github.com/.extraheader

if [ "$SOURCE_FOLDER" != "./" ]
then
    # Clone the destination repository into a temporary directory
    CLONE_DIR=$(mktemp -d)
    echo "[+] Cloning destination repo to: $CLONE_DIR"
    git clone $DESTINATION_URL $CLONE_DIR

    # Remove the target folder in the cloned repository if it exists
    rm -rf "$CLONE_DIR/$SOURCE_FOLDER"

    # Copy the source folder into the cloned repository
    cp -r "$SOURCE_FOLDER" "$CLONE_DIR/"

    echo "[+] Copied source folder to destination repo."

    # Navigate to the cloned directory
    cd $CLONE_DIR

    # Setup git user and email for commit
    git config user.name "$DESTINATION_USERNAME"
    git config user.email "$COMMIT_EMAIL"

    # Add changes and commit
    echo "[+] Committing changes to destination repo."
    git add .
    git commit -m "${COMMIT_MESSAGE}"

    # Push changes to the target branch
    git push origin --set-upstream $TARGET_BRANCH
    echo "[+] Pushed changes to: $DESTINATION_URL on branch: $TARGET_BRANCH"

else
    echo "[+] Pushing to target"
    git push --no-thin --follow-tags $DESTINATION_URL --set-upstream $TARGET_BRANCH
fi
