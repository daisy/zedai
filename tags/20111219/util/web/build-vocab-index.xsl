<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">

    <!-- builds an index vocab catalog. -->

	<xsl:param name="core-list" as="xs:string"/>  		<!-- vocabs reffed from the spec -->
	<xsl:param name="additional-list" as="xs:string"/>	<!-- vocabs not reffed from the spec -->
	<xsl:param name="output-uri" as="xs:string" />
	
	<!--  input lists is a propertySet.toString -->
	<xsl:variable name="coreList" as="xs:string*" select="tokenize(normalize-space($core-list),', ')" />
	<xsl:variable name="additionalList" as="xs:string*" select="tokenize(normalize-space($additional-list),', ')" />
	
	<xsl:variable name="title" as="xs:string">Z39.86-2012 RDF Vocabulary Catalog</xsl:variable>
	
	<xsl:template match="title">
		<title><xsl:value-of select="$title"/></title>
	</xsl:template>
	
	<xsl:template match="body">
		<body>
			<h1 property="dcterms:title"><xsl:value-of select="$title"/></h1>
			<h2>Vocabularies referenced from the Z39.86-AI specification</h2>
			<ul>
				<xsl:for-each select="$coreList">				
					<xsl:call-template name="render-entry"/>
				</xsl:for-each>
			</ul>
	
      	<h2>Additional Vocabularies</h2>
      	<ul>
      	<xsl:for-each select="$additionalList">				
      		<xsl:variable name="subdir" select="substring-before(.,'/')" />				
      		<xsl:variable name="href">./<xsl:value-of select="$subdir"/>/</xsl:variable>
      		<li><a id="{$subdir}" href="{$href}">		        
      			<xsl:variable name="subdoc" select="resolve-uri(.,translate($output-uri,'\','/'))" />					
      			<xsl:value-of select="document($subdoc)//head/title" />
      		</a>
      		</li>
      	</xsl:for-each>
      	</ul>
      	
		<div class="footer">
		  <p>Document last updated: <xsl:value-of select="current-dateTime()"/></p>
		</div>
	  </body>
	</xsl:template>
	
	<xsl:template name="render-entry">
		<xsl:variable name="subdir" select="substring-before(.,'/')" />				
		<xsl:variable name="href">./<xsl:value-of select="$subdir"/>/</xsl:variable>
		<li><a id="{$subdir}" href="{$href}">		        
			<xsl:variable name="subdoc" select="resolve-uri(.,translate($output-uri,'\','/'))" />					
			<xsl:value-of select="document($subdoc)//head/title" />
		</a>
		</li>
	</xsl:template>

    <xsl:template match="link[@rel='stylesheet']">
      		<link rel="stylesheet" type="text/css" href="../z3986-2012.css" />
	</xsl:template>	

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	
</xsl:stylesheet>