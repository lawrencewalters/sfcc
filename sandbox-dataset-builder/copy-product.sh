#!/bin/bash
set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

# $1: product id
# $2: master catalog id
# $3: site catalog id
# $4: pricebook id
# $5: currency

# Validate that 5 command-line parameters are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <product_id> <master_catalog_id> <site_catalog_id> <pricebook_id> <currency>"
    exit 1
fi

# Trim $1 at the first special character (: or |)
dir_name="${1%%[:|]*}"

mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$2"
mkdir "$TMP_DIR/$dir_name/catalogs/$3"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get products from master catalog
java -jar "$SAXON_JAR" -s:"$TMP_DIR/staging/catalogs/$2/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$1"  imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml"

# get all the variations now that we have picked them, this will save time later
echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml" | sort | uniq | paste -sd '|' >> "$TMP_DIR/$dir_name/variations.txt"

# skip inventory (sandbox is default in stock)

# real pricing using variations.txt
# cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/staging/pricebooks/$4.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$4" currency="$5" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$4.xml"

# site catalog
java -jar "$SAXON_JAR" -s:"$TMP_DIR/staging/catalogs/$3/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$3/catalog.xml"

echo ""
echo "See $TMP_DIR/$dir_name for the generated files."