<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xmlns:dr="http://www.daisy.org/ns/z3986/2008/docResources/" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a nsl dr">

	<xsl:include href="rng-doc-xpath-templates.xsl" />
	<xsl:include href="rng-doc-named-templates.xsl" />
	<xsl:include href="rng-doc-functions.xsl" />
	<!-- TODO:
	* Handle documentation of elements that can occur in different contexts (section is an example) 
	* Solve the URI resolve problem (see mail from Marisa and Markus 1. april) when XSLT and resource files do not live in the same folder
	* Better feature handling:
		An element/attribute is a feature iff
			the element or attrib is represented in the Doc Resource File as a child of a
			namespace element with @feature="yes"
	-->

	<!-- PARAMETERS -->
	<xsl:param name="debug" as="xs:string" select="'0'" />
	<xsl:param name="docTitle" as="xs:string" select="'The DAISY Leisure Profile'" />
	<xsl:param name="namespaceMode" as="xs:integer" select="1" />
	<!-- 	0:	No namespace prefix added
																			1:	Add prefix for non-default namespaces only
																			2:  Add prefix for all namespaces
	-->
	<xsl:param name="namespaceListURI" as="xs:string" select="'[UDEF]'" />
	<xsl:param name="docResourceURI" as="xs:string" select="'docResources.xml'" />

	<!-- VARIABLES -->

	<xsl:variable name="Debug" as="xs:boolean" select="matches($debug,'^yes|1|ok|true$','i')" />

	<xsl:variable name="docResource.available" as="xs:boolean"
		select="doc-available(resolve-uri($docResourceURI))" />
	<xsl:variable name="docResource.content" as="element()">
		<xsl:choose>
			<xsl:when test="$docResource.available">
				<!-- Handle possible includes in the file -->
				<xsl:variable name="tmp01" as="element()">
					<xsl:apply-templates select="doc(resolve-uri($docResourceURI))//dr:docResources"
						mode="dr" />
				</xsl:variable>
				<!-- Then group all elements and attributes under their relevant namespace element -->
				<xsl:apply-templates select="$tmp01" />

			</xsl:when>
			<xsl:otherwise>
				<noDecResourceAvailable createDummyElement="yes" usage="Nothing" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:variable name="docResource.elements" as="element()*">
		<els xmlns="http://www.daisy.org/ns/z3986/2008/docResources/">
			<xsl:for-each select="$docResource.content//dr:element">
				<xsl:sort select="@name" />
				<element>
					<xsl:copy-of select="@name, @descriptionURI, @descriptionInclude, ../@nsURI, @context" />
					<xsl:if test="@context">
						<xsl:attribute name="contextLocalName"
							select="substring-after(@context,':')" />
						<xsl:attribute name="contextNamespace"
							select="namespace-uri-for-prefix(substring-before(@context,':'),.)" />
					</xsl:if>
				</element>
			</xsl:for-each>
			<xsl:for-each select="$docResource.content//dr:namespace">
				<defaultDoc>
					<xsl:copy-of select="@*" />
				</defaultDoc>
			</xsl:for-each>
		</els>
	</xsl:variable>


	<xsl:variable name="defaultNamespace" as="xs:string"
		select="//define[@name eq //start/ref/@name]/element/@ns" />

	<xsl:variable name="sRNGdefs" as="element()*" select="//define" />

	<xsl:variable name="docResource.attributes" as="element()*">
		<atts xmlns="http://www.daisy.org/ns/z3986/2008/docResources/">
			<xsl:for-each select="$docResource.content//dr:attribute">
				<xsl:sort select="@name" />
				<attribute>
					<xsl:copy-of select="@name, @descriptionURI, @descriptionInclude, ../@nsURI" />
					<xsl:if test="@context">
						<xsl:choose>
							<xsl:when test="contains(@context,':')">
								<xsl:attribute name="contextLocalName"
									select="substring-after(@context,':')" />
								<xsl:attribute name="contextNamespace"
									select="namespace-uri-for-prefix(substring-before(@context,':'),.)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="contextLocalName"
									select="@context" />
								<xsl:attribute name="contextNamespace"
									select="$defaultNamespace" />
							</xsl:otherwise>
						</xsl:choose>
