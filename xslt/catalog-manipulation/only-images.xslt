<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" 
exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:template match="dw:catalog">
<catalog 
    xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="colony-master-catalog">
        <xsl:for-each select="dw:header">
                <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each-group select="dw:product[contains('000072|000173|000345|000484|000637|000651|000656|000780|001715|007847|007872|007878|007909|007984|007990|007993|030085|031430|035435|049175|059207|740773|740804|740805|749544|757104',@product-id)]" group-by="@product-id">
                <xsl:copy-of select="."/>
        </xsl:for-each-group>
</catalog>
    </xsl:template>
</xsl:stylesheet>