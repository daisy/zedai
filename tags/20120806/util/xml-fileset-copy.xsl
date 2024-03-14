<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rddl="http://www.rddl.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="http://www.daisy.org/z3998#"
	xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />	
	<xsl:param name="destination-dir" />
		
	<xsl:template match="d:file">
		<xsl:variable name="outname">
			<xsl:call-template name="filename">
				<xsl:with-param name="path" select="current()/@uri" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="outpath">
		 	<xsl:choose>
				<xsl:when test="contains(current()/@uri, '/mod/')">
					<xsl:value-of select="concat($destination-dir,'/mod/',$outname)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($destination-dir,'/',$outname)"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
						
		<xsl:result-document method="xml" href="{$outpath}">
			<xsl:copy-of select="document(current()/@uri)"/>
		</xsl:result-document>	
		
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