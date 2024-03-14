<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:zai="http://www.daisy.org/ns/z3986/authoring/"
    xmlns:sel="http://www.daisy.org/ns/z3986/authoring/features/select/"
    xmlns:fnk="http://www.daisy.org/z3986/2011/xsl/functions/"
    xpath-default-namespace="http://www.daisy.org/ns/z3986/authoring/" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs zai sel" version="2.0">

    <!-- Unfortunately, these named templates can not use tunnel parameters, as they are called through functions.
        This means that for a function such as evaluateCSoutputFormat() the argument must be compared with a global
        parameter ($$outputFormat) containg a string describing the outputformat currently being generated.
        
        In order to use tunnel parameters, the algoritm must be rewritten to avoid use of function, and base everything on templates
    -->
    <xsl:template name="evaluateCSoutputFormat">
        <xsl:param name="arg" as="xs:string" />

        <xsl:variable name="arg.noquotes" as="xs:string">
            <xsl:analyze-string select="$arg" regex="(&quot;|&apos;)">
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="$arg.noquotes eq $outputFormat" />
    </xsl:template>

    <xsl:template name="evaluateCStargetConsumerGroup">
        <xsl:param name="arg" as="xs:string" />
        
        <xsl:value-of select="true()" />
        <!-- TODO: Something similar to evaluateCSoutputFormat -->
    </xsl:template>

    <xsl:template name="evaluateCSparameterTest">
        <xsl:param name="arg" as="xs:string" />
        
        <xsl:value-of select="true()" />
        <!-- TODO: Write this function handler -->
    </xsl:template>
</xsl:stylesheet>
