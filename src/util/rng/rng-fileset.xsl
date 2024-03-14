<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:rng="http://relaxng.org/ns/structure/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns="http://www.daisy.org/z3998#"
        exclude-result-prefixes="xs rng"
        > 
                
        <xsl:output method="xml" omit-xml-declaration="no" indent="yes" standalone="yes"/>
        
        <xsl:template match="rng:grammar | rng:element">
            <xsl:call-template name="gatherSchema">
                <xsl:with-param name="schemas" select="."/>
                <xsl:with-param name="includes"
                    select="document(/rng:grammar//rng:include/@href | //rng:externalRef/@href)"/>
            </xsl:call-template>
        </xsl:template>
        
        <xsl:template name="gatherSchema">
            <xsl:param name="schemas"/>
            <xsl:param name="includes"/>
            <xsl:choose>
                <xsl:when test="count($schemas) &lt; count($schemas | $includes)">    
                    <xsl:call-template name="gatherSchema">     
                        <xsl:with-param name="schemas" select="$schemas | $includes"/>     
                        <xsl:with-param 
                            name="includes" 
                            select="document($includes/rng:grammar//rng:include/@href | $includes//rng:externalRef/@href)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>    
                    <xsl:call-template name="output">
                        <xsl:with-param name="schemas" select="$schemas"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
        <xsl:template name="output">
            <xsl:param name="schemas"/>
            <filelist> 
                <xsl:for-each select="$schemas">
                    <xsl:variable name="url" as="xs:string" select="string(document-uri(/))"/>
                    <file uri="{$url}"/>
                </xsl:for-each>
            </filelist>
        </xsl:template>
        
</xsl:stylesheet>