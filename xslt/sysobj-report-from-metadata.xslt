<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/metadata/2006-10-31" >
    <xsl:output method="html" indent="no"/>

<xsl:template match="dw:metadata">
<xsl:text>|ID|Name|Description|Type|Default|Object|Group|
</xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="dw:type-extension/dw:custom-attribute-definitions/dw:attribute-definition">|<xsl:value-of select="@attribute-id"/>|<xsl:value-of select="dw:display-name[@xml:lang='x-default']"/>|<xsl:choose>
  <xsl:when test="dw:description[@xml:lang='x-default']"> 
    <xsl:value-of select="replace(dw:description[@xml:lang='x-default'],'\n',' ')"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>-</xsl:text>
  </xsl:otherwise>
</xsl:choose>|<xsl:value-of select="dw:type"/>|<xsl:choose>
  <xsl:when test="dw:default-value"> 
    <xsl:value-of select="dw:default-value"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>-</xsl:text>
  </xsl:otherwise>
</xsl:choose>|<xsl:value-of select="../../@type-id"/>|<xsl:choose>
  <xsl:when test="../../dw:group-definitions/dw:attribute-group/dw:attribute[@attribute-id=current()/@attribute-id]/../@group-id"> 
    <xsl:value-of select="../../dw:group-definitions/dw:attribute-group/dw:attribute[@attribute-id=current()/@attribute-id]/../@group-id"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>-</xsl:text>
  </xsl:otherwise>
</xsl:choose>|
</xsl:template>

    <xsl:template match="text()|@*"/>
</xsl:stylesheet>