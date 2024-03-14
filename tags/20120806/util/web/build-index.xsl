<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds the main index (http://www.daisy.org/z3998/2011/index.html) -->

 	<xsl:param name="ai-spec-path" as="xs:string" />
	<xsl:param name="ai-primer-path" as="xs:string" />
		
	<xsl:variable name="ai-specname">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$ai-spec-path" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="ai-primername">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$ai-primer-path" />
		</xsl:call-template>
	</xsl:variable>
		
	<xsl:variable name="title">ANSI/NISO Z39.98-2012 Specification</xsl:variable>
    
    <xsl:template match="body">
      <body>
		<h1 property="dcterms:title"><xsl:value-of select="$title"/></h1>
		
		<div>
        	<h2 id="auth">ANSI/NISO Z39.98-2012: Authoring and Interchange Framework</h2>
        	
        	<ul>
        	  <li><a href="./auth/profiles/">Profile Catalog</a></li>
        	  <li><a href="./auth/features/">Feature Catalog</a></li>
         	  <li><a href="{$ai-specname}">Specification</a></li>
        	  <li><a href="./auth/cm/">Core Modules</a></li>
        	  <li><a href="{$ai-primer-path}">Primer</a></li>
          	</ul>
        	 	
 		</div>

		<div>
			<h2 id="vocab">Z39.98-2012 RDF Vocabularies</h2>
        	<p><a href="./vocab/">Z39.98-2012 RDF Vocabulary Catalog</a></p>        	 	
 		</div>
 	    
		<div class="footer">
		  <p>Document last updated: <xsl:value-of select="current-dateTime()"/></p>
		</div>
	  </body>
	</xsl:template>

    <xsl:template match="title">
      <title><xsl:value-of select="$title"/></title>
    </xsl:template>  

    <xsl:template match="link[@rel='stylesheet']">
    	<link rel="stylesheet" type="text/css" href="z3998-2012.css" />
	</xsl:template>	

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="filename">
		<xsl:param name="path" />
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="substring-after($path, '/')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$path" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
</xsl:stylesheet>