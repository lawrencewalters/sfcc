<!-- This XSLT is designed to trim a site catalog by passing in a list of master product ID's that are pipe-separated. This will copy all the category definitions plus any category-assignments that include those product ids.

Prerequisites:
- complete master catalog XML (for figuring out variations of master products)
- complete site catalog XML (for finding products currently assigned to site)
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path
- Linux style tools available. Specifically cat, sed, sort, uniq, shuf, xargs. Used Windows Subsystem for Linux (WSL) with Ubuntu 18 but Git Bash may also work.

Setup (getting random list of 100 master products):
echo -n productIds=> active-random-product-ids.txt
sed -nr 's/.*product-id=\"([^"]*)".*/\1/p' /path/to/site/catalog.xml|sort|uniq|shuf -n 100|tr '\n' '|' >> active-random-product-ids.txt

Usage of this XSLT:
cat active-random-product-ids.txt | xargs -t Transform.exe -s:/path/to/site/catalog.xml -xsl:generate-trimmed-site-catalog.xslt > trimmed-site-catalog.xml

or

Transform.exe -s:/path/to/site/catalog.xml -xsl:generate-trimmed-site-catalog.xslt productIds=ABC123|DEF456 > trimmed-site-catalog.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="productIds"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="{current()/@catalog-id}">
            <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:category"/>
            <xsl:apply-templates select="dw:category-assignment"/>
        </catalog>
    </xsl:template>
    <xsl:template match="dw:header">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:category">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:category-assignment"/>
    <xsl:template match="dw:category-assignment[contains($productIds,@product-id)]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>