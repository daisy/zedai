<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"	
	xmlns:z="http://www.daisy.org/ns/z3986/2008/"
	xmlns="http://www.w3.org/2002/06/xhtml2/" 
	xpath-default-namespace="http://www.w3.org/2002/06/xhtml2/"
	exclude-result-prefixes="xs z">
	
	<!--  TODO reference XHTML VOCAB instead of using class... -->
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
		
	<xsl:template match="*|comment()|processing-instruction()">
		<xsl:call-template name="copy" />
	</xsl:template>
	
	<xsl:template match="z:noteref">	    
		<a class="noteref" href="{@ref}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="z:note">
		<div class="note">	
			 <xsl:apply-templates/>		
		</div>
	</xsl:template>

	<xsl:template match="z:hd">
		<h class="hd">
			<xsl:apply-templates/>
		</h>
	</xsl:template>
	
	<xsl:template name="copy">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>