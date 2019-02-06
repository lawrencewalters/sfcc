<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" 
    exclude-result-prefixes="dw"
    >
    
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
<pricebooks xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31">
    <pricebook>
        <header pricebook-id="MW-monthly-SB">
            <currency>USD</currency>
            <display-name xml:lang="x-default">Default web prices for the site. Browsing will always show these prices</display-name>
            <online-flag>true</online-flag>
            <parent>MW-monthly-web</parent>
        </header>

        <price-tables>
           <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>

        </price-tables>
    </pricebook>
</pricebooks>

    </xsl:template>

    <xsl:template match="dw:header" />

    <xsl:template match="dw:product"/>

    <xsl:template match="dw:product[contains('000072|000173|000345|000484|000637|000651|000656|000780|001715|007847|007872|007878|007909|007984|007990|007993|030085|031430|035435|049175|059207|740773|740804|740805|749544|757104',@product-id)]">
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
            <price-table product-id="{current()/@product-id}">
                <amount quantity="1"><xsl:value-of select="format-number(floor((count(preceding::dw:product) mod 3000) div 150) + 4,'00.00')"/></amount>
                <price-info>SB</price-info>
            </price-table>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>