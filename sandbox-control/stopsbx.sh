#!/bin/sh
npx sfcc-ci client:auth -r
npx sfcc-ci sandbox:stop -s $1