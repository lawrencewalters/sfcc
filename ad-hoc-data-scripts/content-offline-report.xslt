<!--
generate a content library xml that only contains the folders and content assets that are offline
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dw="http://www.demandware.com/xml/impex/library/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="dw:library">
        <xsl:text>Folder,Content Asset ID,Display Name,Description,Languages&#10;</xsl:text>
        <xsl:apply-templates select="dw:content[dw:online-flag and not(dw:online-flag[normalize-space(.)='true'])]">
        <!-- <xsl:apply-templates select="dw:content[dw:online-flag = 'false']"> -->
            <xsl:sort select="dw:folder-links/dw:classification-link/@folder-id"/>
            <xsl:sort select="@id"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="dw:content">
        <xsl:text>"</xsl:text><xsl:value-of select="dw:folder-links/dw:classification-link/@folder-id"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(@content-id), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(dw:display-name[@xml:lang='x-default']), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="replace(string(dw:description[@xml:lang='x-default']), '&quot;', '&quot;&quot;')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="string-join(dw:custom-attributes/dw:custom-attribute[@attribute-id='body']/@xml:lang, '|')"/><xsl:text>",</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of
          select="string-join(
                    for $f in dw:online-flag
                    return concat(
                      if ($f/@site-id) then string($f/@site-id) else 'default',
                      '=',
                      normalize-space(string($f))
                    ),
                    '|'
                  )"/><xsl:text>"&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>