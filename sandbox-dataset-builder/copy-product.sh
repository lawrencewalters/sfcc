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

# Simplified mode:
# $1: product id
# $2: site id (e.g. kjus)
#
# Legacy mode:
# $1: product id
# $2: master catalog id
# $3: site catalog id
# $4: pricebook id
# $5: currency
# $6: sale pricebook id (optional)

print_usage() {
    echo "Usage (site-based): $0 <product_id> <site_id>"
    echo "Usage (legacy):    $0 <product_id> <master_catalog_id> <site_catalog_id> <pricebook_id> <currency> [<sale_pricebook_id>]"
}

resolve_site_config() {
    local site_id="$1"

    case "$site_id" in
        kjus)
            master_catalog_id="kjus-master-akeneo"
            site_catalog_id="kjus-us-storefront"
            pricebook_id="kjus-usd-list-prices"
            currency="USD"
            sale_pricebook_id="kjus-usd-sale-prices"
            image_base_url="development-na.kjus.com/dw/image/v2/AAZW_DEV"
            ;;
        vokey)
            master_catalog_id="vokey-master"
            site_catalog_id="vokey-site"
            pricebook_id="vokey-retail-usd"
            currency="USD"
            sale_pricebook_id=""
            image_base_url="development-na.vokey.com/dw/image/v2/AAZW_DEV"
            ;;
        links-and-kings)
            master_catalog_id="links-kings-master"
            site_catalog_id="links-and-kings-storefront"
            pricebook_id="lnk-usd-list-prices"
            currency="USD"
            sale_pricebook_id=""
            image_base_url="development-na.linksandkings.com/dw/image/v2/AAZW_DEV"
            ;;
        footjoy)
            master_catalog_id="footjoy-master"
            site_catalog_id="footjoy-storefront"
            pricebook_id="usd-list-prices"
            currency="USD"
            sale_pricebook_id=""
            image_base_url="development-na.footjoy.com/dw/image/v2/AAZW_DEV"
            ;;
        footjoy-ca)
            master_catalog_id="footjoy-master"
            site_catalog_id="footjoy-storefront-ca"
            pricebook_id="cad-list-prices"
            currency="CAD"
            sale_pricebook_id=""
            image_base_url="development-na.footjoy.ca/dw/image/v2/AAZW_DEV"
            ;;
        footjoy-kr)
            master_catalog_id="footjoy-master"
            site_catalog_id="footjoy-storefront-kr"
            pricebook_id="krw-list-prices"
            currency="KRW"
            sale_pricebook_id=""
            image_base_url="development-na.footjoy.kr/dw/image/v2/AAZW_DEV"
            ;;
        titleist-clubs-ca)
            master_catalog_id="titleist-clubs-master"
            site_catalog_id="titleist-storefront-CA"
            pricebook_id="titleist-clubs-prices-CAD"
            currency="CAD"
            sale_pricebook_id=""
            image_base_url="development-na.titleist.ca/dw/image/v2/AAZW_DEV"
            ;;
        titleist-clubs)
            master_catalog_id="titleist-clubs-master"
            site_catalog_id="titleist-storefront"
            pricebook_id="titleist-clubs-prices"
            currency="USD"
            sale_pricebook_id=""
            image_base_url="development-na.titleist.com/dw/image/v2/AAZW_DEV"
            ;;
        titleist)
            master_catalog_id="titleist-master"
            site_catalog_id="titleist-storefront"
            pricebook_id="usd-titleist-list"
            currency="USD"
            sale_pricebook_id="usd-titleist-sale"
            image_base_url="development-na.titleist.com/dw/image/v2/AAZW_DEV"
            ;;
        clubglove)
            master_catalog_id="clubglove-master"
            site_catalog_id="clubglove-storefront"
            pricebook_id="clubglove-usd-list-prices"
            currency="USD"
            sale_pricebook_id=""
            image_base_url="development-na.clubglove.com/dw/image/v2/AAZW_DEV"
            ;;
        *)
            echo -e "\n${RED}Error: Unknown site id '${YELLOW}$site_id${RED}'.${NC}"
            print_usage
            exit 1
            ;;
    esac
}

# Validate command-line parameters for either invocation style
if [ "$#" -lt 2 ]; then
    print_usage
    exit 1
fi

