# push-to-release-repo

This github action to push code from a source repo to a release repo. Useful when package distribution requires a separate release repository for running its automated actions. (e.g in case of ROS2 deb packages)

## Inputs

### `destination-username`
**Description:** Username of the destination repository owner.
**Required:** true

### `destination-access-token`
**Description:** Access token for the destination repository. Should be supplied through source repository secrets.
**Required:** false

### `destination-repository`
**Description:** Complete destination repository name in the form (username/repo-name).
**Required:** true

### `git-server`
**Description:** Optional: Git server e.g., github.com or gitlab.com
**Default:** "github.com"
**Required:** false

### `source-branch`
**Description:** Optional: Source repository branch. Defaults to main.
**Default:** "main"
**Required:** false

### `target-branch`
**Description:** Optional: Destination (release) repository branch. Defaults to main.
**Default:** "main"
**Required:** false

## Example Usage

### Example 1: Basic Usage

This example demonstrates a basic usage scenario where you want to push the `main` branch of your source repository to a destination release repository hosted on `github.com`.

```yaml
name: Push to Release Repository

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Source Code
      uses: actions/checkout@v4

    - name: Push to Destination Repository
      uses: automatika-robotics/push-to-release-action@v2
      with:
        destination-username: "destination-user"
        destination-access-token: ${{ secrets.DESTINATION_ACCESS_TOKEN }}
        destination-repository: "destination-user/destination-repo"
```

### Example 2: Pushing a specific source branch to a specific destination branch

This example demonstrates an advanced usage scenario where you want to push a specific branch (`release-candidate`) from your source repository to a different branch (`staging`) in the destination release repository hosted on `gitlab.com`.

```yaml
name: Push Release Candidate to Staging Repository

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Source Code
      uses: actions/checkout@v4

    - name: Push to Destination Repository
      uses: automatika-robotics/push-to-release-action@v2
      with:
        destination-username: "destination-user"
        destination-access-token: ${{ secrets.DESTINATION_ACCESS_TOKEN }}
        destination-repository: "destination-user/destination-repo"
        git-server: "gitlab.com"
        source-branch: "release-candidate"
        target-branch: "staging"
```

### Example 3: Pushing a specific folder from source

This example assumes that you want to push only the contents of a specific folder (`docs/`) from your source repository to a target release repository:

```yaml
name: Push Documentation to Release

on:
  push:
    branches:
      - main

jobs:
  push-to-release:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Source Repository
      uses: actions/checkout@v4

    - name: Push Documentation to Release
      uses: automatika-robotics/push-to-release-action@v2
      with:
        destination-username: 'destination-username'
        destination-access-token: ${{ secrets.DESTINATION_ACCESS_TOKEN }}
        destination-repository: 'username/release-repo'
        source-folder: './docs/'  # Specifies the folder to push
        commit-email: 'destination-username@github.com' # Optional, defaults to destination-username@git-server
        commit-message: 'Push documentation updates to release' # Optional, customizes the commit message
```
