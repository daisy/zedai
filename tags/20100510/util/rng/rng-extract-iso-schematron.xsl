<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.w3.org/1999/xhtml"
	xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns="http://purl.oclc.org/dsdl/schematron"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="xs x rng nsl">

	<!-- <xsl:param name="namespaceListURI" as="xs:string" select="'[UDEF]'" /> -->
	<xsl:param name="niceName" as="xs:string" select="'[niceName]'" />
	<xsl:param name="version" as="xs:string" select="'[version]'" />
	
	<xsl:output method="xml" indent="yes" />

	<xsl:template match="/">
		<schema queryBinding="xslt2">
			
			<title>
				<xsl:value-of select="concat('ISO Schematron tests for ',$niceName)" />
				<xsl:value-of select="concat(' version ',$version)" />
			</title>

			<xsl:variable name="ns-carrier" as="element()" select="/rng:grammar" />
			<xsl:for-each select="in-scope-prefixes($ns-carrier)[. ne '']">
				<ns>
					<xsl:attribute name="uri" select="namespace-uri-for-prefix(.,$ns-carrier)" />
					<xsl:attribute name="prefix" select="." />
				</ns>
			</xsl:for-each>
			<!-- Add default-namespace -->
			<ns prefix="default" uri="http://www.daisy.org/ns/z3986/authoring/" />

			<pattern>
				<xsl:apply-templates />
			</pattern>
		</schema>
	</xsl:template>

	<xsl:template match="nsl:namespace">
		<ns uri="{.}">
			<xsl:copy-of select="@prefix" />
		</ns>
	</xsl:template>

	<xsl:template match="rng:include" priority="10">
		<xsl:variable name="currentFile" as="xs:anyURI" select="resolve-uri(document-uri(/))" />
		<xsl:apply-templates select="doc(resolve-uri(@href,$currentFile))/grammar" />
	</xsl:template>

	<xsl:template match="sch:rule" priority="10">
		<xsl:copy-of select="." copy-namespaces="no" />
	</xsl:template>

	<xsl:template match="*">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="text()" priority="-10" />
</xsl:stylesheet>
