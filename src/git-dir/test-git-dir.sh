#!/bin/bash

# Tests for git-dir orb.
#
# To run, create a .env file with the below variables (no quotes):
#   GITHUB_API_TOKEN=abcd1234
#   DIRECTORY=.circleci
#   GLOB=*.sh
#
# Then copy the CircleCI environment variables from the 'Using build environment variables' block in your job. E.g.:
# BASH_ENV=/tmp/.bash_env-5e012ebafe8b924337b7041c-0-build
# CIRCLE_BRANCH=my-test-branch
# CIRCLE_BUILD_NUM=14428
# ...
#
# To run the tests use:
#   export $(grep -v '^#' .env | xargs -d '\n') >/dev/null && ./test-git-dir.sh

DATA=$(curl -s -H "Authorization: Bearer $GITHUB_API_TOKEN" \
            "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/contents/$DIRECTORY")

echo "$DATA" | jq -c '.[]' | while read  -r file; do
    path=$(echo "$file" | jq -r '.path')
    download_url=$(echo "$file" | jq -r '.download_url')
    echo "Downloading: $path"
    
    curl -s --create-dirs \
        -H "Authorization: Bearer $GITHUB_API_TOKEN" \
        -o "$path" "$download_url"
done


