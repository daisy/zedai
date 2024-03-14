<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rddl="http://www.rddl.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="http://www.daisy.org/z3998#"
	xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
	
	<xsl:param name="schema-fileset" />
	
	
	<xsl:variable name="modules" select="document($schema-fileset)" />
	
	<xsl:template match="*|comment()|processing-instruction()">
		<xsl:call-template name="copy" />
	</xsl:template>
	
	<xsl:template match="ul[@id='normative-schema-modules']">
	
		<ul id="normative-schema-modules">
			<xsl:for-each select="$modules/d:filelist/d:file/@uri">
				<xsl:if test="contains(.,'mod')">
					<xsl:variable name="modname">
						<xsl:call-template name="filename">
							<xsl:with-param name="path" select="." />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="modpath" select="concat('./mod/',$modname)" />
					<li>
						<rddl:resource xlink:type='simple'
							xlink:arcrole='http://www.rddl.org/purposes#module' xlink:role='http://relaxng.org/ns/structure/1.0'
							xlink:href='{$modpath}'>
							<a href="{$modpath}">
							    <!-- todo could parse the module and get the nicename
							    if its predictable -->
								<xsl:value-of select="$modname" />
							</a>
						</rddl:resource>
					</li>
				</xsl:if>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<xsl:template name="copy">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
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