<!-- This XSLT is designed to trim promotions for a site by taking specific campaigns from a predefined list 

Prerequisites:
- complete promo XML 
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path

Usage of this XSLT:
Transform.exe -s:/path/to/promotions.xml -xsl:generate-trimmed-promos.xslt campaignIds='092821-OCT1-CONTENT|111621-DEC-CONTENT|083121-SEP1-CONTENT' > promos-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/promotion/2008-01-31" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="campaignIds"/>
    <xsl:variable name="promotions" select="/dw:promotions"/>    
    
    <xsl:template match="dw:promotions">
<promotions xmlns="http://www.demandware.com/xml/impex/promotion/2008-01-31" >
            <xsl:apply-templates select="dw:campaign"/>
            <xsl:apply-templates select="dw:promotion"/>
            <xsl:apply-templates select="dw:promotion-campaign-assignment"/>
</promotions>
    </xsl:template>
    
    <xsl:template match="dw:campaign"/>
    <xsl:template match="dw:campaign[./dw:enabled-flag=true() and contains($campaignIds, @campaign-id)]">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="dw:promotion">
        <xsl:if test="$promotions/dw:promotion-campaign-assignment[@promotion-id=current()/@promotion-id] and $promotions/dw:campaign[@campaign-id=$promotions/dw:promotion-campaign-assignment[@promotion-id=current()/@promotion-id]/@campaign-id]/dw:enabled-flag=true()">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dw:promotion-campaign-assignment"/>
    <xsl:template match="dw:promotion-campaign-assignment[contains($campaignIds, @campaign-id)]">
        <xsl:if test="$promotions/dw:campaign[@campaign-id=current()/@campaign-id]/dw:enabled-flag=true()">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>