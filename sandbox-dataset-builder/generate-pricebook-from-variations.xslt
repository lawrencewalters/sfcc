<!-- this will take a list of variation product ids, and generate a pricebook with actual prices from a real pricebook. 

Prerequisites:
- list of pipe separated variation product ids
- complete pricebook file
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path
- Linux style tools available. Specifically cat, sed, sort, uniq, shuf, xargs. Used Windows Subsystem for Linux (WSL) with Ubuntu 18 but Git Bash may also work.

Setup (getting variation products from your trimmed catalog):
grep -oP '(?<=product-id=")[^"]+' "catalog.xml" | paste -sd '|' > "variations.txt"

Usage of this XSLT:

cat variations.txt | xargs -t Transform.exe -s:/path/to/pricebook.xml -xsl:generate-pricebook-from-variations.xslt pricebookId="usd-list-prices" currency="USD" pricebookParentId="" > usd-list-prices.xml

or

Transform.exe -s:/path/to/pricebook.xml -xsl:generate-pricebook-from-variations.xslt pricebookId="usd-sale-prices" pricebookParentId="usd-list-prices" currency="USD" productIds="ABC123|DEF456" > usd-sale-prices.xml
-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/pricebook/2006-10-31" 
    exclude-result-prefixes="dw"
    >
    <xsl:param name="productIds"/>
    <xsl:param name="pricebookId"/>
    <xsl:param name="currency"/>
    <xsl:param name="pricebookParentId"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="dw:pricebooks">
    <pricebooks xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31">
        <pricebook>
            <xsl:apply-templates select="dw:pricebook/dw:header"/>
            <price-tables>
                <xsl:apply-templates select="dw:pricebook/dw:price-tables/dw:price-table"/>
            </price-tables>
        </pricebook>
    </pricebooks>
    </xsl:template>
    
    <xsl:template match="dw:header">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="dw:price-table"/>

    <xsl:template match="dw:price-table[contains($productIds,@product-id)]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>