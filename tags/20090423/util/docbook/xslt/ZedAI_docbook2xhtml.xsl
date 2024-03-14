<?xml version="1.0" encoding="UTF-8"?>
<!--
    ZedAI_docbook2xhtml.xsl:  customization layer to DocBook5 XSLTs for ZedAI spec
    jpritchett@rfbd.org
    1 April 2009

    Features:
        * remark[@role='todo'] is converted to span[@class='todo'] (for styling purposes)
        * Parts of the document with @conformance set will now spit out a "This section is ..." line
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="xhtml-1_1/docbook.xsl "/>

<!-- ============================================================================= -->
    <!-- remark[@role='todo'] = span[@class='todo'] -->

    <!-- Note:  template copied from inline.xsl and modified -->
    <xsl:template match="remark[@role='todo']">
                <xsl:param name="content">
                    <xsl:call-template name="anchor"/>
                    <xsl:call-template name="simple.xlink">
                        <xsl:with-param name="content">
                            <xsl:apply-templates/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:param>
                <!-- * if you want output from the inline.charseq template wrapped in -->
                <!-- * something other than a Span, call the template with some value -->
                <!-- * for the 'wrapper-name' param -->
                <xsl:param name="wrapper-name">span</xsl:param>
        <xsl:if test="$show.comments != 0">
                <xsl:element name="{$wrapper-name}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">todo</xsl:attribute>
                    <xsl:call-template name="dir"/>
                    <xsl:call-template name="generate.html.title"/>
                    <xsl:copy-of select="$content"/>
                    <xsl:call-template name="apply-annotations"/>
                </xsl:element>
        </xsl:if>
    </xsl:template>

<!-- ============================================================================= -->
    <!-- For chapters, preface, and sections that have @conformance, add a "This section is ..." line -->
    <!-- We match on title so that we can insert the text after the heading -->
    <xsl:template match="chapter/title|preface/title|section/title">
        <xsl:apply-imports />           <!-- Do everything the normal transform does before adding more text -->
        <xsl:variable name="conformanceLevel" select="../@conformance" />
        <xsl:if test="$conformanceLevel != ''">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class"><xsl:value-of select="$conformanceLevel"/></xsl:attribute>
                This section is <xsl:value-of  select="$conformanceLevel"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
