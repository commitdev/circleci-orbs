#!/bin/bash

# Checks if your orb has changes and needs to be rebuilt.

ORB_NAME=$1

if [ "$ORB_NAME" == "" ]; then
    echo "Usage: ./check-orbs.sh <orb name>"
    exit 1
fi

ORBS=$(git --no-pager diff --name-only --relative="src/" HEAD^ HEAD | \
    grep -E '^commitdev\/(.*)\/orb\.yml$' | \
    cut -d / -f 2)

for orb in $ORBS
do
    if [ "$orb" == "$ORB_NAME" ]; then
        echo "true"
        exit 0
    fi
done

echo "No changes found for orb: $ORB_NAME"
