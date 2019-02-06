#!/bin/sh
#handy commands for processing colony files
# expand the catalog into multiple lines
sed 's/[>][<]/>\n</g'  catalog-master.xml  > expanded-catalog-master.xml

#downcase Color and Size
sed 's/"Color"/"color"/g' expanded-catalog-master.xml > corrected-catalog-master.xml
sed 's/"Size"/"size"/g' corrected-catalog-master.xml > corrected-catalog-master2.xml

# lint the expanded file
xmllint expanded-catalog-master.xml --schema ~/docs/proj/col/xml-xsd-samples/catalog.xsd --noout

# count distinct products
grep '<product product-id=\"[^"]*' expanded-catalog-master.xml|uniq|wc -l

# count duplicate products
grep '<product product-id=\"[^"]*' expanded-catalog-master.xml|sort|uniq -c|grep '2 <'|sort>duplicate_products.txt

# get unique product attributes and their values
grep -o 'attribute-id=\"[^"]*' expanded-catalog-master.xml|sort|uniq

# save all unique attributes to a file
grep -o 'attribute-id=\"[^"]*' corrected-catalog-master2.xml|sort|uniq|sed 's/attribute-id="//' > attributes.csv

# get all values for a given variation attribute
grep 'attribute-id=\"afterPriceLabel"' corrected-catalog-master2.xml|sort|uniq|sed -r 's/<custom-attribute attribute-id="[^"]*">([^<]*)<.*/\1/'

