<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="colony-master-catalog">
            <xsl:apply-templates select="dw:product"/>
        </catalog>
    </xsl:template>
    <xsl:template match="dw:product"/>
    <xsl:template match="dw:product[contains('BT4191001001|BT4191101002|BT4191105003|ES4502|BT4191101003|BT4191101001|BT4191001003|BT4191001002|BT4191105001|BT419110500',@product-id)]">

    <product product-id="{current()/@product-id}">
        <custom-attributes>
            <xsl:for-each select="dw:custom-attributes/dw:custom-attribute[@attribute-id = 'warranty']">
                <custom-attribute attribute-id="warranty" xml:lang="{current()/@xml:lang}"><xsl:value-of select="current()" /></custom-attribute>
            </xsl:for-each>
        </custom-attributes>
    </product>
    </xsl:template>
</xsl:stylesheet>