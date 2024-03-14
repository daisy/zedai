<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds the main index (http://www.daisy.org/z3986/2011/index.html) -->

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
		
	<xsl:variable name="title">Z39.86-201x Specification Document Working area</xsl:variable>
    
    <xsl:template match="body">
      <body>
		<h1 property="dcterms:title"><xsl:value-of select="$title"/></h1>
		
		<div class="alert">
			<dl>
				<dt>28th of March 2011</dt>
				<dd>
					<p>Draft Standard for Trial Use — <em>NISO Z39.86-201x Part A - Authoring and Interchange Framework</em>.</p>
					<p>The trial period runs from March 28, 2011 until September 28, 2011 inclusive.</p>
					<p>Refer to the <a href="http://www.daisy.org/zw/ZedAI_UserPortal#Recent_Events">user portal</a> for further information.</p>
				</dd>
			</dl>
		</div>
		
		<div>
        	<h2 id="auth">NISO Z39.86-201x Part A: Authoring and Interchange Framework</h2>
        	
        	<ul>
        	  <li><a href="./auth/profiles/">Profile Catalog</a></li>
        	  <li><a href="./auth/features/">Feature Catalog</a></li>
         	  <li><a href="{$ai-specname}">Specification</a></li>
        	  <li><a href="./auth/cm/">Core Modules</a></li>
        	  <li><a href="{$ai-primer-path}">Primer</a></li>
          	</ul>
        	 	
 		</div>

		<div>
			<h2 id="vocab">Z39.86-201x RDF Vocabularies</h2>
        	<p><a href="./vocab/">Z39.86-201x RDF Vocabulary Catalog</a></p>        	 	
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