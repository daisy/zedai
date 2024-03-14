<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Null stylesheet to test/demonstrate XInclude
    jpritchett@rfbd.org
    12 Jan 2009
    
    When run on the XInclude driver document, the output should be the complete merged document
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
    xmlns="http://www.w3.org/2002/06/xhtml2/" xmlns:d="http://www.daisy.org/ns/z3986/2008/">
    <xsl:output method="xml"  indent="yes"   />
    <xsl:template match="*">
        <xsl:element name="{name()}">
            <xsl:copy-of select="namespace::*" />
            <xsl:copy-of select="@*" />
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="processing-instruction()" /> <!-- This strips out the oXygen processing instructions -->
</xsl:stylesheet>
