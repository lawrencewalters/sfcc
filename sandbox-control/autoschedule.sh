#!/bin/sh
set -x  # Enable command tracing
sfcc-ci client:auth -r
sfcc-ci sandbox:update --sandbox $1 --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"07:00:00-05:00"}' --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"19:00:00-05:00"}'
# this directly runs our patched sfcc-ci
# node ../../sfcc-ci/cli.js sandbox:update --sandbox $1 --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"07:00:00-05:00"}' --stop-scheduler '{"weekdays":["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY"],"time":"19:00:00-05:00"}'