<!-- find all the enabled=false slot configurations and out put them 
 so that you can import them in DELETE mode
 -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/slot/2008-09-08" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="dw:slot-configurations">
<slot-configurations xmlns="http://www.demandware.com/xml/impex/slot/2008-09-08" >
            <xsl:apply-templates select="dw:slot-configuration"/>
            <xsl:apply-templates select="dw:slot-configuration-campaign-assignment"/>
</slot-configurations>
    </xsl:template>
    
    <xsl:template match="dw:slot-configuration"/>
    <xsl:template match="dw:slot-configuration[./dw:enabled-flag[text()='false']]">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>