<!-- get a map of page-url:category-id for all online categories with a page-url in the storefront catalog XML

java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/path/to/site/catalog.xml -xsl:get-category-url-mappings.xslt > data/url-to-category-id-mapping.txt

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="text"/>
    <xsl:template match="dw:catalog"><xsl:apply-templates select="dw:category"/></xsl:template>
    <xsl:template match="dw:category" />
    <xsl:template match="dw:category[./dw:online-flag[text()='true'] and ./dw:page-attributes/dw:page-url[@xml:lang='x-default']]">
<xsl:value-of select="dw:page-attributes/dw:page-url[@xml:lang='x-default']"/>:<xsl:value-of select="@category-id"/><xsl:text>&#10;</xsl:text>
</xsl:template>
</xsl:stylesheet>