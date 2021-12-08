<!-- This XSLT is designed to trim a content library by taking only the folders and items that are online 

Prerequisites:
- complete content library XML 
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path

Usage of this XSLT:

Transform.exe -s:/path/to/content/library.xml -xsl:generate-trimmed-content-library.xslt > library-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/library/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    
    
    <xsl:template match="dw:library">
<library xmlns="http://www.demandware.com/xml/impex/library/2006-10-31" library-id="{current()/@library-id}">
            <xsl:apply-templates select="dw:folder"/>
            <xsl:apply-templates select="dw:content"/>
</library>
    </xsl:template>
    
    <xsl:template match="dw:folder"/>
    <xsl:template match="dw:folder[./dw:online-flag[text()='true']]">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:content"/>
    <xsl:template match="dw:content[./dw:online-flag[text()='true']]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>