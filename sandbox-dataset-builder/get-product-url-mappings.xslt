<!-- get a list of all product url:product id mapping

java -jar /home/lwalters/SaxonHE12-5J/saxon-he-12.5.jar -s:/path/to/master/catalog.xml -xsl: get-product-url-mappings.xslt > data/url-to-product-id-mapping.txt

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="text"/>
    <xsl:template match="dw:catalog"><xsl:apply-templates select="dw:product"/></xsl:template>
    <xsl:template match="dw:product" />
    <xsl:template match="dw:product[dw:online-flag[text()='true'] and dw:display-name[@xml:lang='x-default'] and dw:variations]">product/<xsl:value-of select="replace(replace(lower-case(dw:display-name[@xml:lang='x-default']), ' ', '-'), &quot;'&quot;, '')"/>/<xsl:value-of select="@product-id"/>.html:<xsl:value-of select="@product-id"/><xsl:text>&#10;</xsl:text></xsl:template>
</xsl:stylesheet>