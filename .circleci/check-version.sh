#!/bin/bash

# Checks if your orb has a new version number or if it's a duplicate of the latest.

ORB_REF=$1
ORB_DATA=$(circleci orb info "$ORB_REF" &>/dev/null || echo "Not found")
LATEST=$( echo "$ORB_DATA" | grep -E 'Latest: .*@([0-9.]+)' | cut -d @ -f 2 )

if [ "$(cat version.txt)" == "$LATEST" ]; then
    echo "Error: Version is the same as published. Please update version.txt"
    exit 1
fi