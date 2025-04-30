# get a single product!
java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:"/home/lwalters/github.com/lawrencewalters/sfcc/tmp/20250409T181755247Z_export/catalogs/titleist-clubs-master-JP/catalog.xml" -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-master-catalog.xslt productIds="670C-J" > /home/lwalters/github.com/lawrencewalters/sfcc/data/670C-J/catalogs/titleist-clubs-master-JP/catalog.xml

# skip inventory (sandbox is default in stock)

# pricing!
java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/home/lwalters/github.com/lawrencewalters/sfcc/tmp/20250409T181755247Z_export/catalogs/titleist-clubs-master-JP/catalog.xml -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-pricebook-from-master-products.xslt productIds="670C-J" pricebookId="jpy-titleist-list" currency="JPY" pricebookParentId="" > /home/lwalters/github.com/lawrencewalters/sfcc/data/670C-J/pricebooks/jpy-titleist-list.xml

java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/home/lwalters/github.com/lawrencewalters/sfcc/tmp/20250409T181755247Z_export/catalogs/titleist-storefront-JP/catalog.xml -xsl:/home/lwalters/github.com/lawrencewalters/sfcc/sandbox-dataset-builder/generate-trimmed-site-catalog.xslt  productIds="670C-J" > /home/lwalters/github.com/lawrencewalters/sfcc/data/670C-J/catalogs/titleist-storefront-JP/catalog.xml