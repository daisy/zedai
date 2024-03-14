<?xml version="1.0" encoding="UTF-8"?>
<!--
    ZedAI_docbook2xhtml.xsl:  customization layer to DocBook5 XSLTs for ZedAI spec
    jpritchett@rfbd.org
    1 April 2009
    Revised, 8 May 2009
        * Added noXHTML2 feature
    Revised, 13 May 2009
        * Added http-equiv metadata to force character encoding
    Revised, 28 May 2009
        * Added custom styling for editor credit on title page
        * Added appendices to the @conformance template
    Revised, 29 May 2009
        * Added bibliographies to the @conformance template
        * Conformance language is now context sensitive

    Features:
        * remark[@role='todo'] is converted to span[@class='todo'] (for styling purposes)
        * Parts of the document with @conformance set will now spit out a "This section is ..." line
        * Paragraphs in the document with @condition='noXHTML2' will now spit out a note regarding the
    dependency, and will set para/@style to "noXHTML2"
        * The editor credit on the title page has custom styling
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:exsl="http://exslt.org/common"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns="http://www.w3.org/1999/xhtml">
    
    <xsl:import href="xhtml-1_1/docbook.xsl "/>
    
    <xsl:output method="xhtml" 
        encoding="UTF-8" 
        omit-xml-declaration="no"
        indent="yes"
        exclude-result-prefixes="saxon db exsl"/>

    <xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title
book      toc,title,example
chapter   title
part      toc,title
preface   title
qandadiv  toc
qandaset  toc
reference toc,title
sect1     toc
sect2     toc
sect3     toc
sect4     toc
sect5     toc
set       toc,title
    </xsl:param>
 
 
 
    <!-- ============================================================================= -->
    <!-- override to order as a spec document -->
    
    <xsl:template match="db:book">
        <xsl:call-template name="id.warning"/>
        
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="." mode="common.html.attributes"/>
            <xsl:if test="$generate.id.attributes != 0">
                <xsl:attribute name="id">
                    <xsl:call-template name="object.id"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:call-template name="book.titlepage"/>
            
            <xsl:if test="db:info/db:annotation[@xml:id='status']">
            	<xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">Status of this Document</xsl:element>
            	<xsl:apply-templates select="db:info/db:annotation[@xml:id='status']/*"/>
            </xsl:if>
 
            <xsl:variable name="toc.params">
                <xsl:call-template name="find.path.params">
                    <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:call-template name="make.lots">
                <xsl:with-param name="toc.params" select="$toc.params"/>
                <xsl:with-param name="toc">
                    <xsl:call-template name="division.toc">
                        <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:apply-templates/>
            
        </xsl:element>
    </xsl:template>
    
<!-- ============================================================================= -->
    <!-- set the target location for a tags that link externally -->
    
    <xsl:variable name="ulink.target">_self</xsl:variable>
    
    
