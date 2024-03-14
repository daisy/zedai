<xsl:stylesheet version="2.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xs">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="no" indent="yes" />
  <xsl:param name="rdfa-vocab" required="yes" as="xs:string" />  <!-- path to the vocab which this revhistory is for -->
  <xsl:variable name="rdfa-doc" select="document(translate($rdfa-vocab,'\','/'))" />
  	
  <xsl:template match="html">
  	<html xml:lang="en" lang="en">
  		<head>
  			<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>  	
  			<link rel="stylesheet" type="text/css" href="../../z3998-2012.css" />
  			<title>Revision history for the <xsl:value-of select="$rdfa-doc//head/title"/></title>
  		</head>
  		<body>
  			<h1><span class="titlesub">Revision history for the </span><br/><xsl:value-of select="$rdfa-doc//head/title"/></h1>
  			<xsl:apply-templates select="./*" />
  		</body>	
  	</html>	
  </xsl:template>

	<xsl:template match="*|text()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
  <xsl:template match="comment()" />
	
</xsl:stylesheet>