<!--						<xsl:attribute name="contextLocalName"
							select="substring-after(@context,':')" />
						<xsl:attribute name="contextNamespace"
							select="namespace-uri-for-prefix(substring-before(@context,':'),.)" />-->
					</xsl:if>
				</attribute>
			</xsl:for-each>
			<xsl:for-each select="$docResource.content//dr:namespace">
				<defaultDoc>
					<xsl:copy-of select="@*" />
				</defaultDoc>
			</xsl:for-each>
		</atts>
	</xsl:variable>

	<!-- DEFINE OUTPUT -->
	<xsl:output method="xhtml" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<!-- TEMPLATE MATCH8ING ROOT -->
	<xsl:template match="/">
		<xsl:message>** Generating schema documentation </xsl:message>
		<xsl:message> Profile name: <xsl:value-of select="$docTitle" /></xsl:message>
		<xsl:choose>
			<xsl:when test="$namespaceListURI eq '[UDEF]'">
				<xsl:message terminate="yes">!!! Can't continue: the parameter namespaceListURI must
					be specified!</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$Debug">
					<xsl:message> Using namespace list from <xsl:value-of
							select="resolve-uri($namespaceListURI)" /></xsl:message>

					<xsl:choose>
						<xsl:when test="$docResource.available">
							<xsl:message> Using documentation resources from <xsl:value-of
									select="resolve-uri($docResourceURI)" /></xsl:message>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message> No documentation resources found.</xsl:message>
							<xsl:message> The schema documentation will be based on the schemas
								only, with no extra information.</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:message> Default namespace: <xsl:value-of select="$defaultNamespace"
						 /></xsl:message>
					<xsl:choose>
						<xsl:when test="$namespaceMode = 0">
							<xsl:message> No namespace prefixes will be added!</xsl:message>
						</xsl:when>
						<xsl:when test="$namespaceMode = 1">
							<xsl:message> Adding prefix for non-default namespaces</xsl:message>
						</xsl:when>
						<xsl:when test="$namespaceMode = 2">
							<xsl:message> Adding prefix for all namespaces</xsl:message>
						</xsl:when>
						<xsl:otherwise />
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="testNamespaces" />

		<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
			<head>
				<title>Schema Documentation: <xsl:value-of select="$docTitle" /></title>
				<link rel="stylesheet" type="text/css" href="rng-doc.css" />
			</head>
			<body style="margin-top:4em;margin-bottom:2em;">
				<h1>Schema Documentation: <span class="doctitle">
						<xsl:value-of select="$docTitle" />
					</span></h1>
				<p>
					<xsl:variable name="startPattern" as="xs:string" select="//start/ref/@name" />

					<xsl:text>Below is a list of all elements in this profile.</xsl:text>
					<br />
					<xsl:text>An asterisk (*) after the element name indicates an element with multiple
					definitions.</xsl:text>
					<br />
					<xsl:text>The root element in this grammar is </xsl:text>
					<a class="element">
						<xsl:attribute name="href"
							select="concat('Elements/',//start/ref/@name,'.html')" />
						<xsl:value-of
							select="hks:addNamespacePrefix(
							/grammar/define[@name eq $startPattern]/element/@name,
							/grammar/define[@name eq $startPattern]/element/@ns
							)"
						 />
					</a>
				</p>
				<h2>The core set of elements</h2>
				<xsl:for-each-group select="/grammar/define[element/@name][not(hks:elementIsAFeatureNew(element))]"
					group-by="element/@ns">
					<h3> Elements in the namespace <xsl:value-of select="current-grouping-key()"
						 /></h3>
					<p>
						<xsl:choose>
							<xsl:when test="current-grouping-key() eq $defaultNamespace"> These
								elements belong to the default namespace, so no namespace prefixing
								is required.</xsl:when>
							<xsl:otherwise> These elements do not belong to the default namespace,
								so namespace prefixing is required. </xsl:otherwise>
						</xsl:choose>

					</p>
					<ul class="main-element-toc">
						<xsl:call-template name="presentElements">
							<xsl:with-param name="elementsToPresent" select="current-group()" />
						</xsl:call-template>
					</ul>
				</xsl:for-each-group>

				<xsl:if test="hks:profileContainsFeatureElements(/grammar)">
					<h2>Features</h2>
					<p>Depending on the variant of the profile, some features may not be available. </p>
					<xsl:for-each-group select="/grammar/define[element/@name][hks:elementIsAFeatureNew(element)]"
						group-by="hks:featureNicenameFromElement(element)">
						<xsl:sort select="hks:featureNicenameFromElement(element)" />
						<h3>
							<xsl:value-of select="current-grouping-key()" />
						</h3>
						<p>
							<xsl:choose>
								<xsl:when
									test="every $e in current-group()/element satisfies ($e/@ns eq '' or $e/@ns eq $defaultNamespace)"
									> All elements in the <xsl:value-of
										select="concat('&#171;',current-grouping-key(),'&#187;')"
									 /> feature belong to the default namespace, so no namespace
									prefixing is required. </xsl:when>
								<xsl:when
									test="some $e in current-group()/element satisfies ($e/@ns eq '' or $e/@ns eq $defaultNamespace)"
									> Some elements in the <xsl:value-of
										select="concat('&#171;',current-grouping-key(),'&#187;')"
									 /> feature belong to the default namespace, so namespace
									prefixing is only required for some of the elements. </xsl:when>
								<xsl:otherwise> No elements in the <xsl:value-of
										select="concat('&#171;',current-grouping-key(),'&#187;')"
									 /> feature belong to the default namespace, so namespace
									prefixing is required. </xsl:otherwise>
							</xsl:choose>
						</p>
						<ul class="main-element-toc">
							<xsl:call-template name="presentElements">
								<xsl:with-param name="elementsToPresent" select="current-group()" />
							</xsl:call-template>
						</ul>
					</xsl:for-each-group>
				</xsl:if>