<!-- ============================================================================= -->
    <!-- Fill in the docbook placeholder user.head.content template to add an http-equiv meta
        element -->
    
    <xsl:template name="user.head.content">        
        <xsl:element name="meta" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="http-equiv">Content-Type</xsl:attribute>
            <xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    
    <!-- ============================================================================= -->
    <!-- override title page templates to remove all the excess divs -->
    
    
    <xsl:template name="book.titlepage">
            <xsl:variable name="recto.content">
                <xsl:call-template name="book.titlepage.before.recto"/>
                <xsl:call-template name="book.titlepage.recto"/>
            </xsl:variable>
            <xsl:variable name="recto.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
                <xsl:copy-of select="$recto.content"/>
            </xsl:if>
            <xsl:variable name="verso.content">
                <xsl:call-template name="book.titlepage.before.verso"/>
                <xsl:call-template name="book.titlepage.verso"/>
            </xsl:variable>
            <xsl:variable name="verso.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
                <xsl:copy-of select="$verso.content"/>
            </xsl:if>
            <xsl:call-template name="book.titlepage.separator"/>
    </xsl:template>
    
    <xsl:template match="db:title" mode="book.titlepage.recto.auto.mode">
            <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    </xsl:template>
    
    <xsl:template name="chapter.titlepage">
            <xsl:variable name="recto.content">
                <xsl:call-template name="chapter.titlepage.before.recto"/>
                <xsl:call-template name="chapter.titlepage.recto"/>
            </xsl:variable>
            <xsl:variable name="recto.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
                <xsl:copy-of select="$recto.content"/>
            </xsl:if>
            <xsl:variable name="verso.content">
                <xsl:call-template name="chapter.titlepage.before.verso"/>
                <xsl:call-template name="chapter.titlepage.verso"/>
            </xsl:variable>
            <xsl:variable name="verso.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
                <xsl:copy-of select="$verso.content"/>
            </xsl:if>
            <xsl:call-template name="chapter.titlepage.separator"/>
    </xsl:template>
    
    <xsl:template match="db:title" mode="chapter.titlepage.recto.auto.mode">
            <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
    </xsl:template>
    
    
    <!-- ============================================================================= -->
    <!-- override section title page templates to remove all the excess divs and correct heading levels -->
    
    <xsl:template name="section.titlepage">
        
            <xsl:variable name="recto.content">
                <xsl:call-template name="section.titlepage.before.recto"/>
                <xsl:call-template name="section.titlepage.recto"/>
            </xsl:variable>
            <xsl:variable name="recto.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
                <xsl:copy-of select="$recto.content"/>
            </xsl:if>
            <xsl:variable name="verso.content">
                <xsl:call-template name="section.titlepage.before.verso"/>
                <xsl:call-template name="section.titlepage.verso"/>
            </xsl:variable>
            <xsl:variable name="verso.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
                <xsl:copy-of select="$verso.content"/>
            </xsl:if>
            <xsl:call-template name="section.titlepage.separator"/>
    
    </xsl:template>
    
    <xsl:template match="db:title" mode="section.titlepage.recto.auto.mode">
         <xsl:apply-templates select="." mode="section.titlepage.recto.mode"/>
    </xsl:template>
    
    <xsl:template name="section.level">
        <xsl:param name="node" select="."/>
        <xsl:choose>
            <xsl:when test="local-name($node)='sect1'">1</xsl:when>
            <xsl:when test="local-name($node)='sect2'">2</xsl:when>
            <xsl:when test="local-name($node)='sect3'">3</xsl:when>
            <xsl:when test="local-name($node)='sect4'">4</xsl:when>
            <xsl:when test="local-name($node)='sect5'">5</xsl:when>
            <xsl:when test="local-name($node)='section'">
                <xsl:choose>
                    <!-- bumping all values up one to make lower than the chapter -->
                    <xsl:when test="$node/../../../../../../db:section">6</xsl:when>
                    <xsl:when test="$node/../../../../../db:section">6</xsl:when>
                    <xsl:when test="$node/../../../../db:section">5</xsl:when>
                    <xsl:when test="$node/../../../db:section">4</xsl:when>
                    <xsl:when test="$node/../../db:section">3</xsl:when>
                    <xsl:when test="$node/../db:section">2</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name($node)='refsect1' or
                local-name($node)='refsect2' or
                local-name($node)='refsect3' or
                local-name($node)='refsection' or
                local-name($node)='refsynopsisdiv'">
                <xsl:call-template name="refentry.section.level">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="local-name($node)='simplesect'">
                <xsl:choose>
                    <xsl:when test="$node/../../db:sect1">2</xsl:when>
                    <xsl:when test="$node/../../db:sect2">3</xsl:when>
                    <xsl:when test="$node/../../db:sect3">4</xsl:when>
                    <xsl:when test="$node/../../db:sect4">5</xsl:when>
                    <xsl:when test="$node/../../db:sect5">5</xsl:when>
                    <xsl:when test="$node/../../db:section">
                        <xsl:choose>
                            <xsl:when test="$node/../../../../../db:section">5</xsl:when>
                            <xsl:when test="$node/../../../../db:section">4</xsl:when>
                            <xsl:when test="$node/../../../db:section">3</xsl:when>
                            <xsl:otherwise>2</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    
<!-- ============================================================================= -->
    <!-- remark[@role='todo'] = span[@class='todo'] -->

    <!-- Note:  template copied from inline.xsl and modified -->
    <xsl:template match="db:remark[@role='todo']">
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
    <!-- remove hyperlinks from terms -->
    
    <xsl:template match="db:xref[starts-with(@linkend, 'term_')]" priority="1">
        <xsl:variable name="id" select="@linkend"/>
        <xsl:value-of select="//db:varlistentry[@xml:id=$id]/db:term/node()[normalize-space(.)]"/>
    </xsl:template>


