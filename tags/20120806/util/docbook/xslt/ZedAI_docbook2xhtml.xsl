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
    
    <xsl:param name="formal.title.placement">
        figure after
        example before
        equation before
        table before
        procedure before
        task before
    </xsl:param>
	<xsl:param name="autotoc.label.separator">&#160;</xsl:param>
	
 
 
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
        <xsl:if test="$conformanceLevel = 'informative' and parent::db:appendix">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">
                    <xsl:value-of select="$conformanceLevel" />
                </xsl:attribute>
                (This appendix is not part of ANSI/NISO Z39.96-2012. It is included for information only.)
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- ============================================================================= -->
    <!-- add daisy logo -->
    
    <xsl:template name="user.header.content">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="style">float: left</xsl:attribute>
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
        </xsl:element>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="style">float: right</xsl:attribute>
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="href">http://www.niso.org/workrooms/daisy</xsl:attribute>
                <xsl:element name="img">
                    <xsl:attribute name="src">http://www.niso.org/images/headermain/logo.png</xsl:attribute>
                    <xsl:attribute name="alt">NISO - Link to the DAISY Standard Workroom</xsl:attribute>
                    <xsl:attribute name="width">213</xsl:attribute>
                    <xsl:attribute name="height">93</xsl:attribute>
                    <xsl:attribute name="border">0</xsl:attribute>
                    <xsl:attribute name="class">logo</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:element name="br" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="style">clear: both</xsl:attribute>
        </xsl:element>
    </xsl:template>    
    
    
    <!-- ============================================================================= -->
    <!-- format release info and publication date as single heading per w3c -->
    
    <xsl:template match="db:releaseinfo" mode="titlepage.mode">
        <!-- <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">releaseinfo</xsl:attribute>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="../db:pubdate/node()"/>
        </xsl:element> -->
        
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

    <!-- add templates as per htmltbl.xsl in order to get id and role -->
       
    <xsl:template mode="htmlTableAtt" match="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="." /></xsl:attribute>        
    </xsl:template>
    
    <xsl:template mode="htmlTableAtt" match="@role">
        <xsl:attribute name="class"><xsl:value-of select="." /></xsl:attribute>        
    </xsl:template>
    
    
    <!-- override to add colons to figure/example titles -->
    
    <xsl:param name="local.l10n.xml" select="document('')"/>
    <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
        <l:l10n language="en">
            <l:gentext key="Bibliography" text=""/>
            <l:gentext key="bibliography" text=""/>
            <l:context name="title">
                <l:template name="abstract" text="%t"/>
                <l:template name="acknowledgements" text="%t"/>
                <l:template name="answer" text="%t"/>
                <l:template name="appendix" text="Appendix %n (normative) %t"/>
                <l:template name="article" text="%t"/>
                <l:template name="authorblurb" text="%t"/>
                <l:template name="bibliodiv" text="%t"/>
                <l:template name="biblioentry" text="%t"/>
                <l:template name="bibliography" text="%t"/>
                <l:template name="bibliolist" text="%t"/>
                <l:template name="bibliomixed" text="%t"/>
                <l:template name="bibliomset" text="%t"/>
                <l:template name="biblioset" text="%t"/>
                <l:template name="blockquote" text="%t"/>
                <l:template name="book" text="%t"/>
                <l:template name="calloutlist" text="%t"/>
                <l:template name="caution" text="%t"/>
                <l:template name="chapter" text="%n %t"/>
                <l:template name="colophon" text="%t"/>
                <l:template name="dedication" text="%t"/>
                <l:template name="equation" text="Equation %n. %t"/>
                <l:template name="example" text="Example %n: %t"/>
                <l:template name="figure" text="Figure %n: %t"/>
                <l:template name="foil" text="%t"/>
                <l:template name="foilgroup" text="%t"/>
                <l:template name="formalpara" text="%t"/>
                <l:template name="glossary" text="%t"/>
                <l:template name="glossdiv" text="%t"/>
                <l:template name="glosslist" text="%t"/>
                <l:template name="glossentry" text="%t"/>
                <l:template name="important" text="%t"/>
                <l:template name="index" text="%t"/>
                <l:template name="indexdiv" text="%t"/>
                <l:template name="itemizedlist" text="%t"/>
                <l:template name="legalnotice" text="%t"/>
                <l:template name="listitem" text=""/>
                <l:template name="lot" text="%t"/>
                <l:template name="msg" text="%t"/>
                <l:template name="msgexplan" text="%t"/>
                <l:template name="msgmain" text="%t"/>
                <l:template name="msgrel" text="%t"/>
                <l:template name="msgset" text="%t"/>
                <l:template name="msgsub" text="%t"/>
                <l:template name="note" text="%t"/>
                <l:template name="orderedlist" text="%t"/>
                <l:template name="part" text="Part %n %t"/>
                <l:template name="partintro" text="%t"/>
                <l:template name="preface" text="%t"/>
                <l:template name="procedure" text="%t"/>
                <l:template name="procedure.formal" text="Procedure %n. %t"/>
                <l:template name="productionset" text="%t"/>
                <l:template name="productionset.formal" text="Production %n"/>
                <l:template name="qandadiv" text="%t"/>
                <l:template name="qandaentry" text="%t"/>
                <l:template name="qandaset" text="%t"/>
                <l:template name="question" text="%t"/>
                <l:template name="refentry" text="%t"/>
                <l:template name="reference" text="%t"/>
                <l:template name="refsection" text="%t"/>
                <l:template name="refsect1" text="%t"/>
                <l:template name="refsect2" text="%t"/>
                <l:template name="refsect3" text="%t"/>
                <l:template name="refsynopsisdiv" text="%t"/>
                <l:template name="refsynopsisdivinfo" text="%t"/>
                <l:template name="segmentedlist" text="%t"/>
                <l:template name="set" text="%t"/>
                <l:template name="setindex" text="%t"/>
                <l:template name="sidebar" text="%t"/>
                <l:template name="step" text="%t"/>
                <l:template name="table" text="Table %n. %t"/>
                <l:template name="task" text="%t"/>
                <l:template name="tasksummary" text="%t"/>
                <l:template name="taskprerequisites" text="%t"/>
                <l:template name="taskrelated" text="%t"/>
                <l:template name="tip" text="%t"/>
                <l:template name="toc" text="%t"/>
                <l:template name="variablelist" text="%t"/>
                <l:template name="varlistentry" text=""/>
                <l:template name="warning" text="%t"/>
            </l:context>
            <l:context name="title-numbered">
                <l:template name="appendix" text="Appendix %n (normative) %t"/>
                <l:template name="article/appendix" text="%n %t"/>
                <l:template name="bridgehead" text="%n %t"/>
                <l:template name="chapter" text="%n %t"/>
                <l:template name="part" text="Part %n %t"/>
                <l:template name="sect1" text="%n %t"/>
                <l:template name="sect2" text="%n %t"/>
                <l:template name="sect3" text="%n %t"/>
                <l:template name="sect4" text="%n %t"/>
                <l:template name="sect5" text="%n %t"/>
                <l:template name="section" text="%n %t"/>
                <l:template name="simplesect" text="%t"/>
            </l:context>
            
            <!-- override to take section out of links -->
            
            <l:context name="xref-number"><l:template name="answer" text="A: %n"/>
                <l:template name="appendix" text="Appendix %n"/>
                <l:template name="bridgehead" text="Section %n"/>
                <l:template name="chapter" text="%n"/>
                <l:template name="equation" text="Equation %n"/>
                <l:template name="example" text="Example %n"/>
                <l:template name="figure" text="Figure %n"/>
                <l:template name="part" text="Part %n"/>
                <l:template name="procedure" text="Procedure %n"/>
                <l:template name="productionset" text="Production %n"/>
                <l:template name="qandadiv" text="Q &amp; A %n"/>
                <l:template name="qandaentry" text="Q: %n"/>
                <l:template name="question" text="Q: %n"/>
                <l:template name="sect1" text="Section %n"/>
                <l:template name="sect2" text="Section %n"/>
                <l:template name="sect3" text="Section %n"/>
                <l:template name="sect4" text="Section %n"/>
                <l:template name="sect5" text="Section %n"/>
                <l:template name="section" text="%n."/>
                <l:template name="table" text="Table %n"/>
            </l:context>
            <l:context name="xref-number-and-title">
                <l:template name="appendix" text="Appendix %n, %t"/>
                <l:template name="bridgehead" text="Section %n, %t"/>
                <l:template name="chapter" text="%n, %t"/>
                <l:template name="equation" text="Equation %n, %t"/>
                <l:template name="example" text="Example %n, “%t”"/>
                <l:template name="figure" text="Figure %n, %t"/>
                <l:template name="part" text="Part %n, %t"/>
                <l:template name="procedure" text="Procedure %n, %t"/>
                <l:template name="productionset" text="Production %n, %t"/>
                <l:template name="qandadiv" text="Q &amp; A %n, %t"/>
                <l:template name="refsect1" text="the section called %t"/>
                <l:template name="refsect2" text="the section called %t"/>
                <l:template name="refsect3" text="the section called %t"/>
                <l:template name="refsection" text="the section called %t"/>
                <l:template name="sect1" text="Section %n, %t"/>
                <l:template name="sect2" text="Section %n, %t"/>
                <l:template name="sect3" text="Section %n, %t"/>
                <l:template name="sect4" text="Section %n, %t"/>
                <l:template name="sect5" text="Section %n, %t"/>
                <l:template name="section" text="%n, %t"/>
                <l:template name="simplesect" text="the section called %t"/>
                <l:template name="table" text="Table %n, %t"/>
            </l:context>
        </l:l10n>
    </l:i18n>
    
    
    <!-- remove all numbering from the foreword sections -->
    
    <xsl:template name="label.this.section">
        <xsl:param name="section" select="."/>
        
        <xsl:variable name="level">
            <xsl:call-template name="section.level"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$level &lt;= $section.autolabel.max.depth and not(ancestor::db:preface)">
                <xsl:value-of select="$section.autolabel"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <!-- fix example and figure numbering to be incremental -->
    
    <xsl:template match="db:figure|db:table|db:example" mode="label.markup">
        
        <xsl:choose>
            <xsl:when test="@label">
                <xsl:value-of select="@label"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number format="1" from="db:book|db:article" level="any"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- re-org the biblio entries for niso look and feel -->
    
    <xsl:template match="db:bibliolist">
        <dl>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="inherit" select="0"/>
            </xsl:call-template>
            <xsl:call-template name="anchor"/>
            <xsl:if test="db:blockinfo/db:title|db:info/db:title|db:title">
                <xsl:call-template name="formal.object.heading"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::db:blockinfo)                                    and not(self::db:info)                                    and not(self::db:title)                                    and not(self::db:titleabbrev)                                    and not(self::db:biblioentry)                                    and not(self::db:bibliomixed)]"/>
            <xsl:apply-templates select="db:biblioentry|db:bibliomixed"/>
        </dl>
    </xsl:template>
    
    <xsl:template match="db:biblioentry">
        <xsl:param name="label">
            <xsl:call-template name="biblioentry.label"/>
        </xsl:param>
        
        <xsl:variable name="id">
            <xsl:call-template name="object.id"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="string(.) = ''">
                <xsl:variable name="bib" select="document($bibliography.collection,.)"/>
                <xsl:variable name="entry" select="$bib/db:bibliography//                                          *[@id=$id or @xml:id=$id][1]"/>
                <xsl:choose>
                    <xsl:when test="$entry">
                        <xsl:choose>
                            <xsl:when test="$bibliography.numbered != 0">
                                <xsl:apply-templates select="$entry">
                                    <xsl:with-param name="label" select="$label"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$entry"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>No bibliography entry: </xsl:text>
                            <xsl:value-of select="$id"/>
                            <xsl:text> found in </xsl:text>
                            <xsl:value-of select="$bibliography.collection"/>
                        </xsl:message>
                        <div>
                            <xsl:call-template name="common.html.attributes"/>
                            <xsl:call-template name="anchor"/>
                            <p>
                                <xsl:copy-of select="$label"/>
                                <xsl:text>Error: no bibliography entry: </xsl:text>
                                <xsl:value-of select="$id"/>
                                <xsl:text> found in </xsl:text>
                                <xsl:value-of select="$bibliography.collection"/>
                            </p>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                    <dt>
                        <xsl:call-template name="common.html.attributes"/>
                        <xsl:call-template name="anchor">
                            <xsl:with-param name="conditional" select="0"/>
                        </xsl:call-template>
                        <xsl:copy-of select="$label"/>
                    </dt>
                    <dd>
                        <xsl:choose>
                            <xsl:when test="$bibliography.style = 'iso690'">
                                <xsl:call-template name="iso690.makecitation"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="bibliography.mode"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- remove editor names -->
    <xsl:template match="db:author" mode="bibliography.mode"/>
    <xsl:template match="db:editor" mode="bibliography.mode"/>
    
    <!-- add a linebreak before the orgname -->
    <xsl:template match="db:orgname" mode="bibliography.mode">
        <br/>
        <span>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:apply-templates mode="bibliography.mode"/>
            <xsl:copy-of select="$biblioentry.item.separator"/>
        </span>
    </xsl:template>
    
    <!-- add a linebreak after the date -->
    <xsl:template match="db:date" mode="bibliography.mode">
        <span>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:apply-templates mode="bibliography.mode"/>
            <xsl:copy-of select="$biblioentry.item.separator"/>
        </span>
        <br/>
    </xsl:template>
    
    <xsl:template match="db:bibliosource" mode="bibliography.mode" priority="1">
        <xsl:if test="not(preceding-sibling::db:date)">
            <br/>
        </xsl:if>
        <span>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:apply-templates mode="bibliography.mode"/>
            <!-- <xsl:copy-of select="$biblioentry.item.separator"/> -->
        </span>
    </xsl:template>
    
    <!-- remove biblio header from body normative references -->
    <xsl:template match="db:bibliography">
        <xsl:call-template name="id.warning"/>
        
        <div>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="inherit" select="1"/>
            </xsl:call-template>
            <xsl:if test="number($generate.id.attributes) != 0">
                <xsl:attribute name="id">
                    <xsl:call-template name="object.id"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:if test="not(ancestor::db:chapter)">
                <xsl:call-template name="bibliography.titlepage"/>
            </xsl:if>
            
            <xsl:apply-templates/>
            
            <xsl:if test="not(parent::db:article)">
                <xsl:call-template name="process.footnotes"/>
            </xsl:if>
        </div>
    </xsl:template>
    
    <!-- overriding to add section titles for italicizing -->
    <xsl:template match="db:chapter|db:appendix|db:section" mode="insert.title.markup">
        <xsl:param name="purpose"/>
        <xsl:param name="xrefstyle"/>
        <xsl:param name="title"/>
        
        <xsl:choose>
            <xsl:when test="$purpose = 'xref'">
                <i>
                    <xsl:copy-of select="$title"/>
                </i>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- add back missing numeration handling for lower alpha sublists -->
    
    <xsl:template match="db:orderedlist">
        <xsl:variable name="start">
            <xsl:call-template name="orderedlist-starting-number"/>
        </xsl:variable>
        
        <xsl:variable name="numeration">
            <xsl:call-template name="list.numeration"/>
        </xsl:variable>
        
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="$numeration='arabic'">1</xsl:when>
                <xsl:when test="$numeration='loweralpha'">a</xsl:when>
                <xsl:when test="$numeration='lowerroman'">i</xsl:when>
                <xsl:when test="$numeration='upperalpha'">A</xsl:when>
                <xsl:when test="$numeration='upperroman'">I</xsl:when>
                <!-- What!? This should never happen -->
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:text>Unexpected numeration: </xsl:text>
                        <xsl:value-of select="$numeration"/>
                    </xsl:message>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <div>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:call-template name="anchor"/>
            
            <xsl:if test="db:title">
                <xsl:call-template name="formal.object.heading"/>
            </xsl:if>
            
            <!-- Preserve order of PIs and comments -->
            <xsl:apply-templates select="*[not(self::db:listitem                   or self::db:title                   or self::db:titleabbrev)]                 |comment()[not(preceding-sibling::db:listitem)]                 |processing-instruction()[not(preceding-sibling::db:listitem)]"/>
            
            <xsl:choose>
                <xsl:when test="@inheritnum='inherit' and ancestor::db:listitem[parent::db:orderedlist]">
                    <table border="0">
                        <xsl:call-template name="generate.class.attribute"/>
                        <col align="{$direction.align.start}" valign="top"/>
                        <tbody>
                            <xsl:apply-templates mode="orderedlist-table" select="db:listitem                         |comment()[preceding-sibling::db:listitem]                         |processing-instruction()[preceding-sibling::db:listitem]"/>
                        </tbody>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <ol>
                        <xsl:call-template name="generate.class.attribute"/>
                        <xsl:if test="$start != '1'"><xsl:message><xsl:text>Strict XHTML does not allow setting @start attribute for lists! </xsl:text></xsl:message></xsl:if>
                        <xsl:if test="$numeration != ''">
                            <xsl:attribute name="style">
                                <xsl:choose>
                                    <xsl:when test="$numeration='loweralpha'">list-style-type: lower-alpha;</xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@spacing='compact'"><xsl:message><xsl:text>Compact spacing via @spacing attribute cannot be set in strict XHTML output for listitem: </xsl:text><xsl:value-of select="@spacing"/></xsl:message></xsl:if>
                        <xsl:apply-templates select="db:listitem                         |comment()[preceding-sibling::db:listitem]                         |processing-instruction()[preceding-sibling::db:listitem]"/>
                    </ol>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    
</xsl:stylesheet>