require_file() {
    local file_path="$1"
    local label="$2"

    if [ ! -f "$file_path" ]; then
        echo -e "\n${RED}Error: ${label} file not found at ${YELLOW}$file_path${NC}"
        exit 1
    fi
}

# Assign parameters to readable variable names
product_id="$1"

if [ "$#" -eq 2 ]; then
    # Site-based mode
    echo -e "\n${CYAN}getting config for site:${YELLOW} $2${NC}"
    resolve_site_config "$2"
elif [ "$#" -ge 5 ]; then
    # Legacy mode
    master_catalog_id="$2"
    site_catalog_id="$3"
    pricebook_id="$4"
    currency="$5"
    sale_pricebook_id="$6"
    image_base_url="development-na.titleist.com/dw/image/v2/AAZW_DEV"
else
    print_usage
    exit 1
fi

echo -e "\t${CYAN}master catalog:               ${YELLOW}$master_catalog_id${NC}"
echo -e "\t${CYAN}site catalog:                 ${YELLOW}$site_catalog_id${NC}"
echo -e "\t${CYAN}pricebook:                    ${YELLOW}$pricebook_id${NC}"
echo -e "\t${CYAN}currency:                     ${YELLOW}$currency${NC}"
echo -e "\t${CYAN}sale pricebook:               ${YELLOW}$sale_pricebook_id${NC}"
echo -e "\t${CYAN}image base URL:               ${YELLOW}$image_base_url${NC}"

# Trim $1 at the first special character (: or |)
echo -e "\t${CYAN}Processing product IDs:      ${YELLOW} $product_id${NC}"
dir_name="${product_id%%[:|]*}"

echo -e "\t${CYAN}Creating temp directories:   ${YELLOW} $TMP_DIR/$dir_name${GRAY}"
mkdir "$TMP_DIR/$dir_name"
mkdir "$TMP_DIR/$dir_name/catalogs"
mkdir "$TMP_DIR/$dir_name/catalogs/$master_catalog_id"
mkdir "$TMP_DIR/$dir_name/catalogs/$site_catalog_id"
mkdir "$TMP_DIR/$dir_name/pricebooks"

# get products from master catalog

master_catalog_file="$TMP_DIR/$SOURCE_DIR/catalogs/$master_catalog_id/catalog.xml"
require_file "$master_catalog_file" "Master catalog"
echo -e "\t${CYAN}Clean invalid xml:            ${YELLOW}$master_catalog_file${NC}"
"$SCRIPT_DIR/remove-unneeded-xml-snippets.sh" "$master_catalog_file"

echo -e "\t${CYAN}master products ->            ${YELLOW}$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml${GRAY}"
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$master_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$product_id"  imageBaseUrl="$image_base_url" > "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml"

# get all the variations now that we have picked them, this will save time later
echo -e "\t${CYAN}Extracting variations to      ${YELLOW}$TMP_DIR/$dir_name/variations.txt${GRAY}"
echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

# skip inventory (sandbox is default in stock)

# real pricing using variations.txt
echo -e "\t${CYAN}real pricing for variations   ${YELLOW}$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml${GRAY}"
source_pricebook_file="$TMP_DIR/$SOURCE_DIR/pricebooks/$pricebook_id.xml"
if [ ! -f "$source_pricebook_file" ]; then
    echo -e "\n${RED}Error: Pricebook file not found at ${YELLOW}$source_pricebook_file${NC}"
    exit 1
fi
cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$pricebook_id" currency="$currency" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml"

# get the sale pricebook if provided
if [ -n "$sale_pricebook_id" ] && [ -f "$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml" ]; then
    echo -e "\t${CYAN}real sale prices ->       ${YELLOW}$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml${GRAY}"
    cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$sale_pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$sale_pricebook_id" currency="$currency" pricebookParentId="$pricebook_id" > "$TMP_DIR/$dir_name/pricebooks/$sale_pricebook_id.xml"
else
    echo -e "\t${CYAN}No sale price param or no file.${NC}"
fi

# site catalog
echo -e "\t${CYAN}products from site catalog -> ${YELLOW}$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml${GRAY}"
site_catalog_file="$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml"
if [ ! -f "$site_catalog_file" ]; then
    echo -e "\n${RED}Error: Site catalog file not found at ${YELLOW}$site_catalog_file${NC}"
    exit 1
fi
java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$1" > "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml"

