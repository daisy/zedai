<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns="http://relaxng.org/ns/structure/1.0" 
	xmlns:xsdp="http://www.daisy.org/ns/rng-preprocess/xsd"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="xs">
	
	<!--  
	
	Preprocessing of RNG files to enable conversion
	to XSD using trang. 
	
	The following tokens 
	(in namespace http://www.daisy.org/ns/rng-preprocess/xsd)
    are supported in the RNG files:
    - @replace : replace the current define with the define named in @replace value
	 -->
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />	

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!--   Example: <define name="z3986.section.content" 
	  xsdp:replace="z3986.section.content.xsd">  -->

	<xsl:template match="//define[@xsdp:replace]">
	
	  <xsl:element name="define">
	    <xsl:attribute name="name">
	      <xsl:value-of select="./@name" />
	    </xsl:attribute>
	    
	    <xsl:variable name="target" select="./@xsdp:replace" />
	    
	    <xsl:comment>Replacing define 
	      <xsl:value-of select="./@name"/> 
	      with define <xsl:value-of select="$target"/></xsl:comment>
	    	    	      
		<xsl:apply-templates select="//define[@name=$target]/*"/>
	  </xsl:element>
	  
	</xsl:template>

</xsl:stylesheet>