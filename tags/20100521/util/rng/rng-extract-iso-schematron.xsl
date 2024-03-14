<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.w3.org/1999/xhtml"
	xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns="http://purl.oclc.org/dsdl/schematron"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="xs x rng">

	<xsl:param name="niceName" as="xs:string" select="'[niceName]'" />
	<xsl:param name="version" as="xs:string" select="'[version]'" />
	<xsl:param name="default-namespace" as="xs:string"
		select="'http://www.daisy.org/ns/z3986/authoring/'" />

	<xsl:output method="xml" indent="yes" />

	<xsl:template match="/">
		<schema queryBinding="xslt2">
			<xsl:comment>generated: <xsl:value-of select="current-dateTime()" /></xsl:comment>
			<xsl:comment>input file: <xsl:value-of select="document-uri(/)" /></xsl:comment>

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
			<ns prefix="default" uri="{$default-namespace}" />

			<pattern>
				<xsl:apply-templates />
			</pattern>
		</schema>
	</xsl:template>


	<xsl:template match="rng:include" priority="10">
		<xsl:variable name="currentFile" as="xs:anyURI" select="resolve-uri(document-uri(/))" />
		<xsl:apply-templates select="doc(resolve-uri(@href,$currentFile))/grammar" />
	</xsl:template>

	<xsl:template match="sch:rule" priority="10">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="sch:assert | sch:report" priority="10">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*" />
			<!-- Remove { and } from the message -->
			<xsl:value-of select="translate(translate(.,'{',''),'}','')" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="text()" priority="-10" />
</xsl:stylesheet>
