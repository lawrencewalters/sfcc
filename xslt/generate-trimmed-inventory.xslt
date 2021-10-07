<!-- given a complete inventory xml file (id hardcoded below) and a list of variants (hardcoded below), pull real inventory records out and generate trimmed inventory XML-->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/inventory/2007-05-31" 
    exclude-result-prefixes="dw" >
    <xsl:output method="xml"/>
    <xsl:template match="dw:inventory"><xsl:text>
</xsl:text>
<inventory xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31"> <xsl:text>
    </xsl:text>
    <xsl:apply-templates select="dw:inventory-list" /><xsl:text>
</xsl:text>
</inventory><xsl:text>
</xsl:text>
    </xsl:template>
   
  <xsl:template match="dw:inventory-list" /> 
  <xsl:template match="dw:inventory-list[./dw:header[contains('us-inventory-list',@list-id)]]"><xsl:text>
  </xsl:text>
    <inventory-list xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31"><xsl:text>
    </xsl:text>
            <xsl:apply-templates select="dw:header" /><xsl:text>
    </xsl:text>
        <records><xsl:text>
        </xsl:text>
        <xsl:apply-templates select="dw:records" /><xsl:text>
    </xsl:text>
        </records><xsl:text>
  </xsl:text>
    </inventory-list>
    </xsl:template> 

    <xsl:template match="dw:header">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="dw:records">
        <xsl:apply-templates select="dw:record" />
    </xsl:template>
    
    <xsl:template match="dw:record" />
    <xsl:template match="dw:record[contains('variant-id-1|variant-id-2',@product-id)]">
        <record xmlns="http://www.demandware.com/xml/impex/inventory/2007-05-31" product-id="{@product-id}"><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:allocation" /><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:perpetual" /><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:preorder-backorder-handling" /><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:preorder-backorder-allocation" /><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:in-stock-datetime" /><xsl:text>
        </xsl:text>
        <xsl:copy-of select="dw:custom-attributes"/><xsl:text>
      </xsl:text>
        </record><xsl:text>
      </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>