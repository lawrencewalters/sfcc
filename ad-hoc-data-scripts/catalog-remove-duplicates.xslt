<!-- for when you have a catalog xml that has duplicates in it - this will remove them by grouping on "product-id"-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" 
exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:template match="dw:catalog">
<catalog 
    xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="master-catalog">
        <xsl:for-each select="dw:header">
                <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each-group select="dw:product" group-by="@product-id">
                <xsl:copy-of select="."/>
        </xsl:for-each-group>
</catalog>
    </xsl:template>
</xsl:stylesheet>