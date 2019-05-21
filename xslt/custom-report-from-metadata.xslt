<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/metadata/2006-10-31" >
    <xsl:output method="html" indent="no"/>


<xsl:template match="dw:custom-type">
<xsl:value-of select="concat('&#10;', dw:display-name,'&#10;------&#10;')"/>
<xsl:value-of select="concat('|ID|', @type-id,'|&#10;')"/>
<xsl:value-of select="concat('|Key|',dw:key-definition/[@attribute-id], '|&#10;')"/>
<xsl:value-of select="concat('|Description|', dw:description,'|&#10;')"/>
<xsl:text>|Data Replication|</xsl:text>
<xsl:choose>
  <xsl:when test="dw:staging-mode = 'no-staging'"> 
    <xsl:text>No</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>Yes</xsl:text>
  </xsl:otherwise>
</xsl:choose><xsl:text>|&#10;</xsl:text>
<xsl:value-of select="concat('|Scope|',dw:storage-scope, '|&#10;')"/><xsl:text></xsl:text>
<xsl:value-of select="concat('|Retention|',dw:retention-days, '|&#10;&#10;')"/> 
<xsl:text>|ID|Name|Description|Type|Default|Group|
</xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="dw:attribute-definitions/dw:attribute-definition">|<xsl:value-of select="@attribute-id"/>|<xsl:value-of select="dw:display-name[@xml:lang='x-default']"/>|<xsl:choose>
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
</xsl:choose>|<xsl:choose>
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