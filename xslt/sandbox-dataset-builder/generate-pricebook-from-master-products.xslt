<!-- this will take a list of master product ids, and generate a pricebook with random prices for every variation. Note you can run this twice to create LIST and SALE prices; the examples below generate random prices, so SALE price is not guaranteed to be below LIST price, but who really cares? SFCC doesn't.


Prerequisites:
- complete master catalog XML (for figuring out variations of master products)
- complete site catalog XML (for finding products currently assigned to site)
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path
- Linux style tools available. Specifically cat, sed, sort, uniq, shuf, xargs. Used Windows Subsystem for Linux (WSL) with Ubuntu 18 but Git Bash may also work.

Setup (getting random list of 100 master products):
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> active-random-product-ids.txt

Usage of this XSLT:

cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-list-prices" pricebookParentId="" > usd-list-prices.xml

cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" > usd-sale-prices.xml

or

Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-pricebook-from-master-products.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" productIds=ABC123|DEF456 > usd-sale-prices.xml
-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" 
    exclude-result-prefixes="dw"
    >
    
    <xsl:param name="productIds"/>
    <xsl:param name="pricebookId"/>
    <xsl:param name="pricebookParentId"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    
    <xsl:template match="dw:catalog">
<pricebooks xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31">
    <pricebook>
        <header pricebook-id="{$pricebookId}">
            <currency>USD</currency>
            <display-name xml:lang="x-default">prices for the website</display-name>
            <online-flag>true</online-flag>
            <xsl:if test="string-length($pricebookParentId) > 0">
            <parent><xsl:value-of select="$pricebookParentId"/></parent>
            </xsl:if>
        </header>

        <price-tables>
            <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </price-tables>
    </pricebook>
</pricebooks>
    </xsl:template>

    <xsl:template match="dw:header" />

    <xsl:template match="dw:product"/>

    <xsl:template match="dw:product[contains($productIds,@product-id)]">
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
            <price-table xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31" product-id="{current()/@product-id}">
                <amount quantity="1"><xsl:value-of select="format-number(floor((count(preceding::dw:product) mod 3000) div 25) + 0.99 ,'00.00')"/></amount>
            </price-table>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>