<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dw="http://www.demandware.com/xml/impex/catalog/2006-10-31" exclude-result-prefixes="dw">
    <xsl:output method="xml"/>
    <xsl:variable name="catalog" select="/dw:catalog"/>
    <xsl:template match="dw:catalog">
        <catalog 
            xmlns="http://www.demandware.com/xml/impex/catalog/2006-10-31" catalog-id="colony-master-catalog">
    <header>
        <image-settings>
            <internal-location base-path="/"/>
            <view-types>
                <view-type>large</view-type>
                <view-type>rollover</view-type>
                <view-type>swatch</view-type>
            </view-types>
            <variation-attribute-id>color</variation-attribute-id>
            <alt-pattern>${productname}, ${variationvalue}, ${viewtype}</alt-pattern>
            <title-pattern>${productname}, ${variationvalue}</title-pattern>
        </image-settings>
    </header>
            <xsl:apply-templates select="dw:header"/>
            <xsl:apply-templates select="dw:product"/>
        </catalog>
    </xsl:template>
    <xsl:template match="dw:header" />
    <xsl:template match="dw:product"/>
    <xsl:template match="dw:product[contains('000072|000173|000345|000484|000637|000651|000656|000780|001715|007847|007872|007878|007909|007984|007990|007993|030085|031430|035435|049175|059207|740773|740804|740805|749544|757104|752998|DE0350|700350|700352|0F8015|700029|00F015|00F008|755967|728481|000007|000465|003298|003363|025703|043204|047286|063911|069296|089096|089105|606525|606534|608262|608271|608846|609327|609410|610826|611723|611783|613669|613962|619101|626591|626595|632686|632692|641851|642373|642628|642696|642705|642783|642792|642858|642868|642908|642917|642931|642940|642995|643005|643353|643389|644186|644187|644772|644781|644940|644950|647369|647379|647455|647460|647650|649415|649424|650058|650068|650978|652259|656655|656663|701606|705606|717510|718309|719897|719995|722462|722517|722518|723377|724014|727054|727992|727993|728116|728728|728729|732520|736919|737059|737879|737940|737942|738351|739047|741655|741778|741779|741842|742630|742904|743845|745354|745447|746168|746169|746176|746291|746333|746592|746610|746611|746704|746835|747064|747140|748722|748889|749765|749766|750070|750256|750647|750714|751651|752831|752862|752863|753117|753252|753253|754407|754743|756197|756351|756352|756418|756432|756433|756532|756533|756534|756535|756671|756773|756887|756888|757084|757419|757422|757614|758011|758146|760805|802225|802231|863152|930263|930372|936121|936211|943139|986379|986480|995947|996006|998727|055126|055551|000159',@product-id)]">
        <xsl:variable name="masterProduct" select="."/>
        <xsl:for-each select="dw:variations/dw:variants/dw:variant">
            <xsl:if test="$catalog/dw:product[@product-id = current()/@product-id]">
                <xsl:copy-of select="$catalog/dw:product[@product-id = current()/@product-id]"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>