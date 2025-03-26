<!-- This XSLT is designed to trim a content slots configuration by taking only the 
global and category slots that are enabled and valid and that don't have an end date, with further filtering by taking a list of category ids and campaign ids you want included

Prerequisites:
- complete content library XML 
- list of campaign ids and category ids to include
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path

Usage of this XSLT:
Transform.exe -s:/path/to/slots.xml -xsl:generate-trimmed-slots.xslt campaignIds='092821-OCT1-CONTENT|111621-DEC-CONTENT|083121-SEP1-CONTENT' categoryIds='accessories|accessories-bags' > slots-trimmed.xml

- OR -

use a prefilled file that has "campaignIds=092821-OCT1-CONTENT|111621-DEC-CONTENT|083121-SEP1-CONTENT categoryIds=accessories|accessories-bags" already in it

cat slot-categories.txt | xargs -t Transform.exe -s:/path/to/slots.xml -xsl:generate-trimmed-slots.xslt > slots-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/slot/2008-09-08" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="categoryIds"/>
    <xsl:param name="campaignIds"/>
    
    
    <xsl:template match="dw:slot-configurations">
<slot-configurations xmlns="http://www.demandware.com/xml/impex/slot/2008-09-08" >
            <xsl:apply-templates select="dw:slot-configuration"/>
            <xsl:apply-templates select="dw:slot-configuration-campaign-assignment"/>
</slot-configurations>
    </xsl:template>
    
    <xsl:template match="dw:slot-configuration"/>
    <xsl:template match="dw:slot-configuration[@assigned-to-site=true() and @context='global' and ./dw:enabled-flag[text()='true'] and not(./dw:schedule/dw:end-date)]">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="dw:slot-configuration[contains($categoryIds,@context-id) and @assigned-to-site=true() and @context='category' and ./dw:enabled-flag[text()='true'] and not(./dw:schedule/dw:end-date)]">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="dw:slot-configuration-campaign-assignment"/>
    <xsl:template match="dw:slot-configuration-campaign-assignment[contains($campaignIds,@campaign-id) and contains($categoryIds,@context-id)]">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>