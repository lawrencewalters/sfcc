<!-- this will take a list of master product ids, read the master catalog to find the variants, then generate an inventory list xml 

Prerequisites:
- complete master catalog XML (for figuring out variations of master products)
- complete site catalog XML (for finding products currently assigned to site)
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path
- Linux style tools available. Specifically cat, sed, sort, uniq, shuf, xargs. Used Windows Subsystem for Linux (WSL) with Ubuntu 18 but Git Bash may also work.

Setup (getting random list of 100 master products):
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> active-random-product-ids.txt

Usage of this XSLT:

cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-inventory-from-master-products.xslt inventoryListId="inventory_for_site" > inventory-trimmed.xml

or

Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-inventory-from-master-products.xslt inventoryListId="inventory_for_site" productIds="ABC123|DEF456" > inventory-trimmed.xml
-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="productIds"/>
    <xsl:param name="inventoryListId"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
<inventory 
    xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31">
    <inventory-list>
        <header list-id="{$inventoryListId}">
            <default-instock>false</default-instock>
            <description>Product Sku Inventory</description>
            <use-bundle-inventory-only>false</use-bundle-inventory-only>
            <on-order>false</on-order>
        </header>
        <records>
           <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </records></inventory-list></inventory>
    </xsl:template>

    <xsl:template match="dw:header" />

    <xsl:template match="dw:product"/>

    <xsl:template match="dw:product[contains($productIds,@product-id)]">
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
            <record xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31" product-id="{current()/@product-id}">
                <allocation>9999999</allocation>
                <perpetual>false</perpetual>
                <preorder-backorder-handling>none</preorder-backorder-handling>
                <preorder-backorder-allocation>0</preorder-backorder-allocation>
                <ats>9999999</ats>
                <on-order>0</on-order>
                <turnover>0</turnover>
            </record>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>