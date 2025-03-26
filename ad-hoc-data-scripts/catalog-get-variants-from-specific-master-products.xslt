<!-- generic catalog XML generation to make a new catalog XML pulling out specific master products and their variations -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="{current()/@catalog-id}">
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
    <xsl:template match="dw:product"/>
    <xsl:template match="dw:product[contains('CT1000|ES4093|ES4442|ES4502|ES4504|ES4505|ES4506SET|ES4507|ES4573|FS4735|FS5151|FS5507|FS5508|FS5509|FS5510|FS5511|FS5524|FTW1177|FTW1178|FTW1179|FTW1180|FTW6013|FTW6017|FTW6020|FTW6022|FTW6023|FTW6024|FTW6025|FTW6026|FTW6027|FTW6028|JF03108710|JF03109793|JF03110040|ML4059222|S141179|S141181|S141182|S141184|S221428|S221430|S221431|ZB6760001|ZB6760200|ZB7256231|ZB7256981|ZB7314005|ZB7314414|ZB7314998',@product-id)]">
        <xsl:variable name="masterProduct" select="."/>
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
                <xsl:copy-of select="$catalog/dw:product[@product-id = current()/@product-id]"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>