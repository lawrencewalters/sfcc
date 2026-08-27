#!/bin/bash

# this is a local change for publishing quickly to sandboxes, so let's reset it
git restore  gulp_builder/config.json

git checkout develop/acushnet

if [[ -n $(git status --porcelain) ]]; then
    echo "Uncommitted changes detected. Please commit or stash before pulling."
    exit 1
fi

git pull --prune

# git checkout -b $1

git checkout "$1" 2>/dev/null || git checkout -b "$1"