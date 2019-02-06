<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/customer/2006-10-31" >
    <xsl:output method="xml"/>

   <!-- Identity transform -->
   <xsl:template match="@* | node()">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
   </xsl:template>
    <!-- add a new custom attribute using first 5 digits of postal-code of preferred address -->
   <xsl:template match="dw:custom-attributes/dw:custom-attribute[1]">
      <xsl:copy-of select="."/>
      <xsl:element name="custom-attribute"
      namespace="http://www.demandware.com/xml/impex/customer/2006-10-31">
      <xsl:attribute name="attribute-id">billingAddress</xsl:attribute>
      {"postalCode":"<xsl:value-of select="substring(../../../dw:addresses/dw:address[@preferred='true'][1]/dw:postal-code,1,5)"/>"}</xsl:element>
   </xsl:template>
</xsl:stylesheet>