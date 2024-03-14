<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:zai="http://www.daisy.org/z3986/2010/"
    xmlns:sel="http://www.daisy.org/z3986/2010/auth/features/select/"
    xmlns:fnk="http://www.daisy.org/z3986/2010/xsl/functions/"
    xpath-default-namespace="http://www.daisy.org/z3986/2010/" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs zai sel" version="2.0">

    <!-- NB: This is NOT a standalone XSLT.
    
    This file and the included file 'CSFunctionSet.xsl' is meant to be used as modules in a transformation scenario with ZedAI files 
    using the Content Selection Feature.
    
    TODO:
        * Currently the operator names 'or' and 'and' are used as tokens when separating the functions of a Conditional Expression.
            This means that a function such as xyz:wheatherIsNice('sun and wind') is not allowed.
        * Improved handling of white space, an expression such as expr="not( zyx:function('hello'))" will probably not be treated properly due to the space
            after not(. Should be trivial to fix with better regexps.
        * Try to rewrite to make it possible to use tunnel parameters when evaluating functions.
    -->
    
    <!-- Specify a parameter containing information about what this transform is generating -->
    <xsl:param name="outputFormat" as="xs:string" select="'PDFx'" />

    <!-- Include the different function handlers -->
    <xsl:include href="content-selection-function-set-handler.xsl" />


    <xsl:template match="sel:select">
        <xsl:param name="demoen" as="xs:string" tunnel="yes"></xsl:param>
        <xsl:variable name="trueWhens" as="element()*"
            select="sel:when[fnk:exprIsTrue(@expr,//head)]" />
        <xsl:choose>
            <xsl:when test="$trueWhens">
                <!-- Pick the first true sel:when -->
                <xsl:apply-templates select="$trueWhens[1]/*" />
            </xsl:when>
            <xsl:otherwise>
                <!-- If no true sel:when, then use sel:otherwise -->
                <xsl:apply-templates select="sel:otherwise" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="fnk:exprIsTrue" as="xs:boolean">
        <!-- Does the Conditional Expression (i.e. the value of the @expr) evaulate to true()? -->
        <xsl:param name="expression" as="xs:string" />
        <xsl:param name="ZAIhead" as="element()" />
        <xsl:variable name="e.normalized" as="xs:string" select="normalize-unicode($expression)" />
        <xsl:choose>
            <xsl:when test="fnk:exprIsOK($e.normalized,$ZAIhead)">
                <xsl:variable name="functions" as="xs:string+"
                    select="tokenize($expression,' (and|or) ')" />
                <xsl:choose>
                    <xsl:when test="contains($e.normalized,' and ')">
                        <xsl:value-of
                            select="every $function in $functions satisfies fnk:functionIsTrue($function)"
                         />
                    </xsl:when>
                    <xsl:when test="contains($e.normalized,' or ')">
                        <xsl:value-of
                            select="some $function in $functions satisfies fnk:functionIsTrue($function)"
                         />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- It's only one function in this expression -->
                        <xsl:value-of select="fnk:functionIsTrue($functions)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>The Content Select expression "<xsl:value-of select="$e.normalized" />" is
                    not a valid expression</xsl:message>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fnk:exprIsOK" as="xs:boolean">
        <!-- Is the Conditional Expression (i.e. the value of the @expr) valid? -->
        <xsl:param name="CE" as="xs:string" />
        <xsl:param name="ZAIhead" as="element()" />
        <!-- This function could be improved by using xsl:analyze-string to tokenize. Would then be possible to avoid using or/and as tokens.
            First bullet on the TODO-list above
            -->
        <xsl:value-of
            select="
            $CE ne ''   (: not an empty string :) 
            and 
            not(contains($CE,' and ') and contains($CE,' or '))    (: Not both and and or in the same expression :)
            and
            (every $function in tokenize($CE,' (and|or) ') satisfies matches($function,'^(\i+:\i+\(.*\))|(not\(\i+:\i+\(.*\)\))$')) 
            " />
    </xsl:function>
    
    <xsl:function name="fnk:functionIsTrue" as="xs:boolean">
        <!-- Evaluate a single function -->
        <xsl:param name="function" as="xs:string" />
        <xsl:variable name="not" as="xs:boolean" select="starts-with($function,'not(')" />
        <xsl:variable name="f" as="xs:string">  <!-- Strip away the not(...) part if present -->
            <xsl:analyze-string select="$function" regex="^not\((.+)\)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)" />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="." />
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="f.evaluated" as="xs:boolean">
            <xsl:choose>
                <!-- Delegate to the proper template based on the function QName -->
                <xsl:when test="starts-with($f,'offs:outputFormat(')">
                    <xsl:call-template name="evaluateCSoutputFormat">
                        <xsl:with-param name="arg">
                            <xsl:analyze-string select="$f" regex=".+\((.*)\)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)" />
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="starts-with($f,'tcgfs:targetConsumerGroup(')">
                    <xsl:call-template name="evaluateCStargetConsumerGroup">
                        <xsl:with-param name="arg">
                            <xsl:analyze-string select="$f" regex=".+\((.*)\)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)" />
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="starts-with($f,'ptfs:parameterTest(')">
                    <xsl:call-template name="evaluateCSparameterTest">
                        <xsl:with-param name="arg">
                            <xsl:analyze-string select="$f" regex=".+\((.*)\)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)" />
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="if ($not) then not($f.evaluated) else $f.evaluated" />
    </xsl:function>

</xsl:stylesheet>
