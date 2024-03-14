<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
	xmlns="http://relaxng.org/ns/structure/1.0"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:rng="http://relaxng.org/ns/structure/1.0"	
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"		
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:z="http://www.daisy.org/ns/z3986/annotations/#"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"		
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"		
	exclude-result-prefixes="rng z">

	<!--
	xmlns:xsdp="http://www.daisy.org/ns/rng-preprocess/xsd"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"	
	xmlns:zrng="http://www.daisy.org/ns/rng/annotations"
	-->
	
	<!-- Postprocessing of RNG files. Source is an RNG, result is an RNG
		This XSLT does things like turning non-top RDF to a:documentation -->
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:include href="../xsl/wiki-link-handler.xsl"/>

	<xsl:template match="rdf:RDF">
		<xsl:choose>
			<xsl:when test="parent::rng:grammar">
				<xsl:element name="rdf:RDF">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about">.</xsl:attribute>
						<xsl:attribute name="xml:lang">en</xsl:attribute>					
						<xsl:call-template name="handle-top-level-rdf">
							<xsl:with-param name="desc" select="./rdf:Description"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="a:documentation">				
					<xsl:call-template name="handle-fragment-rdf">
						<xsl:with-param name="desc" select="./rdf:Description"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>	

	<xsl:template name="handle-top-level-rdf">
		<xsl:param name="desc" as="element()" />
		<xsl:apply-templates 
			select="$desc/*[not(local-name() eq 'requires') and not (local-name() eq 'isRequiredBy')]" />
	</xsl:template>

	<xsl:template name="handle-fragment-rdf">
		<xsl:param name="desc" as="element()" />
		<xsl:apply-templates select="$desc/dcterms:description" mode="replace" />
		<xsl:apply-templates select="$desc/z:info" mode="replace" />
		<xsl:apply-templates select="$desc/parent::node/parent::node()/sch:assert" mode="replace" />
	</xsl:template>
		
	<xsl:template match="dcterms:description|z:info|sch:assert" mode="replace">
		<xsl:call-template name="handle-wiki-text">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="handle-wiki-text">
		<xsl:param name="text" as="xs:string" />		
		<xsl:variable name="string" as="text()">
			<xsl:value-of select="replace(replace(string($text),'\{',''),'\}','')" />
		</xsl:variable>		
		<xsl:call-template name="wiki-links-to-plain-text">
			<xsl:with-param name="text" select="$string"/>
		</xsl:call-template><xsl:text> </xsl:text>		
	</xsl:template>
	
	<xsl:template match="dcterms:title">
		<xsl:element name="dcterms:title">
			<xsl:call-template name="handle-wiki-text">
				<xsl:with-param name="text">
					<xsl:value-of select="."/>
				</xsl:with-param>	
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="dcterms:description">
		<xsl:element name="dcterms:description">
			<xsl:call-template name="handle-wiki-text">
				<xsl:with-param name="text">
					<xsl:value-of select="."/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:element>
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
	
	<xsl:template match="rng:*">
		<xsl:copy copy-namespaces="yes">			
			<!-- strip out all non-rng attributes -->
			<xsl:copy-of select="@*[not(namespace-uri())]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rng:grammar">
		<xsl:copy>
			<!-- drop the xml:id attribute -->
			<xsl:copy-of select="@*[not(local-name() eq 'id')]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*">
		<xsl:copy copy-namespaces="yes">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="comment()" />
	
</xsl:stylesheet>
