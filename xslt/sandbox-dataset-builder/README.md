Sandbox Dataset Builder
=========================

These scripts are purposely tweaked from the general XSLT scripts to take a production site and master catalog and produce trimmed site and master catalogs, as well as list and sale pricebooks and inventory to match, so that a developer or team can run this to get a manageable, semi live data set for a sandbox.

Setup
-----------
- read the XSLT setup in the ../README.md
- copy your full site catalog and master catalog to data/site-catalog.xml and data/master-catalog.xml
- run the below commands in your favorit linux-y environment (I use WSL on Windows 10 running Ubuntu 18)


**Using site catalog - get all the product assignments for ALL master products:**
```
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' data/site-catalog.xml|sort|uniq > data/product-ids.txt
```

**Get a random subset of 100 site catalog assigned products**
```
echo -n productIds=> data/active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' data/site-catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> data/active-random-product-ids.txt
```
**pass in the product ids to be transformed for creating the master catalog**
```
cat data/active-random-product-ids.txt | xargs -t Transform.exe -s:data/master-catalog.xml -xsl:generate-trimmed-master-catalog.xslt > data/master-catalog-trimmed.xml
```

**which really is doing this - adding the productIds=XXXX on from the file contents**
```
Transform.exe -s:data/master-catalog.xml -xsl:generate-trimmed-master-catalog.xslt productIds=ABC123|DEF456 > data/master-catalog-trimmed.xml
```

**do the same for inventory - create a new inventory file using the master product id list**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:data/master-catalog.xml -xsl:generate-inventory-from-master-products.xslt inventoryListId="inventory" > data/inventory-trimmed.xml
```

**do the same for prices - create a new pricebook using the master product id list**

**list prices**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-list-prices" pricebookParentId="" > usd-list-prices.xml
```

**sale prices**
```
cat short-active-random-product-ids.txt | xargs -t Transform.exe -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" > inventory-trimmed.xml
```

**Trim site catalog to ALL categories, but only assignments for our random products**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/site/catalog.xml -xsl:generate-trimmed-site-catalog.xslt > trimmed-site-catalog.xml
```

Todo
-------------------
- remove empty <parent/> element when no parent price book is specified in pricebook generation
- automate the download of the production master and site catalogs from staging
- create a shell script (or something) to run all commands at one time
- put variation product ids into their own text file to speed processing: after getting list of master products assigned to the site catalog, do the processing that looks for variants of the masters, but output those as just product ids and save to text file. THEN use this list as the input for all the scripts, and simplify their lookup so they aren't also doing the wild master/variant product lookup.