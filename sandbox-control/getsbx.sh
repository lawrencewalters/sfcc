#!/bin/sh
npx sfcc-ci client:auth -r --selfsigned
npx sfcc-ci sandbox:get -s $1 --selfsigned