<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a">

	<!-- 
	20081003: Per Sennels (ps): Created 
-->

	<!-- VARIOUS PARAMETERS -->
	<xsl:param name="debug" as="xs:boolean" select="false()" />
	<xsl:param name="docFoldername" as="xs:string" select="'SchemaDoc'" />
	<xsl:param name="docSubFoldername" as="xs:string" select="'subFiles'" />
	<xsl:param name="docFilename" as="xs:string" select="'DAISYLeisure.html'" />
	<xsl:param name="docTitle" as="xs:string" select="'The DAISY Leisure Profile'" />

	<!-- Store the driver rng in a variable; we will need it in other contexts later -->
	<xsl:variable name="RNG" as="node()" select="." />


	<xsl:output method="xhtml" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:template match="/">
		<xsl:message>** Generating schema documentation </xsl:message>



		<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
			<head>
				<title>Profile Documentation: <xsl:value-of select="$docTitle" /></title>
				<link rel="stylesheet" type="text/css" href="ProfileDoc.css" />
			</head>
			<body>
				<h1>Profile Documentation: <span class="doctitle">
						<xsl:value-of select="$docTitle" />
					</span></h1>

				<p>
					<xsl:variable name="startPattern" as="xs:string" select="//start/ref/@name" />
					<xsl:variable name="root" as="element()"
						select="//define[@name eq $startPattern]" />
					<xsl:text>The root element in this grammar is </xsl:text>
					<a class="element">
						<xsl:attribute name="href"
							select="concat('Elements/',//start/ref/@name,'.html')" />
						<xsl:value-of select="/grammar/define[@name eq $startPattern]/element/@name"
						 />
					</a>
					<xsl:text>. The complete grammar comprises the following elements:</xsl:text>
				</p>
				<div class="element-toc">
					<xsl:for-each select="/grammar/define">
						<xsl:sort select="element/@name" />
						<a class="element" href="{concat('Elements/',@name,'.html')}">
							<xsl:value-of select="element/@name" />
						</a>
						<xsl:text>&#10;</xsl:text>
					</xsl:for-each>
				</div>
			</body>
		</html>

		<xsl:for-each select="/grammar/define">
			<xsl:call-template name="createElementInfo" />
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="createElementInfo">
		<xsl:result-document href="{concat('Elements/',@name,'.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<head>
					<title>Profile Documentation: <xsl:value-of select="$docTitle" /> - the
							<xsl:value-of select="element/@name" /> element</title>
					<link rel="stylesheet" type="text/css" href="../ProfileDoc.css" />
				</head>
				<body>
					<h1>The <span class="element">
							<xsl:value-of select="element/@name" />
						</span> element</h1>
					<xsl:apply-templates select="element" />
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="element">
		<xsl:variable name="attlist.optional" as="element()*"
			select="descendant::attribute[ancestor::optional]" />
		<xsl:variable name="attlist.mandatory" as="element()*"
			select="descendant::attribute[not(ancestor::optional)]" />
		<xsl:variable name="children" as="element()*" select="descendant::ref" />
		<xsl:variable name="children.optional" as="element()*"
			select="$children[ancestor::optional or ancestor::zeroOrMore or ancestor::choice]" />
		<xsl:variable name="children.mandatory" as="element()*"
			select="$children except $children.optional" />
		<table xmlns="http://www.w3.org/1999/xhtml">
			<col id="col1" />
			<col id="col2" />
			<tr valign="top">
				<td>Element name:</td>
				<td>
					<span class="element">
						<xsl:value-of select="@name" />
					</span>
				</td>
			</tr>
			<tr valign="top">
				<td>Namespace:</td>
				<td>
					<span class="namespace"><xsl:value-of select="@ns" /></span>
					<!--					<xsl:choose>
						<xsl:when test="../@ns">
							<xsl:value-of select="../@ns" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$RNG//grammar/@ns" />
						</xsl:otherwise>
					</xsl:choose>-->
				</td>
			</tr>
			<xsl:if test="$attlist.mandatory">
				<tr valign="top">
					<td>Mandatory attributes:</td>
					<td>
						<xsl:call-template name="listAttributes">
							<xsl:with-param name="a" as="element()*" select="$attlist.mandatory" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$attlist.optional">
				<tr valign="top">
					<td>Optional attributes:</td>
					<td>
						<xsl:call-template name="listAttributes">
							<xsl:with-param name="a" as="element()*" select="$attlist.optional" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
			<tr valign="top">
				<td>Content model:</td>
				<td>
					<xsl:call-template name="presentContentModel">
						<xsl:with-param name="c.mandatory" as="element()*"
							select="$children.mandatory" />
						<xsl:with-param name="c.optional" as="element()*"
							select="$children.optional" />
						<xsl:with-param name="textAllowed" as="xs:boolean"
							select="boolean(descendant::text[not(ancestor::attribute)])" />
					</xsl:call-template>
				</td>
			</tr>


		</table>
		<a href="../ProfileDoc.html">Back to element toc</a>
	</xsl:template>

	<xsl:template name="presentContentModel">
		<xsl:param name="c.mandatory" as="element()*" />
		<xsl:param name="c.optional" as="element()*" />
		<xsl:param name="textAllowed" as="xs:boolean" />
		<xsl:choose>
			<xsl:when test="($c.mandatory or $c.optional) and $textAllowed"> This element
					<em>may</em> contain text. 
				<xsl:if test="$c.mandatory">
					It <em>must</em> contain the following children:
					<xsl:call-template name="listChildren">
						<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$c.optional">
					 It <em>may</em> contain the following children:
					<xsl:call-template name="listChildren">
						<xsl:with-param name="c" as="element()*" select="$c.optional" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="($c.mandatory or $c.optional) and not($textAllowed)"> This element
					<em>may not</em> contain text. <xsl:if test="$c.mandatory">
					 It <em>must</em> contain the following children:
					<xsl:call-template name="listChildren">
						<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$c.optional">
					It <em>may</em> contain the following children:
					<xsl:call-template name="listChildren">
						<xsl:with-param name="c" as="element()*" select="$c.optional" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="not($c.mandatory or $c.optional) and $textAllowed"> This element may
				contain text only. </xsl:when>
			<xsl:otherwise> This element is empty. </xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="listChildren">
		<xsl:param name="c" as="element()*" />
		<xsl:for-each select="$c">
			<xsl:sort select="@name" />
			<a class="element" href="{concat(@name,'.html')}">
				<xsl:value-of select="//define[@name eq current()/@name]/element/@name" />
			</a>
			<xsl:choose>
				<xsl:when test="position() eq last()" />
				<xsl:when test="position() eq last()-1">
					<xsl:text> and </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>, </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="listAttributes">
		<xsl:param name="a" as="element()*" />
		<xsl:for-each select="$a">
			<xsl:sort select="@name" />
			<span class="attribute">
				<xsl:value-of select="@name" />
			</span>
			<xsl:choose>
				<xsl:when test="position() eq last()" />
				<xsl:when test="position() eq last()-1">
					<xsl:text> and </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>, </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
