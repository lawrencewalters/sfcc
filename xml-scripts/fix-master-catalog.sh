#!/bin/sh
set -ex

#handy commands for processing colony files
WORKING=expanded2.xml
FINAL=expanded.xml
INPUT=$1
OUTPUT=~/bitbucket.org/lyonsconsultinggroup/colony-brands/data_impex/data_test/catalogs/colony-master-catalog/catalog.xml
echo 'Processing catalog file ' + $INPUT

# expand the catalog into multiple lines
#sed 's/[>][<]/>\n</g'  catalog-master.xml  > expanded-catalog-master.xml
sed 's/[>][<]/>\n</g'  $INPUT > $FINAL

# fix invalid variation values for images
mv $FINAL > $WORKING
sed 's/image-group view-type="swatch" variation-value=""/image-group view-type="swatch"/' $WORKING > $FINAL
rm $WORKING

#downcase Color and Size
mv $FINAL > $WORKING
sed 's/"Color"/"color"/g' $WORKING > $FINAL 
rm $WORKING

mv $FINAL > $WORKING
sed 's/"Size"/"size"/g' $WORKING > $FINAL 
rm $WORKING

mv $FINAL $OUTPUT

# lint the expanded file
#xmllint expanded-catalog-master.xml --schema ~/docs/proj/col/xml-xsd-samples/catalog.xsd --noout
xmllint $OUTPUT --schema ~/docs/proj/col/xml-xsd-samples/catalog.xsd --noout
