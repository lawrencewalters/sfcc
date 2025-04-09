#!/bin/sh
npx sfcc-ci client:auth -r
npx sfcc-ci sandbox:start -s $1