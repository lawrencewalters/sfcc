#!/bin/sh
set -x  # Enable command tracing
# $1: sandbox id like aazw-011
# $2: start time in EST, 2 digits, 24h format
# $3: stop time in EST, 2 digits, 24h format

# Validate that 3 command-line parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <sandbox> <start_hour> <stop_hour>"
    exit 1
fi
sfcc-ci client:auth -r
sfcc-ci sandbox:update --sandbox $1 --start-scheduler "{\"weekdays\":[\"MONDAY\",\"TUESDAY\",\"WEDNESDAY\",\"THURSDAY\",\"FRIDAY\"],\"time\":\"$2:00:00-05:00\"}" --stop-scheduler "{\"weekdays\":[\"MONDAY\",\"TUESDAY\",\"WEDNESDAY\",\"THURSDAY\",\"FRIDAY\"],\"time\":\"$3:00:00-05:00\"}"
# this directly runs our patched sfcc-ci
# node ../../sfcc-ci/cli.js sandbox:update --sandbox $1 --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"07:00:00-05:00"}' --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"19:00:00-05:00"}'