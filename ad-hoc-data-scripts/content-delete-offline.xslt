<!-- 
generate a content library xml that only contains the folders and content assets that are offline  
-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/library/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="dw:library">
<library xmlns="http://www.demandware.com/xml/impex/library/2006-10-31" library-id="{current()/@library-id}">
            <xsl:apply-templates select="dw:folder"/>
            <xsl:apply-templates select="dw:content"/>
</library>
    </xsl:template>
    
    <xsl:template match="dw:folder"/>
    <xsl:template match="dw:folder[./dw:online-flag[text()='false']]">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:content"/>
    <xsl:template match="dw:content[./dw:online-flag[text()='false']]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>