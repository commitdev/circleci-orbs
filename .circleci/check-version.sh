#!/bin/bash

# Checks if your orb has a new version number or if it's a duplicate of the latest.
ORB_REF=$1

ORB_DATA=$(circleci orb info "$ORB_REF" 2>/dev/null || circleci orb create "$ORB_REF")
LATEST=$( echo "$ORB_DATA" | grep -E 'Latest: .*@([0-9.]+)' | cut -d @ -f 2 )
VERSION=$(cat "src/$ORB_REF/version.txt")

if [ "$VERSION" == "$LATEST" ]; then
    echo "Version is the same as published. Please update version.txt if you need to publish this orb."
    exit 0
fi

echo "updated"
