<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:d="http://www.daisy.org/ns/z3986/authoring/">
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8" version="1.0" />
    
    <xsl:param name="profile-machinename" required="yes" />         
    <xsl:param name="rd-summary" required="yes" />          <!-- path to rd-summary doc -->
    
    <!-- params that say which feature RD URIs to include -->
    <xsl:param name="feature-its-ruby" required="yes" />        <!-- boolean -->
    <xsl:param name="feature-ssml" required="yes" />            <!-- boolean -->
    <xsl:param name="feature-forms" required="yes" />           <!-- boolean -->
    <xsl:param name="feature-mathml" required="yes" />          <!-- boolean -->
    <xsl:param name="feature-select" required="yes" />          <!-- boolean -->
    <xsl:param name="feature-rend" required="yes" />            <!-- boolean -->
    <xsl:param name="feature-svg-cdr" required="yes" />         <!-- boolean -->
    
    <xsl:variable name="rd-summary-doc" select="document($rd-summary)" />
        
    <xsl:template match="d:meta[@rel='z3986:profile']">        
        <xsl:element name="meta" namespace="http://www.daisy.org/ns/z3986/authoring/">
            <xsl:attribute name="rel">z3986:profile</xsl:attribute>
            <xsl:attribute name="resource"><xsl:value-of select="$rd-summary-doc//profile[@machinename eq $profile-machinename]/@rd-uri"/></xsl:attribute>
            <xsl:text>
                
            </xsl:text>
            <xsl:comment>supported features (remove if not used)</xsl:comment>
            <xsl:text>
                
            </xsl:text>
            <xsl:if test="$feature-its-ruby eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">its-ruby</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-ssml eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">ssml</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-forms eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">forms</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-mathml eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">mathml</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-select eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">select</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-rend eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">rend</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$feature-svg-cdr eq 'true'">
                <xsl:call-template name="feature-rd-meta-uri">
                    <xsl:with-param name="f_machinename">svg-cdr</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:element>    
    </xsl:template>    
    
    <xsl:template name="feature-rd-meta-uri">
        <xsl:param name="f_machinename" />        
        <xsl:element name="meta" namespace="http://www.daisy.org/ns/z3986/authoring/">
            <xsl:attribute name="rel">z3986:feature</xsl:attribute>
            <xsl:attribute name="resource"><xsl:value-of select="$rd-summary-doc//feature[@machinename eq $f_machinename]/@rd-uri"/></xsl:attribute>
        </xsl:element>                
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>    