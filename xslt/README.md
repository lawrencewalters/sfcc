XSLT fun
=================

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

XSLT Setup
-----------
I used Saxonica, .net version.
There's a java version
(it's cross platform, duh)
Home Edition (HE) is open source, seems fine
highly performant, afaict

Saxon-HE
http://www.saxonica.com/html/download/download_page.html

fyi, Saxon-HE 9.8.0.1N

Runnit....

`transform inputfile.xml your-transform.xslt > new-xml-file.xml`

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


Development Environment XML Import Setup - Specific XSLT script usage notes
-------------------
Below are notes on how to generate trimmed master catalog, site catalog, inventory and pricebooks given a production master and site catalog.

**Using site catalog - get all the product assignments for ALL master products:**
```
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq > product-ids.txt
```

**Get a random subset of 100 site catalog assigned products**
```
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> active-random-product-ids.txt
```
**pass in the product ids to be transformed for creating the master catalog**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-trimmed-master-catalog.xslt > master-catalog-trimmed.xml
```

**which really is doing this - adding the productIds=XXXX on from the file contents**
```
Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-trimmed-master-catalog.xslt productIds=ABC123|DEF456 > master-catalog-trimmed.xml
```

**do the same for inventory - create a new inventory file using the master product id list**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-inventory-from-master-products.xslt inventoryListId="inventory_madewell_US" > inventory-trimmed.xml
```

**do the same for prices - create a new pricebook using the master product id list**

**list prices**
```
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-list-prices" pricebookParentId="" > usd-list-prices.xml
```

**sale prices**
```
cat short-active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" > inventory-trimmed.xml
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