#!/bin/sh
# get some handy info from a catalog file
CATALOG=$1
echo "Inspecting $CATALOG"

# get unique product attributes and their values
echo "Getting unique product attributes"
grep -o 'attribute-id=\"[^"]*' $CATALOG|sort|uniq|sed 's/attribute-id="//' > attributes.csv
cat attributes.csv

# get all values for a given variation attribute
echo "Distinct values of all attributes: "
echo "attribute-values:" > attribute-values.txt
for attribute in `cat attributes.csv`; do
    echo $attribute
    echo $attribute >> attribute-values.txt
    grep "custom-attribute attribute-id=\"$attribute\"" $CATALOG|sort|uniq|sed -r 's/<custom-attribute attribute-id="[^"]*">([^<]*)<.*/  \1/' >> attribute-values.txt
done

# lint the expanded file
echo "Linting file now"
xmllint $CATALOG --schema schema/catalog.xsd --noout

# count distinct products
echo "Total Distinct products:"
grep '<product product-id=\"[^"]*' $CATALOG|uniq|wc -l

# count duplicate products
echo "Duplicate products -> duplicate_products.txt"
grep '<product product-id=\"[^"]*' $CATALOG|sort|uniq -c|grep '2 <'|sort>duplicate_products.txt
