<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.0" exclude-result-prefixes="db">
    
    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" />
        
    <xsl:template match="db:section">
        <div class="section"><xsl:apply-templates /></div>
    </xsl:template>    
    
    <xsl:template match="db:para">
        <p><xsl:apply-templates /></p>
    </xsl:template>
    
    <xsl:template match="db:programlisting">
        <div><pre xml:space="preserve"><xsl:apply-templates /></pre></div>
    </xsl:template>
    
    <xsl:template match="db:emphasis">
        <em><xsl:apply-templates /></em>
    </xsl:template>
    
    <xsl:template match="db:itemizedlist">
        <ul><xsl:apply-templates /></ul>
    </xsl:template>
    
    <xsl:template match="db:orderedlist">
        <ol><xsl:apply-templates /></ol>
    </xsl:template>
    
    <xsl:template match="db:listitem">
        <li><xsl:apply-templates /></li>
    </xsl:template>
    
    <xsl:template match="db:code">
        <code><xsl:apply-templates /></code>
    </xsl:template>
    
    <xsl:template match="db:bridgehead">
        <h4><xsl:apply-templates /></h4>
    </xsl:template>
    
    <xsl:template match="db:link">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="@xlink:href"/>
            </xsl:attribute>
            <xsl:apply-templates />
        </a>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:copy />
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:message terminate="yes">
            Unmatched element in /doc/longdescs/docbook2xhtml-lite.xsl: <xsl:value-of select="local-name(.)"/>
        </xsl:message>
    </xsl:template>
        
</xsl:stylesheet>
