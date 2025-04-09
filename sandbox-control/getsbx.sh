#!/bin/sh
npx sfcc-ci client:auth -r
npx sfcc-ci sandbox:get -s $1