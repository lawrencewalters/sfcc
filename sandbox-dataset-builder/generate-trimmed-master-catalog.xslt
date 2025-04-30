<!-- This XSLT is designed to trim a master catalog by passing in a list of master product ID's that are pipe-separated. This will pull all the variation products, and the masters, and create a new master catalog file

Prerequisites:
- complete master catalog XML (for figuring out variations of master products)
- complete site catalog XML (for finding products currently assigned to site)
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path
- Linux style tools available. Specifically cat, sed, sort, uniq, shuf, xargs. Used Windows Subsystem for Linux (WSL) with Ubuntu 18 but Git Bash may also work.

Setup (getting random list of 100 master products):
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> active-random-product-ids.txt

Usage of this XSLT:
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-trimmed-master-catalog.xslt > master-catalog-trimmed.xml

or

Transform.exe -s:/path/to/master/catalog.xml -xsl:generate-trimmed-master-catalog.xslt productIds="ABC123|DEF456" > master-catalog-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:param name="productIds"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="{current()/@catalog-id}">
            <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </catalog>
    </xsl:template>
    <xsl:template match="dw:header">
        <header xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31">
            <xsl:apply-templates select="dw:image-settings"/>
        </header>
    </xsl:template>
    <xsl:template match="dw:image-settings">
        <image-settings xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31">
            <external-location xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" >
                <http-url xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31">http://development-na.titleist.com/dw/image/v2/AAZW_DEV/on/demandware.static/-/Sites-<xsl:value-of select="$catalog/@catalog-id"/>/default/</http-url>
                <https-url xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31">https://development-na.titleist.com/dw/image/v2/AAZW_DEV/on/demandware.static/-/Sites-<xsl:value-of select="$catalog/@catalog-id"/>/default/</https-url>
            </external-location>
            <!-- Copy all child elements except internal-location -->
            <xsl:for-each select="*[name() != 'internal-location']">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </image-settings>
    </xsl:template>

    <xsl:template match="dw:product"/>
    <xsl:template match="dw:product[contains($productIds,@product-id)]">
        <xsl:variable name="masterProduct" select="."/>
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
                <xsl:copy-of select="$catalog/dw:product[@product-id = current()/@product-id]"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>