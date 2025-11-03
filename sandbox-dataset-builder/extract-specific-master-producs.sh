#!/bin/bash
set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

# $1: product id
# $2: master catalog id

# Validate that 5 command-line parameters are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <product_id> <master_catalog_id>"
    exit 1
fi

# Trim $1 at the first special character (: or |)
dir_name="${1%%[:|]*}"

mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$2"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get products from master catalog
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$2/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$1"  imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml"

# get all the variations now that we have picked them, this will save time later
echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

echo "\nSee $TMP_DIR/$dir_name for the generated files."

npx b2c-tools import run "$TMP_DIR/$dir_name"