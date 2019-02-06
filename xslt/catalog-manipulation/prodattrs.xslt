<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/metadata/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:template match="dw:metadata/dw:type-extensiondw">
            <xsl:apply-templates select="dw:type-extension"/>
    </xsl:template>
    <xsl:template match="dw:type-extension"/>
    <xsl:template match="dw:type-extension[@type-id='Product']">
        <xsl:for-each select="dw:custom-attribute-definitions">
            &lt;attribute attribute-id="<xsl:value-of select="dw:attribute-definition/@attribute-id"/>"/&gt;
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>