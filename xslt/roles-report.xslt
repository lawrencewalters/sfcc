<!-- given an export of the user roles from an SFCC instance, report specific roles' access -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/accessrole/2007-09-05" exclude-result-prefixes="dw">
    <xsl:output method="html"/>

<xsl:template match="/">
<table>
<xsl:apply-templates />
</table>
</xsl:template>

<xsl:template match="dw:access-role">
<tr>
<td><xsl:value-of select="@role-id"/></td>
<td><xsl:value-of select="dw:description"/></td>
<td><xsl:apply-templates select="dw:access-controls/dw:access-control"/></td>
</tr>
</xsl:template>

<xsl:template match="dw:access-control[contains(@resource-path, 'Some site id here') or contains(@resource-path, 'WEBDAV') or contains(@resource-path,'Sites/-')]">
<xsl:value-of select="@resource-path"/>:<xsl:value-of select="@permission"/><br /><xsl:text>
</xsl:text>
</xsl:template>
</xsl:stylesheet>