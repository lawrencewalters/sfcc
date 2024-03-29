#!/bin/sh
set -ex

#handy commands for processing files
WORKING=expanded2.xml
FINAL=expanded.xml
INPUT=$1
OUTPUT=~/data_impex/data_test/catalogs/catalog-en/catalog.xml
echo 'Processing catalog file ' + $INPUT

# expand the catalog into multiple lines
#sed 's/[>][<]/>\n</g'  catalog-master.xml  > expanded-catalog-master.xml
sed 's/[>][<]/>\n</g'  $INPUT > $FINAL

mv $FINAL $OUTPUT

# lint the expanded file
#xmllint expanded-catalog-master.xml --schema ~/docs/proj/col/xml-xsd-samples/catalog.xsd --noout
xmllint $OUTPUT --schema ~/docs/proj/xml-xsd-samples/catalog.xsd --noout
