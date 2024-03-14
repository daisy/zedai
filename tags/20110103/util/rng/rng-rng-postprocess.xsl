<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
	xmlns="http://relaxng.org/ns/structure/1.0"	
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:rng="http://relaxng.org/ns/structure/1.0"	
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"		
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"		
	xmlns:db="http://docbook.org/ns/docbook"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:z="http://www.daisy.org/ns/z3986/annotations/#"
	xmlns:ssml="http://www.w3.org/2001/10/synthesis"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" 
	exclude-result-prefixes="rng xs">
	
	<!-- Postprocessing of RNG files. Source is an RNG, result is an RNG
		This XSLT does things like turning docbook into to a:documentation -->
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:include href="../xsl/wiki-link-handler.xsl"/>

	<xsl:template match="rng:grammar/db:info//db:simplelist" />
	
	<xsl:template match="rng:grammar/db:info/db:title">
		<xsl:element name="title" namespace="http://docbook.org/ns/docbook">
			<xsl:call-template name="handle-wiki-text">
				<xsl:with-param name="text">
					<xsl:value-of select="."/>
				</xsl:with-param>	
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="rng:grammar/db:info/db:annotation">
		<xsl:element name="annotation" namespace="http://docbook.org/ns/docbook">
			<xsl:attribute name="annotates">/</xsl:attribute>
			<xsl:for-each select="db:para[starts-with(@role,'desc-')]">
				<xsl:element name="para" namespace="http://docbook.org/ns/docbook">
					<xsl:call-template name="handle-wiki-text">
						<xsl:with-param name="text">
							<xsl:value-of select="current()"/>
						</xsl:with-param>	
					</xsl:call-template>
				</xsl:element>
			</xsl:for-each>
			<!-- TODO can make a more clever linkage detector than the below -->
			<xsl:if test="//rng:grammar/@ns eq 'http://www.daisy.org/ns/z3986/authoring/'">
				<xsl:element name="para" namespace="http://docbook.org/ns/docbook"
					>More information about this module is available at http://www.daisy.org/z3986/2011/auth/cm/#<xsl:value-of 
						select="//rng:grammar/@xml:id"/></xsl:element>	
			</xsl:if>
		</xsl:element>	
	</xsl:template>

	<xsl:template match="rng:define//db:annotation">
		<a:documentation>
			<xsl:for-each select="db:para[starts-with(@role,'desc-')]">
				<!-- <a:documentation> -->
					<xsl:call-template name="handle-wiki-text">
						<xsl:with-param name="text">
							<xsl:value-of select="current()"/>
						</xsl:with-param>	
					</xsl:call-template>
				<!-- </a:documentation> -->
			</xsl:for-each>
		</a:documentation>	
	</xsl:template>

	<xsl:template match="rng:grammar">
		<xsl:copy>
			<xsl:copy-of select="@*[not(local-name() eq 'id')]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rng:*">
		<xsl:copy copy-namespaces="yes">			
			<!-- strip out all non-rng attributes -->
			<xsl:copy-of select="@*[not(namespace-uri())]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="a:documentation">
		<xsl:element name="a:documentation">
			<xsl:call-template name="handle-wiki-text">
				<xsl:with-param name="text">
					<xsl:value-of select="."/>
				</xsl:with-param>	
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="sch:assert/text()">		
		<xsl:call-template name="handle-wiki-text">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
			</xsl:with-param>	
		</xsl:call-template>		
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy copy-namespaces="yes">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="comment()" />
	
	<xsl:template match="processing-instruction()" />
	
	<xsl:template name="handle-wiki-text">
		<xsl:param name="text" as="xs:string" />		
		<xsl:variable name="string" as="text()">
			<xsl:value-of select="replace(replace(string($text),'\{',''),'\}','')" />
		</xsl:variable>		
		<xsl:call-template name="wiki-links-to-plain-text">
			<xsl:with-param name="text" select="$string"/>
		</xsl:call-template><xsl:text> </xsl:text>		
	</xsl:template>
	
</xsl:stylesheet>
