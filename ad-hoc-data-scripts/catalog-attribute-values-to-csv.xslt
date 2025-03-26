<!-- this was a one off generation of a list of product values. The specific attributes are printed in a CSV format-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" 
exclude-result-prefixes="dw">
    <xsl:output method="text"/>
    <xsl:template match="dw:catalog">
      <xsl:for-each select="dw:product">
      <xsl:if test="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxCa']">
<xsl:value-of select="@product-id"/>, <xsl:value-of select="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxCa']"/>, <xsl:value-of select="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxIa']"/>, <xsl:value-of select="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxIl']"/>, <xsl:value-of select="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxIn']"/>, <xsl:value-of select="dw:custom-attributes/dw:custom-attribute[@attribute-id='taxWi']"/>
<xsl:text>
</xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>