<!-- ============================================================================= -->
    <!-- For chapters, preface, sections, and appendices that have @conformance, add a "This section is ..." line -->
    <!-- We match on title so that we can insert the text after the heading -->
    <xsl:template
        match="db:chapter/db:title|db:preface/db:title|db:section/db:title|db:appendix/db:title|db:bibliography/db:title">
        <xsl:apply-imports />
        <!-- Do everything the normal transform does before adding more text -->
        <xsl:variable name="conformanceLevel" select="../@conformance" />
        <xsl:variable name="parentName" select="local-name(..)"/>
        <xsl:variable name="structureName">
            <xsl:choose>
                <xsl:when test="$parentName='preface' or $parentName='chapter' or $parentName='bibliography'">
                    <xsl:text>section</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parentName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$conformanceLevel != ''">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">
                    <xsl:value-of select="$conformanceLevel" />
                </xsl:attribute> This <xsl:value-of select="$structureName" /> is
                    <xsl:value-of select="$conformanceLevel" />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- ============================================================================= -->
    <!-- add daisy logo -->
    
    <xsl:template name="user.header.content">
        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="href">http://www.daisy.org/</xsl:attribute>
            <xsl:element name="img">
                <xsl:attribute name="src">http://www.daisy.org/images/daisylogo-w.gif</xsl:attribute>
                <xsl:attribute name="alt">DAISY Consortium Logo - Link to Home Page</xsl:attribute>
                <xsl:attribute name="width">150</xsl:attribute>
                <xsl:attribute name="height">110</xsl:attribute>
                <xsl:attribute name="border">0</xsl:attribute>
                <xsl:attribute name="class">logo</xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>    
    
    
    <!-- ============================================================================= -->
    <!-- format release info and publication date as single heading per w3c -->
    
    <xsl:template match="db:releaseinfo" mode="titlepage.mode">
        <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">releaseinfo</xsl:attribute>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="../db:pubdate/node()"/>
        </xsl:element>
        
        <xsl:apply-templates select="../db:annotation[@role='specLinks']/*"/>
        
        <xsl:if test="../db:annotation[@xml:id='editors']">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">edLabel</xsl:attribute>
                <xsl:text>Editors:</xsl:text>
            </xsl:element>
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">editors</xsl:attribute>
                <xsl:apply-templates select="../db:annotation[@xml:id='editors']/*"/>
            </xsl:element>
        </xsl:if>
        
        <xsl:element name="hr" namespace="http://www.w3.org/1999/xhtml"/>
    </xsl:template>
    
    <xsl:template match="db:pubdate" mode="titlepage.mode"/>
     
    <!-- ============================================================================= -->
    <!-- override titlepage hr separators -->
   
    <xsl:template name="book.titlepage.separator"/>
    <xsl:template name="section.titlepage.separator"/>
    
    
    <!-- ============================================================================= -->
    <!-- Change the way credits are done for the editor -->
    <xsl:template match="editor" mode="titlepage.mode">
        <div>
            <xsl:apply-templates select="." mode="class.attribute"/>
            <xsl:if test="self::editor[position()=1] and not($editedby.enabled = 0)">
                <span class="editedby"><xsl:call-template
                    name="gentext.edited.by"/>&#160;&#160;</span>
            </xsl:if>
            <span>
                <xsl:apply-templates select="." mode="class.attribute"/>
                <xsl:choose>
                    <xsl:when test="orgname">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:when test="personname and affiliation">
                        <xsl:call-template name="person.name"/>, <xsl:apply-templates mode="titlepage.mode" select="affiliation"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="person.name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="not($contrib.inline.enabled = 0)">
                <xsl:apply-templates mode="titlepage.mode" select="contrib"/>
            </xsl:if>
            <xsl:if test="not($blurb.on.titlepage.enabled = 0)">
                <xsl:choose>
                    <xsl:when test="$contrib.inline.enabled = 0">
                        <xsl:apply-templates mode="titlepage.mode" select="contrib|authorblurb|personblurb"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="titlepage.mode" select="authorblurb|personblurb"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="affiliation" mode="titlepage.mode">
        <span>
            <xsl:apply-templates select="." mode="class.attribute"/>
            <xsl:apply-templates mode="titlepage.mode"/>
        </span>
    </xsl:template>
    
    <xsl:template match="orgname" mode="titlepage.mode">
        <span>
            <xsl:apply-templates select="." mode="class.attribute"/>
            <xsl:apply-templates mode="titlepage.mode"/>
        </span>
    </xsl:template>
    
    
</xsl:stylesheet>
