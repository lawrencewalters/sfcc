<!-- get a list of all categories that are online from a storefront catalog xml 

java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/path/to/site/catalog.xml -xsl:get-online-categories.xslt > online-site-catalog.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="text" indent="yes"/>
    <xsl:template match="dw:catalog">categoryIds="<xsl:apply-templates select="dw:category"/>"</xsl:template>
    <xsl:template match="dw:category" />
    <xsl:template match="dw:category[./dw:online-flag[text()='true']]"><xsl:value-of select="@category-id"/>|</xsl:template>
</xsl:stylesheet>