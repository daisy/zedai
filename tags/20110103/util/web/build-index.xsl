<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds the main index (http://www.daisy.org/z3986/2011/index.html) -->

 	<xsl:param name="ai-spec-path" as="xs:string" />
 	<xsl:param name="dist-spec-path" as="xs:string" />
	<xsl:param name="ai-primer-path" as="xs:string" />
		
	<xsl:variable name="ai-specname">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$ai-spec-path" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="dist-specname">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$dist-spec-path" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="ai-primername">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$ai-primer-path" />
		</xsl:call-template>
	</xsl:variable>
		
	<xsl:variable name="title">Z39.86-2011 Specification Document Working area</xsl:variable>
    
    <xsl:template match="body">
      <body>
		<h1 property="dcterms:title"><xsl:value-of select="$title"/></h1>
		
		<div class="alert">
			<dl>
				<dt>3rd of January 2011</dt>
				<dd>
					<p>Third Working Draft of <em>Z39.86-2011 Part A - Authoring and Interchange Framework</em>.</p>
					<p>Refer to the <a href="http://www.daisy.org/zw/ZedAI_UserPortal#Recent_Events">user portal</a> for further information.</p>
				</dd>
			</dl>
		</div>
		
		<div>
        	<h2 id="auth">Z39.86-2011 Part A: Authoring and Interchange Framework</h2>
        	
        	<ul>
        	  <li><a href="./auth/profiles/">Profile Catalog</a></li>
        	  <li><a href="./auth/features/">Feature Catalog</a></li>
         	  <li><a href="{$ai-specname}">Specification</a></li>
        	  <li><a href="./auth/cm/">Core Modules</a></li>
        	  <li><a href="{$ai-primer-path}">Primer</a></li>
          	</ul>
        	 	
 		</div>

<!--		
	<div>
        	<h2 id="dist">Z39.86-2011 Part B: Distribution Framework</h2>
			<p><em>Work on the first public draft is ongoing.</em></p>
			<p>
				Please visit the <a href="http://www.daisy.org/zw/ZedDist">Working Group's site</a> and 
				<a href="http://www.daisy.org/forums/zeddist">ZedDist forum</a> for further information and
				announcements.
			</p>
        	<ul>
        	  <li><a href="./dist/profiles/">Profile Catalog</a></li>
        	  <li><a href="./dist/features/">Feature Catalog</a></li>
         	  <li><a href="{$dist-specname}">Specification</a></li> 
          	</ul>
 		</div>
-->
      	
		<div>
        	<h2 id="dist">Z39.86-2011 RDF Vocabularies</h2>
        	<p><a href="./vocab/">Z39.86-2011 RDF Vocabulary Catalog</a></p>        	 	
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
    	<link rel="stylesheet" type="text/css" href="z3986-2011.css" />
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