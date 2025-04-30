#!/bin/bash
set -x
# get a single product!
java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:"/home/lwalters/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/titleist-clubs-master/catalog.xml" -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-master-catalog.xslt productIds="557C" > /home/lwalters/github.com/lawrencewalters/sfcc/data/557C/catalogs/titleist-clubs-master/catalog.xml

# skip inventory (sandbox is default in stock)

# pricing!
java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/home/lwalters/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/titleist-clubs-master-JP/catalog.xml -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-pricebook-from-master-products.xslt productIds="557C" pricebookId="titleist-clubs-prices" currency="USD" pricebookParentId="" > /home/lwalters/github.com/lawrencewalters/sfcc/data/557C/pricebooks/titleist-clubs-prices.xml

java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/home/lwalters/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/titleist-storefront/catalog.xml -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-site-catalog.xslt  productIds="557C" > /home/lwalters/github.com/lawrencewalters/sfcc/data/557C/catalogs/titleist-storefront/catalog.xml