# Only process recommendations for club catalogs
if [[ "$master_catalog_id" =~ "club" ]]; then
    echo -e "\t${CYAN}Clubs: Processing recs for club catalog ${YELLOW}$master_catalog_id${CYAN} and site catalog ${YELLOW}$site_catalog_id${NC}"

    #### Clubs with recommendations handling ####

    # get a subset of the recommendations for the products in our new trimmed catalog
    echo -e "\t${CYAN}Clubs: static rec target products -> ${YELLOW}$TMP_DIR/$dir_name/recs-targets.txt${CYAN} from our new trimmed catalog${GRAY}"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs"
    python3 "$SCRIPT_DIR/generate-static-recs.py" \
        --master-catalog "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" \
        --catalog-id "$site_catalog_id" \
        --source-catalog "$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" \
        --output "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs/catalog.xml" \
        --targets-dir "$TMP_DIR/$dir_name"
        # --limit-recs

    # get recommendation target products from master catalog
    echo -e "\t${CYAN}Clubs: rec target products master catalog to ${YELLOW}$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml${GRAY}"
    recs_targets=$(cat "$TMP_DIR/$dir_name/recs-targets.txt")
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$master_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-master-catalog.xslt" productIds="$recs_targets" imageBaseUrl="$image_base_url" > "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml"

    # Merge the main master catalog with the rec targets master catalog
    echo -e "\t${CYAN}Clubs: merging main master catalog with rec targets catalog${GRAY}"
    python3 "$SCRIPT_DIR/merge_catalogs.py" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets/catalog.xml"

    # Replace the original catalog with the merged one
    mv "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml"

    # Update variations to include all products from the merged catalog
    echo -e "\t${CYAN}Clubs: updating variations.txt to include all products from merged catalog${GRAY}"
    echo -n "productIds=" > "$TMP_DIR/$dir_name/variations.txt"
    grep -oP '(?<=product-id=")[^"]+' "$TMP_DIR/$dir_name/catalogs/$master_catalog_id/catalog.xml" | sort | uniq | awk '{print "\"" $0 "\""}' | paste -sd'|' - >> "$TMP_DIR/$dir_name/variations.txt"

    cat "$TMP_DIR/$dir_name/variations.txt"

    # rec target products real pricing using updated variations.txt (now includes all products)
    echo -e "\t${CYAN}Clubs: generating pricing for all products (including rec targets) to ${YELLOW}$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml${GRAY}"
    cat "$TMP_DIR/$dir_name/variations.txt" | xargs -t java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/pricebooks/$pricebook_id.xml" -xsl:"$SCRIPT_DIR/generate-pricebook-from-variations.xslt" pricebookId="$pricebook_id" currency="$currency" pricebookParentId="" > "$TMP_DIR/$dir_name/pricebooks/$pricebook_id.xml"

    # rec target products - site catalog assignments
    echo -e "\t${CYAN}Clubs: rec target site catalog to ${YELLOW}$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml${GRAY}"
    mkdir -p "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets"
    java -jar "$SAXON_JAR" -s:"$TMP_DIR/$SOURCE_DIR/catalogs/$site_catalog_id/catalog.xml" -xsl:"$SCRIPT_DIR/generate-trimmed-site-catalog.xslt" productIds="$recs_targets" > "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml"

    # Merge the main site catalog with the rec targets site catalog
    echo -e "\t${CYAN}Clubs: merging main site catalog with rec targets site catalog${GRAY}"
    python3 "$SCRIPT_DIR/merge_catalogs.py" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets/catalog.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs/catalog.xml"

    # Replace the original catalog with the merged one
    mv "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog-merged.xml" "$TMP_DIR/$dir_name/catalogs/$site_catalog_id/catalog.xml"

    # Clean up temporary recs-targets directories
    rm -rf "$TMP_DIR/$dir_name/catalogs/$master_catalog_id-recs-targets"
    rm -rf "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs-targets"
    rm -rf "$TMP_DIR/$dir_name/catalogs/$site_catalog_id-recs"

fi

echo -e "\t${CYAN}See ${YELLOW}$TMP_DIR/$dir_name${CYAN} for the generated files.${NC}"
# node -v
echo -e "\t${CYAN}Importing data into sandbox using b2c-tools...${NC}"
b2c-tools import run "$TMP_DIR/$dir_name" --verify false