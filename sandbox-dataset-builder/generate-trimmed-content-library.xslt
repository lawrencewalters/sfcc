<!-- This XSLT is designed to trim a content library by taking only the folders that are online, along with a predefined list of content asset ids

Prerequisites:
- complete content library XML
- list of content asset ids you want included
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path

Usage of this XSLT:

Transform.exe -s:/path/to/content/library.xml -xsl:generate-trimmed-content-library.xslt contentIds='some-content|more-content-id' > library-trimmed.xml

- OR - 

#get content ids that are referenced by slots (may need manual trimming)
grep -o 'content-asset content-id=\"[^"]*' data/slots.xml|sort|uniq|sed 's/content-asset content-id="//' > data/slot-content-ids.txt

cat data/content-asset-ids.txt | xargs -t Transform.exe -s:data/library.xml -xsl:generate-trimmed-content-library.xslt > data/library-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/library/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="contentIds"/>
    
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
    <xsl:template match="dw:content[contains($contentIds,@content-id) and ./dw:online-flag[text()='true']]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>