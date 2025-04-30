#!/bin/bash
set -x

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

mkdir "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name"
mkdir "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/catalogs"
mkdir "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/catalogs/$2"
mkdir "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/catalogs/$3"
mkdir "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/pricebooks"

# get a single product!
java -jar "$HOME/SaxonHE12-5J/saxon-he-12.5.jar" -s:"$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/$2/catalog.xml" -xsl:"$HOME/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-master-catalog.xslt" productIds="$1" > "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/catalogs/$2/catalog.xml"

# skip inventory (sandbox is default in stock)

# pricing!
java -jar "$HOME/SaxonHE12-5J/saxon-he-12.5.jar" -s:"$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/$2/catalog.xml" -xsl:"$HOME/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-pricebook-from-master-products.xslt" productIds="$1" pricebookId="$4" currency="$5" pricebookParentId="" > "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/pricebooks/$4.xml"

# site catalog
java -jar "$HOME/SaxonHE12-5J/saxon-he-12.5.jar" -s:"$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/$3/catalog.xml" -xsl:"$HOME/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-site-catalog.xslt" productIds="$1" > "$HOME/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/$dir_name/catalogs/$3/catalog.xml"