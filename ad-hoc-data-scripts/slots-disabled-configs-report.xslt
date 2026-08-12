<!--
  Output CSV rows for disabled slot configurations.
  Columns: slot-id, context, context-id, configuration-id
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dw="http://www.demandware.com/xml/impex/slot/2008-09-08"
    exclude-result-prefixes="dw">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/dw:slot-configurations">
        <xsl:text>Slot Type,Context (Category),Slot,Configuration,Start Date,End Date,Content Asset&#10;</xsl:text>
        <xsl:apply-templates select="dw:slot-configuration[dw:enabled-flag = 'false']">
            <xsl:sort select="@context"/>
            <xsl:sort select="@context-id"/>
            <xsl:sort select="@slot-id"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="dw:slot-configuration">
        <!-- Quote each field and escape internal quotes for valid CSV output. -->
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(@context), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(@context-id), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(@slot-id), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(@configuration-id), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="dw:schedule/dw:start-date"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="dw:schedule/dw:end-date"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="dw:content/dw:content-assets/dw:content-asset/@content-id"/><xsl:text>"&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>