<!--				<h2>The core set of elements</h2>
				<xsl:for-each-group select="/grammar/define[not(hks:elementIsAFeature(element))]"
					group-by="element/@ns">
					<h3> Elements in the namespace <xsl:value-of select="current-grouping-key()" />
					</h3>
					<p>
						<xsl:choose>
							<xsl:when test="current-grouping-key() eq $defaultNamespace"> These
								elements belong to the default namespace, so no namespace prefixing
								is required.</xsl:when>
							<xsl:otherwise> These elements do not belong to the default namespace,
								so namespace prefixing is required. </xsl:otherwise>
						</xsl:choose>

					</p>
					<ul class="main-element-toc">
						<xsl:call-template name="presentElements">
							<xsl:with-param name="elementsToPresent" select="current-group()" />
						</xsl:call-template>
					</ul>
				</xsl:for-each-group>


				<xsl:if test="hks:profileContainsFeatures(distinct-values(//@ns))">
					<h2>Features</h2>
					<p>Depending on the variant of the profile, some features may no be available. </p>
					<xsl:for-each-group select="/grammar/define[hks:elementIsAFeature(element)]"
						group-by="element/@ns">
						<h3>
							<xsl:value-of
								select="hks:featureNicenameFromNamespace(current-grouping-key())" />
						</h3>
						<p> These elements do not belong to the default namespace, so namespace
							prefixing is required.</p>
						<ul class="main-element-toc">
							<xsl:call-template name="presentElements">
								<xsl:with-param name="elementsToPresent" select="current-group()" />
							</xsl:call-template>
						</ul>
					</xsl:for-each-group>
				</xsl:if>-->

			</body>
		</html>

		<xsl:for-each select="/grammar/define[element/@name]">
			<!--<xsl:message><xsl:value-of select="@name"/></xsl:message>-->
			<xsl:variable name="e" as="element()" select="element" />
			<xsl:call-template name="createElementInfo" />
			<xsl:if
				test="
					following-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]
					and 
					not(preceding-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns])
				">
				<xsl:call-template name="createDuplicatedElementInfo" />
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="$Debug">

			<xsl:result-document href="_DRcontent.xml" method="xml">
				<xsl:copy-of select="$docResource.content" />
			</xsl:result-document>

			<xsl:result-document href="_ContextAtts.xml" method="xml">
				<xsl:copy-of select="$docResource.attributes" />
			</xsl:result-document>

			<xsl:result-document href="_ContextEls.xml" method="xml">
				<xsl:copy-of select="$docResource.elements" />
			</xsl:result-document>
		</xsl:if>

		<!--		<xsl:for-each select="//element">
			<xsl:if test="@name eq 'label'">
				<xsl:message>Element: <xsl:value-of select="@name"/></xsl:message>
							<xsl:message> Number of possible parents: <xsl:value-of select="count(hks:possibleParentsForElement(.))"/></xsl:message>
			<xsl:message> Parents (1): <xsl:value-of select="hks:QNamesForPossibleElementParents(.)"/></xsl:message>
			<xsl:message> Parents (2): <xsl:value-of select="hks:namesForPossibleElementParents(.)"/></xsl:message>
				<xsl:message> DR.count: <xsl:value-of
						select="hks:getDocResourceForElement(.)/@descriptionURI"/></xsl:message>
			</xsl:if>
		</xsl:for-each>-->
		<!--<xsl:call-template name="createAttributeFiles"></xsl:call-template>-->
	</xsl:template>






</xsl:stylesheet>
