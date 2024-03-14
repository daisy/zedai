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

	<xsl:variable name="resolvedRNGFile">
		<xsl:apply-templates/>
	</xsl:variable>

	<xsl:template match="/">
		<schema queryBinding="xslt2">
			<xsl:comment>generated: <xsl:value-of select="current-dateTime()" /></xsl:comment>
			<xsl:comment>input file: <xsl:value-of select="document-uri(/)" /></xsl:comment>
			
			<title>
				<xsl:value-of select="concat('ISO Schematron tests for ',$niceName)" />
				<xsl:value-of select="concat(' version ',$version)" />
			</title>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">notes</xsl:attribute>
				<xsl:attribute name="match">default:note</xsl:attribute>
				<xsl:attribute name="use">@xml:id</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">noterefs</xsl:attribute>
				<xsl:attribute name="match">default:noteref</xsl:attribute>
				<xsl:attribute name="use">tokenize(@ref,'\s+')</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">annotations</xsl:attribute>
				<xsl:attribute name="match">default:annotation</xsl:attribute>
				<xsl:attribute name="use">@xml:id</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">annorefs</xsl:attribute>
				<xsl:attribute name="match">default:annoref</xsl:attribute>
				<xsl:attribute name="use">tokenize(@ref,'\s+')</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">descriptions</xsl:attribute>
				<xsl:attribute name="match">default:description</xsl:attribute>
				<xsl:attribute name="use">@xml:id|@sel:selid</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">descrefs</xsl:attribute>
				<xsl:attribute name="match">default:*[@desc]</xsl:attribute>
				<xsl:attribute name="use">tokenize(@desc,'\s+')</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">rdfprefix</xsl:attribute>
				<xsl:attribute name="match">default:document</xsl:attribute>
				<xsl:attribute name="use">tokenize(replace(@prefix,': +[^ ]+ *', ':'), ':')</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="xsl:key">
				<xsl:attribute name="name">rdfprofile</xsl:attribute>
				<xsl:attribute name="match">default:document</xsl:attribute>
				<xsl:attribute name="use">document(//default:meta[@rel='z3986:rdfa-context']/@resource)//*[@property='rdfa:prefix']/text()</xsl:attribute>
			</xsl:element>
			
			<xsl:variable name="ns-carrier" as="element()" select="/rng:grammar" />
			<xsl:for-each select="in-scope-prefixes($ns-carrier)[. ne '']">
				<ns>
					<xsl:attribute name="uri" select="namespace-uri-for-prefix(.,$ns-carrier)" />
					<xsl:attribute name="prefix" select="." />
				</ns>
			</xsl:for-each>
			<!-- Add default-namespace -->
			<ns prefix="default" uri="{$default-namespace}" />
			
			<!-- add additional namespaces -->
			<ns prefix="sel" uri="http://www.daisy.org/ns/z3986/authoring/features/select/"/>
			<ns prefix="its" uri="http://www.w3.org/2005/11/its"/>
			<ns prefix="m" uri="http://www.w3.org/1998/Math/MathML"/>
			<ns prefix="d" uri="http://www.daisy.org/ns/z3986/authoring/features/description/"/>
			
			<!-- insert all error rules first -->
			<xsl:for-each select="$resolvedRNGFile//sch:rule[not(@role='warning')][not(child::sch:assert[@role='warning'])][not(child::sch:report[@role='warning'])]">
				<xsl:sort select="@context"/>
				<pattern>
					<xsl:copy-of select="."/>
				</pattern>
			</xsl:for-each>
			
			<!-- insert all warning rules after -->
			<xsl:for-each select="$resolvedRNGFile//sch:rule[@role='warning' or child::sch:assert[@role='warning'] or child::sch:report[@role='warning']]">
				<xsl:sort select="@context"/>
				<pattern>
					<xsl:copy-of select="."/>
				</pattern>
				</xsl:for-each>
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
