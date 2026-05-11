#!/bin/bash
# set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

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

# Assign parameters to readable variable names
product_id="$1"
master_catalog_id="$2"
site_catalog_id="$3"
pricebook_id="$4"
currency="$5"
sale_pricebook_id="$6"

# Trim $1 at the first special character (: or |)
echo -e "\n${CYAN}Processing product IDs:${YELLOW} $product_id${NC}"
dir_name="${product_id%%[:|]*}"

echo -e "\n${CYAN}Creating temporary directory structure in${YELLOW} $TMP_DIR/$dir_name${GRAY}"
mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$master_catalog_id"
mkdir "$TMP_DIR/$dir_name/catalogs/$site_catalog_id"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get products from master catalog
echo -e "\n${CYAN}Getting products from master catalog to${YELLOW} $TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml${GRAY}"
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$master_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$product_id"  imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml"

# get all the variations now that we have picked them, this will save time later
echo -e "\n${CYAN}Extracting variations to${YELLOW} $TMP_DIR/$dir_name/variations.txt${GRAY}"
echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

# skip inventory (sandbox is default in stock)

# real pricing using variations.txt
echo -e "\n${CYAN}Generating real pricing for variations to ${YELLOW}$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml${GRAY}"
cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$pricebook_id" currency="$currency" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml"

# get the sale pricebook if provided
if [ -n "$sale_pricebook_id" ] && [ -f "$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml" ]; then
    echo -e "\n${CYAN}Sale pricebook file exists: ${YELLOW}$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml${GRAY}"
    cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$sale_pricebook_id" currency="$currency" pricebookParentId="$pricebook_id" > "$TMP_DIR/$dir_name/pricebooks/$sale_pricebook_id.xml"
else
    echo -e "\nNo sale pricebook parameter provided or file does not exist."
fi

# site catalog
echo -e "\n${CYAN}Getting products from site catalog to ${YELLOW}$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml${GRAY}"
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml"

# Only process recommendations for club catalogs
if [[ "$master_catalog_id" =~ "club" ]]; then
    echo -e "\n${CYAN}Club recommendations: Processing recommendations for club catalog ${YELLOW}$master_catalog_id${CYAN} and site catalog ${YELLOW}$site_catalog_id${NC}"

    #### Clubs with recommendations handling ####

    # get a subset of the recommendations for the products in our new trimmed catalog
    echo -e "\n${CYAN}Club recommendations: get static rec target products into ${YELLOW}$TMP_DIR/$dir_name/recs-targets.txt${CYAN} from our new trimmed catalog${GRAY}"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs"
    python3 "$SCRIPT_DIR/generate-static-recs.py" \
        --master-catalog "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" \
        --catalog-id "$site_catalog_id" \
        --source-catalog "$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" \
        --output "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs/catalog.xml" \
        --targets-dir "$TMP_DIR/$dir_name" \
        --limit-recs

    # get recommendation target products from master catalog
    echo -e "\n${CYAN}Club recommendations: rec target products master catalog to ${YELLOW}$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml${GRAY}"
    recs_targets=$(cat "$TMP_DIR/$dir_name/recs-targets.txt")
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$master_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$recs_targets" imageBaseUrl="$IMAGE_BASE_URL" > "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml"

    # Merge the main master catalog with the rec targets master catalog
    echo -e "\n${CYAN}Club recommendations: merging main master catalog with rec targets catalog${GRAY}"
    python3 "$SCRIPT_DIR/merge_catalogs.py" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml"

    # Replace the original catalog with the merged one
    mv "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml"

    # Update variations to include all products from the merged catalog
    echo -e "\n${CYAN}Club recommendations: updating variations.txt to include all products from merged catalog${GRAY}"
    echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
    grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

    cat "$TMP_DIR/$dir_name/variations.txt"

    # rec target products real pricing using updated variations.txt (now includes all products)
    echo -e "\n${CYAN}Club recommendations: generating pricing for all products (including rec targets) to ${YELLOW}$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml${GRAY}"
    cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$pricebook_id" currency="$currency" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml"

    # rec target products - site catalog assignments
    echo -e "\n${CYAN}Club recommendations: rec target site catalog to ${YELLOW}$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml${GRAY}"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$recs_targets" > "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml"

    # Merge the main site catalog with the rec targets site catalog
    echo -e "\n${CYAN}Club recommendations: merging main site catalog with rec targets site catalog${GRAY}"
    python3 "$SCRIPT_DIR/merge_catalogs.py" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs/catalog.xml"

    # Replace the original catalog with the merged one
    mv "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml"

    # Clean up temporary recs-targets directories
    rm -rf "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets"
    rm -rf "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets"
    rm -rf "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs"

fi

echo -e "\n${CYAN}See ${YELLOW}$TMP_DIR/$dir_name${CYAN} for the generated files.${NC}"
# node -v
echo -e "\nImporting data into sandbox using b2c-tools..."
b2c-tools import run "$TMP_DIR/$dir_name" --verify false