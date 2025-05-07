#!/bin/bash
set -x

# Load paths from paths.env
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
dir_name=junior-shafts

mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$2"
mkdir "$TMP_DIR/$dir_name/catalogs/$3"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get a single product!
java -jar "$SAXON_JAR" -s:"$TMP_DIR/2025-0416-junior-grip-data/TLST_Clubs_Master_2025-04-17_03-52-59_www.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml"

# skip inventory (sandbox is default in stock)

# pricing!
java -jar "$SAXON_JAR" -s:"$TMP_DIR/2025-0416-junior-grip-data/TLST_Clubs_Master_2025-04-17_03-52-59_www.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-master-products.xslt" productIds="$1" pricebookId="$4" currency="$5" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$4.xml"

# site catalog
java -jar "$SAXON_JAR" -s:"$TMP_DIR/2025-0416-junior-grip-data/titleist-clubs-storefront-US-2025-04-17_03-54-34.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$3/catalog.xml"