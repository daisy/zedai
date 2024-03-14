<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds the main index (http://www.daisy.org/z3986/2010/index.html) -->

 	<xsl:param name="spec-path" as="xs:string" />
	<xsl:param name="primer-path" as="xs:string" />

	<xsl:variable name="specname">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$spec-path" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="primername">
		<xsl:call-template name="filename">
			<xsl:with-param name="path" select="$primer-path" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="title">Z39.86-2010 Specification Document Working area</xsl:variable>
    

    <xsl:template match="body">
      <body>
		<h1 property="dc:title"><xsl:value-of select="$title"/></h1>
		
		<div class="alert">
		  <p>05 October 2009: Second public working draft of 
		    <em>Z39.86-2010 Part A - Authoring and Interchange Framework</em>.</p>
		  <p>The documents provided here are early access working drafts.</p>
		  <p>Please read the working groups 
		    <a href="http://www.daisy.org/zw/ZedAI_Iteration4_Report">current iteration report</a> 
		    to get updated on current status and known issues.</p>
		  <p>An informal <a href="http://www.daisy.org/zw/ZedAI_Introduction">Wiki introduction</a>
		  is also available.</p>		    
		  <p>Comments and feedback is welcome through the 
		    <a href="http://www.daisy.org/forums/forum/4">ZedNext Forum</a>.</p>
		  <p>Expect repeated updates in this area until January 2010.</p>
		</div>
		
		<div>
        	<h2 id="auth">Z39.86-2010 Part A: Authoring and Interchange Framework</h2>
        	
        	<ul>
        	  <li><a href="./auth/profiles/">Profile Catalog</a></li>
        	  <li><a href="./auth/features/">Feature Catalog</a></li>
         	  <li><a href="{$specname}">Specification</a></li> 
        	  <li><a href="{$primername}">Primer</a></li>
          	</ul>
        	 	
 		</div>

		<div>
        	<h2 id="dist">Z39.86-2010 Part B: Distribution Framework</h2>
        	<p>Nothing to see here, yet. Please move along.</p>
        	 	
 		</div>

		<div>
        	<h2 id="dist">Z39.86-2010 RDF Vocabularies</h2>
        	<p><a href="./vocab/">Z39.86-2010 RDF Vocabulary Catalog</a></p>        	 	
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
    	<link rel="stylesheet" type="text/css" href="z3986-2010.css" />
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