<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

   <!-- builds a version index for a profile or a feature  -->

	<xsl:param name="version.list" as="xs:string"/>
	<xsl:param name="nicename" as="xs:string" />
	<xsl:param name="machinename" as="xs:string" />
	<xsl:param name="part.prefix" as="xs:string" />
	<xsl:param name="part.nicename.prefix" as="xs:string" />
	<xsl:param name="current.version" as="xs:string"/>
	
	<xsl:variable name="version-list" as="xs:string*" select="tokenize(normalize-space($version.list),' ')"/>
	
   <xsl:template match="head">
     <head>
    	<meta property="z3986-feature-nicename" content="{$nicename}" />
    	<xsl:apply-templates/>
     </head> 	
   </xsl:template>

    <xsl:template match="body">
      <body>
		<h1 property="dc:title">
		  <span class="titlesub">Version index for the <xsl:value-of select="$part.nicename.prefix"/></span>
		  <br/><xsl:value-of select="$nicename"/>		  
		</h1>

	    <p>This index contains a listing of the version history of the <em><xsl:value-of select="$nicename"/></em>.</p>
	    <p>The most recently published version is <a href="./{$current.version}/{$part.prefix}-{$machinename}.html"><xsl:value-of select="$current.version"/></a>.</p>
		<ul>
			<xsl:for-each select="$version-list">
				<xsl:variable name="version" select="." />
				<li><a id="{$version}" href="./{$version}/{$part.prefix}-{$machinename}.html">
					<xsl:value-of select="$version"/>
				</a></li>
			</xsl:for-each>
		</ul>
	
		<div class="footer">
		  <p>Document last updated: <xsl:value-of select="current-dateTime()"/></p>
		</div>
	 </body>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="title">
    	<title>Version Index for the <xsl:value-of select="$part.nicename.prefix"/> <xsl:value-of select="$nicename"/></title>
    </xsl:template>
		
</xsl:stylesheet>