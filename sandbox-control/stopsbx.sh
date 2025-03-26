#!/bin/sh
npx sfcc-ci client:auth -r --selfsigned
npx sfcc-ci sandbox:stop -s $1 --selfsigned