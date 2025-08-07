<!-- get all content ids referenced in enabled slots

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/slot/2008-09-08" exclude-result-prefixes="dw">
    <xsl:output method="text"/>
    <xsl:param name="categoryIds"/>
    
    <xsl:template match="dw:slot-configurations">contentIds=<xsl:apply-templates select="dw:slot-configuration"/></xsl:template>
    
    <xsl:template match="dw:slot-configuration"/>

    <!-- get global content, enabled, content asset configs-->
    <xsl:template match="dw:slot-configuration[@assigned-to-site=true() and @context='global' and ./dw:enabled-flag[text()='true'] and ./dw:template[text()='slots/content/contentassetbody.isml'] and not(./dw:schedule/dw:end-date)]">"<xsl:value-of select="dw:content/dw:content-assets/dw:content-asset/@content-id"/>"|</xsl:template>

    <!-- get category context, enabled, matching category input list categories only -->
    <xsl:template match="dw:slot-configuration[contains($categoryIds,@context-id) and @assigned-to-site=true() and @context='category' and ./dw:enabled-flag[text()='true'] and ./dw:template[text()='slots/content/contentassetbody.isml'] and not(./dw:schedule/dw:end-date)]">"<xsl:value-of select="dw:content/dw:content-assets/dw:content-asset/@content-id"/>"|</xsl:template>
    
</xsl:stylesheet>