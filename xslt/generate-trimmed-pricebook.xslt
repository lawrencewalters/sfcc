<!-- given a list of product ids (hardcoded below) and a list of pricebook ids that appear in a pricebook XML (also hardcoded), generate a trimmed pricebook xml-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/pricebook/2006-10-31" 
    exclude-result-prefixes="dw" >
    
    <xsl:output method="xml"/>
    <xsl:template match="dw:pricebooks"><xsl:text>
</xsl:text>
        <pricebooks xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
            xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31"><xsl:text>
    </xsl:text>
            <xsl:apply-templates select="dw:pricebook" /><xsl:text>
</xsl:text>
        </pricebooks><xsl:text>
</xsl:text>
    </xsl:template>
   
  <xsl:template match="dw:pricebook" /> 
  <xsl:template match="dw:pricebook[./dw:header[contains('pricebook-id-list'|'pricebook-usd-sale',@pricebook-id)]]"><xsl:text>
  </xsl:text>
    <pricebook xmlns="http://www.demandware.com/xml/impex/pricebook/2006-10-31"><xsl:text>
    </xsl:text>
            <xsl:apply-templates select="dw:header" /><xsl:text>
    </xsl:text>
        <price-tables><xsl:text>
        </xsl:text>
        <xsl:apply-templates select="dw:price-tables" /><xsl:text>
    </xsl:text>
        </price-tables><xsl:text>
  </xsl:text>
    </pricebook>
    </xsl:template> 

    <xsl:template match="dw:header">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:price-tables">
        <xsl:apply-templates select="dw:price-table" />
    </xsl:template>
    
    <xsl:template match="dw:price-table" />
    <xsl:template match="dw:price-table[contains('variant-product-id1|variant-product-id2',@product-id)]">
        <xsl:copy-of select="."/><xsl:text>
      </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>