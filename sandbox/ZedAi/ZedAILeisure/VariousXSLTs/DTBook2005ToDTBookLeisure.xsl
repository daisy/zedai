<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns="http://www.w3.org/2002/06/xhtml2/"
	xmlns:dtbl="http://www.daisy.org/z3986/2008/dtbook-leisure/"
	xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/" 
	exclude-result-prefixes="hks xs"
	>

<xsl:output method="xhtml" encoding="UTF-8" indent="yes" />

<xsl:template match="element()" priority="-5">
	<xsl:message terminate="no">*** No matching template for the <xsl:value-of select="local-name(.)" /> element!</xsl:message>
	<xsl:apply-templates />
</xsl:template>
<xsl:template match="/">
	<xsl:apply-templates />
</xsl:template>
	
<xsl:template match="dtbook">
	<xsl:processing-instruction name="xml-stylesheet" select="'type=&quot;text/css&quot; href=&quot;http://www.w3.org/MarkUp/style/xhtml2.css&quot;'" />
	<html>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</html>
</xsl:template>
	
<xsl:template match="head">
	<head>
		<title>
			<xsl:value-of select="//frontmatter/doctitle" />
		</title>
		<meta property="title">
			<xsl:value-of select="//frontmatter/doctitle" />
		</meta>
	</head>
</xsl:template>

<xsl:template match="book">
	<body>
		<xsl:apply-templates />
	</body>
</xsl:template>

<xsl:template match="frontmatter | bodymatter | rearmatter | level1 | level2 | level3 | level4 | level5 | level6">
	<section class="{local-name()}">
		<xsl:copy-of select="@* except @class" />
		<xsl:apply-templates />
		<xsl:comment> End of <xsl:value-of select="local-name()" /> </xsl:comment>
	</section>	
</xsl:template>
<xsl:template match="h1 | h2 | h3 | h4 | h5 | h6">
	<h>
		<xsl:call-template name="copy-attribs" />
		<xsl:apply-templates />
	</h>
</xsl:template>

<xsl:template match="doctitle">
	<h class="doctitle">
		<xsl:apply-templates />
	</h>
</xsl:template>
	
<xsl:template match="br">
	<!--We ignore br all together
	<separator class="br" />-->
</xsl:template>

<xsl:template match="p/br | span/br" />	<!-- Not sure how to handle br inside p, span. So currently; get rid of them-->
	
<xsl:template match="imggroup">
	<!-- Don't transform imggroup in the leisure instance
	<div class="{local-name()}">
		<xsl:apply-templates />
	</div>
	-->
</xsl:template>

<xsl:template match="sent">
	<span>
		<xsl:call-template name="copy-attribs" />
		<xsl:apply-templates />
	</span>
</xsl:template>
	

<xsl:template match="pagenum">
	<dtbl:pagenum>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</dtbl:pagenum>
</xsl:template>

	<xsl:template match="p | div | li | table | tr | td | th | span | caption | blockquote">
	<xsl:element name="{local-name()}">
		<xsl:call-template name="copy-attribs" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="list">
	<xsl:element name="{@type}">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>
	
<xsl:template match="line">
	<l>
		<xsl:call-template name="copy-attribs" />
		<xsl:apply-templates />
	</l>
</xsl:template>
	
<xsl:template match="img">
	<img>
		<xsl:copy-of select="@* except @alt except @id" />
		<xsl:apply-templates />
	</img>	
</xsl:template>

<xsl:template match="a">
	<a>
		<xsl:copy-of select="@* except @id except @external" />
		<xsl:apply-templates />
	</a>	
</xsl:template>

<!-- A few things we currently ignore -->
<xsl:template match="note | noteref | prodnote | docauthor" />

<!-- and some we just pass through -->
<xsl:template match="w | acronym">
	<xsl:apply-templates />
</xsl:template>
	
	
<!--<xsl:template match="p[normalize-space(.) = '']">
	
</xsl:template>-->	<!-- Get rid of empty paragraps -->
	
<xsl:template name="copy-attribs">
	<xsl:copy-of select="@* except @imgref except @id" />
</xsl:template>
</xsl:stylesheet>
