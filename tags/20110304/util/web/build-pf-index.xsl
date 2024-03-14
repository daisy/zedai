<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds an index of profiles or features (aka "catalog"). The index points to the respective
    version index of the particular profile or feature. -->

	<xsl:param name="list" as="xs:string"/>
	<xsl:param name="title" as="xs:string" />
	<xsl:param name="output-uri" as="xs:string" />
	<xsl:param name="nicename-prefix" as="xs:string" />
	
	<!--  input list is a propertySet.toString -->
	<xsl:variable name="xlist" as="xs:string*" select="tokenize(normalize-space($list),', ')" />
	
    <xsl:template match="title">
    	<title><xsl:value-of select="$title"/></title>
    </xsl:template>

    <xsl:template match="body">
      <body>
		<h1 property="dcterms:title"><xsl:value-of select="$title"/></h1>
 
		<ul>
			<xsl:for-each select="$xlist">
				<xsl:variable name="entry" select="translate(.,' ','')" />
				<xsl:variable name="id" select="substring-after($entry,'=')" />
				<xsl:variable name="href">./<xsl:value-of select="$id" />/index.html</xsl:variable>
				<li><a id="{$id}" href="{$href}">		        
			    	<xsl:variable name="subdoc" select="resolve-uri($href,translate($output-uri,'\','/'))" />
					<!--  <xsl:message><xsl:value-of select="$subdoc"/></xsl:message>  -->
					<!--  <xsl:value-of select="substring-after(document($subdoc)//head/meta[@property='z3986-feature-nicename']/@content,$nicename-prefix)" />-->
					<xsl:value-of select="document($subdoc)//head/meta[@property='z3986-feature-nicename']/@content" />
				    </a>
				</li>
			</xsl:for-each>
		</ul>
	
		<div class="footer">
		  <p>Document last updated: <xsl:value-of select="current-dateTime()"/></p>
		</div>
	  </body>
	</xsl:template>

    <xsl:template match="link[@rel='stylesheet']">
      		<link rel="stylesheet" type="text/css" href="../../z3986-2011.css" />
	</xsl:template>	

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	
</xsl:stylesheet>