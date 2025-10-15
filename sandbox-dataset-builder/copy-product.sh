#!/bin/bash
# set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

# $1: product id
# $2: master catalog id
# $3: site catalog id
# $4: pricebook id
# $5: currency
# $6: sale pricebook id (optional)

# Validate that 5 command-line parameters are provided
if [ "$#" -lt 5 ]; then
    echo "Usage: $0 <product_id> <master_catalog_id> <site_catalog_id> <pricebook_id> <currency> [<sale_pricebook_id>]"
    exit 1
fi

# Trim $1 at the first special character (: or |)
echo -e "\nProcessing product IDs: $1"
dir_name="${1%%[:|]*}"

echo -e "\nCreating temporary directory structure in $TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$2"
mkdir "$TMP_DIR/$dir_name/catalogs/$3"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get products from master catalog
echo -e "\nGetting products from master catalog to $TMP_DIR/$dir_name/catalogs/$2/catalog.xml"
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$2/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$1"  imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml"

# get all the variations now that we have picked them, this will save time later
echo -e "\nExtracting variations to $TMP_DIR/$dir_name/variations.txt"
echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

# skip inventory (sandbox is default in stock)

# real pricing using variations.txt
echo -e "\nGenerating real pricing for variations to $TMP_DIR/$dir_name/pricebooks/$4.xml"
cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$4.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$4" currency="$5" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$4.xml"

# get the sale pricebook if provided
if [ -n "$6" ] && [ -f "$TMP_DIR/$SOURCE_DIR/pricebooks/$6.xml" ]; then
    echo -e "\nSale pricebook file exists: $TMP_DIR/$SOURCE_DIR/pricebooks/$6.xml"
    cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$6.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$6" currency="$6" pricebookParentId="$4" > "$TMP_DIR/$dir_name/pricebooks/$6.xml"
else
    echo -e "\nNo sale pricebook parameter provided or file does not exist."
fi

# site catalog
echo -e "\nGetting products from site catalog to $TMP_DIR/$dir_name/catalogs/$3/catalog.xml"
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$3/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$3/catalog.xml"

# Only process recommendations for club catalogs
if [[ "$2" =~ "club" ]]; then
    echo -e "\nProcessing recommendations for club catalog $2 and site catalog $3"
    #### Clubs with recommendations handling ####
    # get a subset of the recommendations for the products in our new trimmed catalog
    echo -e "\n   get static rec target products into $TMP_DIR/$dir_name/recs-targets.txt from our new trimmed catalog"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$3-recs"
    python3 "$SCRIPT_DIR/generate-static-recs.py" "$TMP_DIR/$dir_name/catalogs/$2/catalog.xml" "$3" "$TMP_DIR/$SOURCE_DIR/catalogs/$3/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$3-recs/catalog.xml" "true" "$TMP_DIR/$dir_name"

    # get recommendation target products from master catalog
    echo -e "\n   rec target products master catalog to $TMP_DIR/$dir_name/catalogs/$2-recs-targets/catalog.xml"
    recs_targets=$(cat "$TMP_DIR/$dir_name/recs-targets.txt")
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$2-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$2/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$recs_targets" imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$2-recs-targets/catalog.xml"

    # rec targets - VARIATIONS - now that we have picked them, this will save time later
    echo -n "productIds=" > "$TMP_DIR/$dir_name/recs-targets-variations.txt"
    grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$2-recs-targets/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/recs-targets-variations.txt"

    # rec target products real pricing using recs-targets-variations.txt
    echo -e "\n   rec target products pricing to $TMP_DIR/$dir_name/pricebooks/$4-recs-targets.xml"
    cat "$TMP_DIR/$dir_name/recs-targets-variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$4.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$4" currency="$5" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$4-recs-targets.xml"

    # rec target products - site catalog assignments
    echo -e "\n   rec target site catalog to $TMP_DIR/$dir_name/catalogs/$3-recs-targets/catalog.xml"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$3-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$3/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$recs_targets" > "$TMP_DIR/$dir_name/catalogs/$3-recs-targets/catalog.xml"
fi

echo -e "\nSee $TMP_DIR/$dir_name for the generated files."
# node -v
echo -e "\nImporting data into sandbox using b2c-tools..."
b2c-tools import run "$TMP_DIR/$dir_name" --verify false