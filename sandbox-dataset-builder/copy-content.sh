#!/bin/bash -ex

# copy a list of content assets and upload to sandbox

source "$(dirname "$0")/paths.env"

# $1: content ids (separated by |)
# $2: content library id

# Validate that 1 command-line parameters are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <content_ids> <content_library_id>"
    exit 1
fi

# Trim $1 at the first special character (: or |)
dir_name="${1%%[:|]*}"

mkdir -p "$TMP_DIR/$dir_name"
mkdir -p "$TMP_DIR/$dir_name/libraries"
mkdir -p "$TMP_DIR/$dir_name/libraries/$2"



# generate trimmed library
    # input: staging library.xml, file with list of contentIds to retrieve
    # output: trimmed content library

java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/libraries/$2/library.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-content-library.xslt" contentIds="$1" > "$TMP_DIR/$dir_name/libraries/$2/library.xml"

npx b2c-tools import run "$TMP_DIR/$dir_name"