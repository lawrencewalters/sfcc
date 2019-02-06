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

Questions / follow up
--------------

provide sample XML to go with transforms, especially
