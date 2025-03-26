Salesforce Commerce Cloud B2C tools

ad-hoc-data-scripts: xslt, shell scripts for messing with data
browser-plugin: tampermonkey script for making business manager more friendly
data: place to put data sets for upload to an SFCC instance
log-scripts: tools for parsing logs
ocapi: postman collection
sandbox-control: starting/stopping/creating on demand sandboxes
sandbox-dataset-builder: create entire sets of data for a site based on trimming production data
xml-schema: XSD from SFCC for validating xml


XSLT fun
=================

Read below for an intro to XSLT

See sandbox-dataset-builder if you want to take a production dataset and trim for sandbox use.

XSLT Setup
-----------
For all of the XSLT here, this is the setup I've used.

Home Edition (HE) is open source, seems fine
highly performant, afaict

Saxon-HE
http://www.saxonica.com/html/download/download_page.html

fyi, SaxonHE12-5J

Runnit....

`SaxonHE12-5J/saxon-he-12.5.jar inputfile.xml your-transform.xslt > new-xml-file.xml`

Introduction to XSLT
===============

What is it!?
-----------
Extensible Stylesheet Language Transformation

XML + XSLT = HTML (or more XML... or text)

1.0 - 1999

2.0 - 2007... XPath 2.0, XML Schema (XSD, anyone?)

3.0 - 2017 ?


Sidebar: xmllint
-------------
Question: is this valid XML for SFCC?

install (windows):
http://www.zlatkovic.com/libxml.en.html
https://stackoverflow.com/questions/19546854/installing-xmllint

(already installed on Mac, lucky!)

`xmllint --noout --schema catalog.xsd some-catalog-file.xml`

Examples
--------------

Add a missing element to some xml (fix-cust2.xslt)
 - pro tip #1: "identity transform" and matching templates

Pick out some products from a huge catalog file (only-images.xslt)
 - pro tip #2: the namespace, don't forget the fkn namespace!

Delete duplicates from a huge file (remove-duplicates.xslt)
 - pro tip #3: group by is a thing

Create an inventory file when you don't know the variants (inventory.xslt)
 - pro tip #4: current element and walking the xpath tree


Sandbox Dataset Builder
=========================

These scripts are purposely tweaked from the general XSLT scripts to take a production site and master catalog and produce trimmed site and master catalogs, as well as list and sale pricebooks and inventory to match, so that a developer or team can run this to get a manageable, semi live data set for a sandbox.

Setup
-----------
- read the XSLT setup in the ../README.md
- copy your full site catalog and master catalog to data/site-catalog.xml and data/master-catalog.xml
- run the below commands in your favorite linux-y environment (I use WSL on Windows 11 running Ubuntu 22)


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
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-trimmed-master-catalog.xslt > data/master-catalog-trimmed.xml
```

**which really is doing this - adding the productIds=XXXX on from the file contents**
```
java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-trimmed-master-catalog.xslt productIds=ABC123|DEF456 > data/master-catalog-trimmed.xml
```

**do the same for inventory - create a new inventory file using the master product id list**
```
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-inventory-from-master-products.xslt inventoryListId="footjoy-inventory-sea" > data/footjoy-inventory-sea.xml
```

**do the same for prices - create a new pricebook using the master product id list**

**list prices**
```
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="myr-list-prices" currency="MYR" pricebookParentId="" > data/pricebooks/myr-list-prices.xml
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="sgd-list-prices" currency="SGD" pricebookParentId="" > data/pricebooks/sgd-list-prices.xml
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="thb-list-prices" currency="THB" pricebookParentId="" > data/pricebooks/thb-list-prices.xml
```

**sale prices**
Make a `data/short-active-random-product-ids.txt` so that only some of the products will have sale prices
```
cat data/short-active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="myr-sale-prices" currency="MYR" pricebookParentId="myr-list-prices" > data/pricebooks/myr-sale-prices.xml
cat data/short-active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="sgd-sale-prices" currency="SGD" pricebookParentId="sgd-list-prices" > data/pricebooks/sgd-sale-prices.xml
cat data/short-active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="thb-sale-prices" currency="THB" pricebookParentId="thb-list-prices" > data/pricebooks/thb-sale-prices.xml
```

**inventory pricebooks**
```
cat data/in-stock-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="myr-list-prices-inventory" currency="MYR" pricebookParentId="" > data/pricebooks/myr-list-prices-inventory.xml
cat data/short-active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="sgd-list-prices-inventory" currency="SGD" pricebookParentId="" > data/pricebooks/sgd-list-prices-inventory.xml
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/master-catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="thb-list-prices-inventory" currency="THB" pricebookParentId="" > data/pricebooks/thb-list-prices-inventory.xml
```

**Trim site catalog to ALL categories, but only assignments for our random products**
```
cat data/active-random-product-ids.txt | xargs -t java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:data/site-catalog.xml -xsl:generate-trimmed-site-catalog.xslt > data/footjoy-storefront-sea/catalog.xml
```

Todo
-------------------
- remove empty <parent/> element when no parent price book is specified in pricebook generation
- automate the download of the production master and site catalogs from staging
- create a shell script (or something) to run all commands at one time
- put variation product ids into their own text file to speed processing: after getting list of master products assigned to the site catalog, do the processing that looks for variants of the masters, but output those as just product ids and save to text file. THEN use this list as the input for all the scripts, and simplify their lookup so they aren't also doing the wild master/variant product lookup.