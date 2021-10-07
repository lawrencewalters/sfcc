# XSLT script usage notes

## Using site catalog - get all the product assignments for ALL master products:
```
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' catalog.xml|sort|uniq > product-ids.txt
```

## get a random subset of site catalog assigned products
```
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' catalog.xml|sort|uniq|shuf -n 3|tr '\n' '|' >> active-random-product-ids.txt
```

## pass in the product ids to be transformed for creating the master catalog
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:../master-catalog/catalog.xml -xsl:enerate-trimmed-master-catalog.xslt > master-catalog-trimmed.xml
```

## do the same for inventory - create a new inventory file using the master product id list
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:../master-catalog/catalog.xml -xsl:enerate-inventory-from-master-products.xslt inventoryListId="inventory_madewell_US" > inventory-trimmed.xml
```

## do the same for prices - create a new pricebook using the master product id list

### list prices
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:../master-catalog/catalog.xml -xsl:enerate-pricebook-from-master-products.xslt pricebookId="usd-list-prices" pricebookParentId="" > usd-list-prices.xml
```

### sale prices
```
cat short-active-random-product-ids.txt | xargs -t Transform.exe -s:../master-catalog/catalog.xml -xsl:enerate-pricebook-from-master-products.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" > inventory-trimmed.xml
```

## which really is doing this - adding the productIds=XXXX on from the file contents
```
Transform.exe -s:../master-catalog/catalog.xml -xsl:et-variants-mdw.xslt productIds=L3887
```

## Trim site catalog to ALL categories, but only assignments for our random products
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:catalog.xml -xsl:enerate-trimmed-site-catalog.xslt > trimmed-site-catalog.xml
```