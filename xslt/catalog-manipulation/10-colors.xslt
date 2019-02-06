<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="colony-master-catalog">
    <header>
        <image-settings>
            <internal-location base-path="/"/>
            <view-types>
                <view-type>large</view-type>
                <view-type>rollover</view-type>
                <view-type>swatch</view-type>
            </view-types>
            <variation-attribute-id>color</variation-attribute-id>
            <alt-pattern>${productname}, ${variationvalue}, ${viewtype}</alt-pattern>
            <title-pattern>${productname}, ${variationvalue}</title-pattern>
        </image-settings>
    </header>
            <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </catalog>
    </xsl:template>
    <xsl:template match="dw:header" />
    <xsl:template match="dw:product" />
    <xsl:template match="dw:product[@product-id='752998']">
        <xsl:if test="count(dw:variations/dw:attributes/dw:variation-attribute[@attribute-id='color']/dw:variation-attribute-values/*) &gt; 9">
            <xsl:variable name="masterProduct" select="."/>
            <xsl:for-each select="dw:variations/dw:variants/dw:variant">
                <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
                    <xsl:copy-of select="$catalog/dw:product[@product-id = current()/@product-id]"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>