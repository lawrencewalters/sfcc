<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
<inventory 
    xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31">
    <inventory-list>
        <header list-id="inventory">
            <default-instock>false</default-instock>
            <description>Product Sku Inventory</description>
            <use-bundle-inventory-only>false</use-bundle-inventory-only>
            <on-order>false</on-order>
        </header>
        <records>
           <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </records></inventory-list></inventory>
    </xsl:template>

    <xsl:template match="dw:header" />

    <xsl:template match="dw:product"/>

    <xsl:template match="dw:product[contains('000072|000173|000345|000484|000637|000651|000656|000780|001715|007847|007872|007878|007909|007984|007990|007993|030085|031430|035435|049175|059207|740773|740804|740805|749544|757104|755967',@product-id)]">
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
            <record product-id="{current()/@product-id}">
                <allocation>9999999</allocation>
                <perpetual>false</perpetual>
                <preorder-backorder-handling>none</preorder-backorder-handling>
                <preorder-backorder-allocation>0</preorder-backorder-allocation>
                <ats>9999999</ats>
                <on-order>0</on-order>
                <turnover>0</turnover>
            </record>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>