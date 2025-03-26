#!/bin/sh
npx sfcc-ci client:auth -r --selfsigned
npx sfcc-ci sandbox:start -s $1 --selfsigned