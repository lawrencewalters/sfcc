<!-- This XSLT is designed to trim coupons for a site by taking specific campaigns from a predefined list. It limits the number of coupon-codes to create smaller files.

Prerequisites:
- complete coupons XML
- list of coupons you want to include (this doesn't do "random")
- Saxon HE XSLT parser (used Saxon-HE 9.9.1.7N from Saxonica see http://www.saxonica.com), Transform.exe is on path

Usage of this XSLT:
Transform.exe -s:/path/to/coupons.xml -xsl:generate-trimmed-coupons.xslt couponIds='10offsale|vip-discount' > coupons-trimmed.xml

-OR-

# get coupon codes from a promotions xml - ideally one that you've already trimmed
grep -o 'coupon-id=\"[^"]*' data/promotions.xml |sort|uniq|sed 's/coupon-id="//' > data/coupons.txt

cat data/coupons.txt | xargs -t Transform.exe -s:data/coupons.xml -xsl:generate-trimmed-coupons.xslt > data/coupons-trimmed.xml

-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/coupon/2008-06-17" exclude-result-prefixes="dw">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="couponIds"/>
    <xsl:variable name="coupons" select="/dw:coupons"/>    
    
    <xsl:template match="dw:coupons">
        <coupons xmlns="http://www.demandware.com/xml/impex/coupon/2008-06-17" >
            <xsl:apply-templates select="dw:coupon"/>
            <xsl:apply-templates select="dw:coupon-codes"/>
        </coupons>
    </xsl:template>
    
    <xsl:template match="dw:coupon"/>
    <xsl:template match="dw:coupon[./dw:enabled-flag=true() and contains($couponIds, @coupon-id)]">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="dw:coupon-codes">
        <!-- make sure our coupon is enabled before copying it's codes -->
        <xsl:if test="$coupons/dw:coupon[@coupon-id=current()/@coupon-id]/dw:enabled-flag=true()">
            <xsl:copy>
                <xsl:attribute name="coupon-id"><xsl:value-of select="@coupon-id"/></xsl:attribute>
                <xsl:apply-templates select="dw:code"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <!-- make a copy of the first 100 codes -->
    <xsl:template match="dw:code[position() &lt;= 100]">
        <xsl:copy-of select="."/>
    </xsl:template>
    <!-- do nothing with all the other codes -->
    <xsl:template match="dw:code[position() &gt; 100]"/>
</xsl:stylesheet>