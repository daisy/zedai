<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xmlns:dr="http://www.daisy.org/ns/z3986/2008/docResources/" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a nsl dr">

	<xsl:param name="debug" as="xs:boolean" select="false()" />
	<xsl:param name="docTitle" as="xs:string" select="'The DAISY Leisure Profile'" />
	<xsl:param name="namespaceMode" as="xs:integer" select="1" />
	<!-- 	0:	No namespace prefix added
																			1:	Add prefix for non-default namespaces only
																			2:  Add prefix for all namespaces
	-->
	<xsl:param name="namespaceListURI" as="xs:string" select="'[UDEF]'" />
	<xsl:param name="docResourceURI" as="xs:string" select="'docResources.xml'" />
	<xsl:variable name="docResource.available" as="xs:boolean"
		select="doc-available(resolve-uri($docResourceURI))" />
	<xsl:variable name="docResource.content" as="element()">
		<xsl:choose>
			<xsl:when test="$docResource.available">
				<!-- Handle possible includes in the file -->
				<xsl:variable name="tmp01" as="element()">
					<xsl:apply-templates select="doc(resolve-uri($docResourceURI))//dr:docResources" mode="dr"
					/>	
				</xsl:variable>
				<!-- The group all elements and attributes under their relevant namespace element -->
				<xsl:apply-templates select="$tmp01" />
				
			</xsl:when>
			<xsl:otherwise>
				<noDecResourceAvailable createDummeElement="yes" usage="Nothing" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="*" mode="dr">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="dr" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="dr:include" mode="dr">
		<xsl:apply-templates select="doc(resolve-uri(@subDrURI))//dr:docResources/dr:*" mode="dr" />
	</xsl:template>
	<xsl:template match="dr:docResources">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:for-each-group select="dr:namespace" group-by="@nsURI">
				<xsl:copy>
					<xsl:copy-of select="@*" />
					<xsl:apply-templates select="current-group()/dr:*" mode="dr" />
				</xsl:copy>
			</xsl:for-each-group>
		</xsl:copy>
	</xsl:template>
	<xsl:variable name="docResource.attributes" as="element()*">
		<atts xmlns="http://www.daisy.org/ns/z3986/2008/docResources/">
			<xsl:for-each select="$docResource.content//dr:attribute">
				<xsl:sort select="@name" />
				<attribute>
					<xsl:copy-of select="@name, @docURI, @include, ../@nsURI" />
					<xsl:if test="@context">
						<xsl:attribute name="contextLocalName"
							select="substring-after(@context,':')" />
						<xsl:attribute name="contextNamespace"
							select="namespace-uri-for-prefix(substring-before(@context,':'),.)" />
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

	<xsl:variable name="defaultNamespace" as="xs:string"
		select="//define[@name eq //start/ref/@name]/element/@ns" />

	<xsl:output method="xhtml" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:template match="/">
		<xsl:message>** Generating schema documentation </xsl:message>
		<xsl:message> Profile name: <xsl:value-of select="$docTitle" /></xsl:message>
		<xsl:choose>
			<xsl:when test="$namespaceListURI eq '[UDEF]'">
				<xsl:message terminate="yes">!!! Can't continue: the parameter namespaceListURI must
					be specified!</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$debug">
					<xsl:message> Using namespace list from <xsl:value-of
							select="resolve-uri($namespaceListURI)" /></xsl:message>

					<xsl:choose>
						<xsl:when test="$docResource.available">
							<xsl:message> Using documentation resources from <xsl:value-of
									select="resolve-uri($docResourceURI)" /></xsl:message>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message> No documentation resources found.</xsl:message>
							<xsl:message> The profile documentation will be based on the schemas
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
				<title>Profile Documentation: <xsl:value-of select="$docTitle" /></title>
				<link rel="stylesheet" type="text/css" href="rng-doc.css" />
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
						<xsl:value-of
							select="hks:addNamespacePrefix(
							/grammar/define[@name eq $startPattern]/element/@name,
							/grammar/define[@name eq $startPattern]/element/@ns
							)"
						 />
					</a>
					<xsl:text>. The complete grammar comprises the following elements:</xsl:text>
				</p>
				<div class="element-toc">
					<xsl:for-each select="/grammar/define">
						<xsl:sort select="element/@name" />
						<xsl:variable name="e" as="element()" select="element" />
						<!-- Avoid duplicating elements with the same name and namespace -->
						<xsl:if
							test="not(preceding-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns])">
							<xsl:choose>
								<xsl:when
									test="following-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]">
									<a class="element" href="{concat('Elements/_',@name,'.html')}">
										<xsl:value-of
											select="hks:addNamespacePrefix(element/@name,element/@ns)" />
										<xsl:text> *</xsl:text>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="element" href="{concat('Elements/',@name,'.html')}">
										<xsl:value-of
											select="hks:addNamespacePrefix(element/@name,element/@ns)"
										 />
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<!--						<xsl:choose>
							<xsl:when
								test="preceding-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]" />
							<xsl:otherwise>
								<a class="element" href="{concat('Elements/',@name,'.html')}">
									<xsl:value-of
										select="hks:addNamespacePrefix(element/@name,element/@ns)" />
									<xsl:if
										test="following-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]">
										<xsl:text> *</xsl:text>
									</xsl:if>
								</a>
							</xsl:otherwise>
						</xsl:choose>-->
						<xsl:text>&#10;</xsl:text>
					</xsl:for-each>
				</div>
				<p>An asterisk (*) after the element name indicates an element with multiple
					definitions.</p>
			</body>
		</html>

		<xsl:for-each select="/grammar/define">
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

		<xsl:if test="$debug">
			<xsl:result-document href="_DRcontent.xml" method="xml">
				<xsl:copy-of select="$docResource.content" />
			</xsl:result-document>

			<xsl:result-document href="_ContextAtts.xml" method="xml">
				<xsl:copy-of select="$docResource.attributes" />
			</xsl:result-document>
		</xsl:if>


	</xsl:template>

	<xsl:template name="createDuplicatedElementInfo">
		<xsl:variable name="defs" as="element()+"
			select="//define[element/@name eq current()/element/@name and element/@ns eq current()/element/@ns]" />

		<xsl:result-document href="{concat('Elements/_',@name,'.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<head>
					<title>Profile Documentation: <xsl:value-of select="$docTitle" /> - the
							<xsl:value-of select="element/@name" /> element</title>
					<link rel="stylesheet" type="text/css" href="../rng-doc.css" />
				</head>
				<body>
					<h1>
						<xsl:text>The </xsl:text>
						<span class="element">
							<xsl:value-of select="element/@name" />
						</span>
						<xsl:text> element</xsl:text>
					</h1>
					<p><xsl:text>The </xsl:text>
						<span class="element">
							<xsl:value-of select="element/@name" />
						</span>
						<xsl:text> element is available in </xsl:text><xsl:value-of
							select="count($defs)" />
						<xsl:text> different versions</xsl:text>.</p>
					<ul class="duplicatedElementMenu">
						<xsl:for-each select="$defs">
							<!-- Get the possible parents -->
							<xsl:variable name="ref.by" as="element()+"
								select="//define[some $e in descendant::ref satisfies $e/@name eq current()/@name]" />
							<xsl:variable name="ref.by.filtered" as="element()+"
								select="$ref.by[not(element/@name eq current()/element/@name and current()/element/@ns)]" />
							<li>
								<a href="{concat('#',generate-id(element))}">
									<xsl:text>The </xsl:text>
									<span class="element">
										<xsl:value-of select="element/@name" />
									</span>
									<xsl:text> element as child of </xsl:text>
									<xsl:for-each select="$ref.by.filtered">
										<xsl:sort select="@name" />
										<span class="element">
											<xsl:value-of
												select="hks:addNamespacePrefix(
												//define[@name eq current()/@name]/element/@name,
												//define[@name eq current()/@name]/element/@ns
												)"
											 />
										</span>
										<xsl:choose>
											<xsl:when test="position() eq last()" />
											<xsl:when test="position() eq last()-1">
												<xsl:text> or </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>, </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</a>
							</li>
						</xsl:for-each>
					</ul>

					<xsl:for-each select="$defs">
						<xsl:apply-templates select="element" />
					</xsl:for-each>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>
	<xsl:template name="createElementInfo">
		<xsl:result-document href="{concat('Elements/',@name,'.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<head>
					<title>Profile Documentation: <xsl:value-of select="$docTitle" /> - the
							<xsl:value-of select="element/@name" /> element</title>
					<link rel="stylesheet" type="text/css" href="../rng-doc.css" />
				</head>
				<body>
					<xsl:call-template name="createNavigationBox" />
					<h1>
						<xsl:text>The </xsl:text>
						<span class="element">
							<xsl:value-of select="element/@name" />
						</span>
						<xsl:text> element</xsl:text>
					</h1>
					<xsl:apply-templates select="element" />
					<!--<hr />
					<a class="toc-link" href="../index.html">Back to element toc</a>-->
					<xsl:call-template name="createNavigationBox" />
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>

	<xsl:template name="createNavigationBox">
		<div class="nav-box">
			<xsl:if test="preceding-sibling::define">
				<a class="previous-element"
					href="{concat(preceding-sibling::define[1]/@name,'.html')}">
					<xsl:text>Previous: </xsl:text>
					<xsl:value-of
						select="hks:addNamespacePrefix(preceding-sibling::define[1]/element/@name,preceding-sibling::define[1]/element/@ns)"
					 />
				</a>
			</xsl:if>
			<a class="toc-link" href="../index.html">Back to element toc</a>
			<xsl:if test="following-sibling::define">
				<a class="next-element" href="{concat(following-sibling::define[1]/@name,'.html')}">
					<xsl:text>Next: </xsl:text>
					<xsl:value-of
						select="hks:addNamespacePrefix(following-sibling::define[1]/element/@name,following-sibling::define[1]/element/@ns)"
					 />
				</a>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="element">
		<xsl:variable name="el.name" as="xs:string" select="@name" />
		<xsl:variable name="attlist" as="element()*" select="descendant::attribute" />
		<xsl:variable name="attlist.optional" as="element()*"
			select="descendant::attribute[ancestor::optional]" />
		<xsl:variable name="attlist.mandatory" as="element()*"
			select="descendant::attribute[not(ancestor::optional)]" />
		<xsl:variable name="children" as="element()*" select="descendant::ref" />
		<xsl:variable name="children.optional" as="element()*"
			select="$children[ancestor::optional or ancestor::zeroOrMore or ancestor::choice]" />
		<xsl:variable name="children.mandatory" as="element()*"
			select="$children except $children.optional" />

		<xsl:variable name="elementInformation" as="element()">
			<div>
				<div class="element-coreinfo">
					<h2>Element name</h2>
					<p>
						<span class="element">
							<xsl:value-of select="hks:addNamespacePrefix(@name,@ns)" />
						</span>
					</p>
					<xsl:if test="$docResource.available">
						<!-- Element name -->
						<xsl:variable name="e.name" as="xs:string" select="@name" />
						<!-- ... and namespace -->
						<xsl:variable name="e.ns" as="xs:string"
							select="if (@ns eq '') then $defaultNamespace else @ns" />
						<xsl:variable name="relevant.doc" as="element()?"
							select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/dr:element[@name eq $e.name]" />
						<xsl:if test="$relevant.doc/@include eq 'yes'">
							<xsl:variable name="filename" as="xs:string"
								select="substring-before($relevant.doc/@docURI,'#')" />
							<xsl:variable name="fragment" as="xs:string"
								select="substring-after($relevant.doc/@docURI,'#')" />
							<xsl:if
								test="doc($filename)//*[@id eq $fragment]/*[@class eq 'description']">
								<h2>Description</h2>
								<xsl:copy-of
									select="doc($filename)//*[@id eq $fragment]/*[@class eq 'description']"
								 />
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<h2>Namespace</h2>
					<p>
						<span class="namespace">
							<xsl:value-of select="@ns" />
						</span>
					</p>
					<h2>Posssible children</h2>
					<xsl:call-template name="presentPossibleChildren">
						<xsl:with-param name="c.mandatory" as="element()*"
							select="$children.mandatory" />
						<xsl:with-param name="c.optional" as="element()*"
							select="$children.optional" />
						<xsl:with-param name="textAllowed" as="xs:boolean"
							select="boolean(descendant::text[not(ancestor::attribute)])" />
					</xsl:call-template>
					<h2>Possible parents</h2>
					<xsl:call-template name="presentPossibleParents" />
					<h2>Content model</h2>
					<xsl:call-template name="presentContentModel" />
					<h2>Attributes</h2>
					<xsl:choose>
						<xsl:when test="$attlist">
							<xsl:call-template name="presentAttributes">
								<xsl:with-param name="a" as="element()*" select="$attlist" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<p>No attributes are allowed on this element.</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:if test="$docResource.available">
					<!-- Element name -->
					<xsl:variable name="e.name" as="xs:string" select="@name" />
					<!-- ... and namespace -->
					<xsl:variable name="e.ns" as="xs:string"
						select="if (@ns eq '') then $defaultNamespace else @ns" />
					<xsl:variable name="relevant.doc" as="element()?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/dr:element[@name eq $e.name]" />
					<xsl:variable name="default.doc.url" as="xs:string?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/@defaultDocURL" />


					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@include eq 'yes'">
									<div class="element-docprose">
										<xsl:call-template name="getDocProse">
											<xsl:with-param name="docURI" as="xs:string"
												select="$relevant.doc/@docURI" />
										</xsl:call-template>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>More information about this element can be found at </xsl:text>
									<br />
									<a target="_blank" href="{$relevant.doc/@docURI}">
										<xsl:value-of select="$relevant.doc/@docURI" />
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$default.doc.url">
									<xsl:text>Some general information about elements and attributes in this namespace may be found at</xsl:text>
									<br />
									<a target="_blank" href="{$default.doc.url}">
										<xsl:value-of select="$default.doc.url" />
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>No further information about this element is
									available.</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>
		</xsl:variable>

		<div class="elementInformation" id="{generate-id()}">
			<ul class="element-toc">
				<xsl:for-each select="$elementInformation//*[matches(local-name(),'^h[1-6]$')]">
					<li class="{local-name()}">
						<a href="{concat('#',$el.name,'-',generate-id())}">
							<xsl:value-of select="." />
						</a>
					</li>
				</xsl:for-each>
			</ul>
			<xsl:apply-templates select="$elementInformation/*:div" mode="ei">
				<xsl:with-param name="elementName" as="xs:string" select="@name" tunnel="yes" />
			</xsl:apply-templates>
		</div>
	</xsl:template>
	<xsl:template match="*" mode="ei">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="ei" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[matches(local-name(),'^h[1-6]$')]" mode="ei">
		<xsl:param name="elementName" as="xs:string" tunnel="yes" />
		<xsl:copy>
			<xsl:copy-of select="@* except @id" />
			<xsl:attribute name="id" select="concat($elementName,'-',generate-id())" />
			<xsl:apply-templates mode="ei" />
		</xsl:copy>
	</xsl:template>

	<xsl:template name="presentAttributes">
		<xsl:param name="a" as="element()*" />
		<table class="attributes">
			<col class="attrib-name" />
			<col class="attrib-presence" />
			<col class="attrib-value" />
			<tr valign="top">
				<th>Name</th>
				<th>Presence</th>
				<th>Value</th>
			</tr>
			<xsl:for-each select="$a[not(ancestor::optional)]">
				<xsl:sort select="@name" />
				<xsl:call-template name="createAttributeInfo" />
			</xsl:for-each>
			<xsl:for-each select="$a[ancestor::optional]">
				<xsl:sort select="@name" />
				<xsl:call-template name="createAttributeInfo" />
			</xsl:for-each>
		</table>
	</xsl:template>
	<xsl:template name="createAttributeInfo">
		<!-- Element name -->
		<xsl:variable name="e.name" as="xs:string" select="ancestor::element/@name" />
		<!-- Element namespace -->
		<xsl:variable name="e.ns" as="xs:string"
			select=" if (ancestor::element/@ns eq '') then $defaultNamespace else ancestor::element/@ns" />
		<!-- Attribute name -->
		<xsl:variable name="attrib.name" as="xs:string" select="@name" />
		<!-- Attribute namespace -->
		<!--<xsl:variable name="attrib.ns" as="xs:string"
		select="if (@ns eq '') then $defaultNamespace else @ns" />-->
		<xsl:variable name="attrib.ns" as="xs:string" select="@ns" />
		<tr valign="top">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="ancestor::optional">
						<xsl:value-of select="'optional'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'required'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<td>
				<span class="attribute">
					<xsl:value-of select="hks:addNamespacePrefix(@name,@ns)" />
				</span>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="ancestor::optional"> Optional </xsl:when>
					<xsl:otherwise> Required </xsl:otherwise>
				</xsl:choose>

			</td>
			<td>
				<xsl:apply-templates mode="acm" />
			</td>
		</tr>
		<xsl:if test="$docResource.available">
			<!--			<xsl:variable name="ns.list" as="xs:string*"
				select="in-scope-prefixes($docResource.content)" />
			<xsl:variable name="possible.docs" as="element()*"
				select="$docResource.content//dr:attribute[@name eq $attrib.name]" />
-->
			<!--<xsl:variable name="relevant.doc" as="element()?"
select="$docResource.content//dr:namespace[@nsURI eq $attrib.ns]/dr:attribute[@name eq $attrib.name]" />-->
			<xsl:variable name="relevant.doc" as="element()*">
				<xsl:choose>
					<xsl:when
						test="$docResource.attributes//dr:attribute[
						@name eq $attrib.name 
						and @nsURI eq $attrib.ns
						and @contextLocalName eq $e.name
						and @contextNamespace eq $e.ns
						]">
						<!-- If possible, pick the attribute element with the correct name, namespace and context -->
						<xsl:sequence
							select="$docResource.attributes//dr:attribute[
							@name eq $attrib.name 
							and @nsURI eq $attrib.ns
							and @contextLocalName eq $e.name
							and @contextNamespace eq $e.ns
							]"
						 />
					</xsl:when>
					<xsl:when
						test="$docResource.attributes//dr:attribute[
						@name eq $attrib.name 
						and @contextLocalName eq $e.name
						and @contextNamespace eq $e.ns
						]">
						<!-- If above not found, try to pick the attribute element with the correct name and context -->
						<xsl:sequence
							select="$docResource.attributes//dr:attribute[
							@name eq $attrib.name 
							and @contextLocalName eq $e.name
							and @contextNamespace eq $e.ns
							]"
						 />
					</xsl:when>
					<xsl:when
						test="$docResource.attributes//dr:attribute[
						@name eq $attrib.name 
						and @nsURI eq $attrib.ns]">
						<!-- If above not found, try to pick the attribute element with the correct name and namespace (and with no context) -->
						<xsl:sequence
							select="$docResource.attributes//dr:attribute[
							@name eq $attrib.name 
							and @nsURI eq $attrib.ns
							and not(@contextLocalName)
							]"
						 />
					</xsl:when>
					<xsl:otherwise>
						<!-- As a last resort, the try to pick the one with the correct name (and with no context)-->
						<xsl:sequence
							select="$docResource.attributes//dr:attribute[
							@name eq $attrib.name
							and not(@contextLocalName)
							]"
						 />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="default.doc.url" as="xs:string?"
				select="$docResource.content//dr:namespace[@nsURI eq $attrib.ns]/@defaultDocURL" />
			<tr valign="top">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="ancestor::optional">
							<xsl:value-of select="'attribdoc-optional'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'attribdoc-required'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<td colspan="2" />
				<td>
					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@include eq 'yes'">
									<xsl:call-template name="getDocProse">
										<xsl:with-param name="docURI" as="xs:string"
											select="$relevant.doc/@docURI" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>More information about this attribute can be found at </xsl:text>
									<br />
									<a target="_blank" href="{$relevant.doc/@docURI}">
										<xsl:value-of select="$relevant.doc/@docURI" />
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$default.doc.url">
									<xsl:text>Some general information about elements and attributes in this namespace may be found at</xsl:text>
									<br />
									<a target="_blank" href="{$default.doc.url}">
										<xsl:value-of select="$default.doc.url" />
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>No further information about this attribute is
										available.</xsl:text>
									<!--									<xsl:message>name: <xsl:value-of select="$attrib.name" /></xsl:message>
										<xsl:message>ns: <xsl:value-of select="$attrib.ns" /></xsl:message>-->
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</td>

			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template name="presentContentModel">
		<xsl:variable name="cm" as="element()*"
			select="group/child::*[not(descendant-or-self::attribute)]" />
		<xsl:choose>
			<xsl:when test="count($cm) = 0"> Empty </xsl:when>
			<xsl:when test="count($cm) = 1">
				<xsl:apply-templates select="$cm" mode="cm" />
			</xsl:when>
			<xsl:otherwise>
				<table class="cm-table">
					<col class="sub1" />
					<col class="sub2" />
					<xsl:for-each select="$cm">
						<tr valign="top">
							<td>
								<xsl:choose>
									<xsl:when test="position() = 1">First</xsl:when>
									<xsl:otherwise>followed by</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:apply-templates select="." mode="cm" />
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="presentPossibleChildren">
		<xsl:param name="c.mandatory" as="element()*" />
		<xsl:param name="c.optional" as="element()*" />
		<xsl:param name="textAllowed" as="xs:boolean" />
		<p>
			<xsl:choose>
				<xsl:when test="($c.mandatory or $c.optional) and $textAllowed">
					<xsl:text>This element </xsl:text>
					<em>may</em>
					<xsl:text> contain text. </xsl:text>
					<xsl:if test="$c.mandatory">
						<xsl:text>It </xsl:text>
						<em>must</em>
						<xsl:text> contain the following children:</xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$c.optional">
						<xsl:text>It </xsl:text>
						<em>may</em>
						<xsl:text> contain the following children:</xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.optional" />
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="($c.mandatory or $c.optional) and not($textAllowed)">
					<xsl:text>This element </xsl:text>
					<em>can not</em>
					<xsl:text> contain text. </xsl:text>
					<xsl:if test="$c.mandatory">
						<xsl:text>It </xsl:text>
						<em>must</em>
						<xsl:text> contain the following children:</xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$c.optional">
						<xsl:text>It </xsl:text>
						<em>may</em>
						<xsl:text> contain the following children:</xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.optional" />
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="not($c.mandatory or $c.optional) and $textAllowed">
					<xsl:text>This element may
					contain text only. </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>None. </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>

	<xsl:template name="presentPossibleParents">
		<xsl:variable name="pattern.name" as="xs:string" select="../@name" />
		<xsl:variable name="ref.by" as="element()*"
			select="//define[some $e in descendant::ref satisfies $e/@name eq $pattern.name]" />
		<p>
			<xsl:choose>
				<xsl:when test="$ref.by">
					<xsl:call-template name="listChildren">
						<xsl:with-param name="c" as="element()*" select="$ref.by" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>None, this is the root element.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>


	<xsl:template match="optional" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] Optional:</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>
	<xsl:template match="interleave" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] A mixture of:</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>
	<xsl:template match="zeroOrMore" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] Zero or more of:</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>
	<xsl:template match="oneOrMore" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] At least one or more
				of:</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>
	<xsl:template match="text" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] Text content</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>

	<xsl:template match="ref" mode="cm">
		<xsl:call-template name="listChildren">
			<xsl:with-param name="c" select="." as="element()*" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="choice[every $e in child::* satisfies local-name($e) eq 'ref']" mode="cm">
		<div class="rng">
			<span class="rng">[<xsl:value-of select="local-name()" />] One of the following
				elements: </span>
			<xsl:call-template name="listChildren">
				<xsl:with-param name="c" select="ref" as="element()*" />
			</xsl:call-template>
		</div>
	</xsl:template>

	<!-- For other rng elements, simply present the local-name() and continue -->
	<xsl:template match="*" mode="cm" priority="-5">
		<div class="rng">
			<span class="rng-x">
				<xsl:value-of select="local-name()" />
			</span>
			<div class="rng-content">
				<xsl:apply-templates mode="cm" />
			</div>
		</div>
	</xsl:template>


	<xsl:template name="listChildren">
		<xsl:param name="c" as="element()*" />
		<xsl:for-each select="$c">
			<xsl:sort select="@name" />
			<a class="element" href="{concat(@name,'.html')}">
				<xsl:value-of
					select="hks:addNamespacePrefix(
					//define[@name eq current()/@name]/element/@name,
					//define[@name eq current()/@name]/element/@ns
					)"
				 />
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


	<xsl:template name="getDocProse">
		<xsl:param name="docURI" as="xs:string" />
		<xsl:variable name="filename" as="xs:string" select="substring-before($docURI,'#')" />
		<xsl:variable name="fragment" as="xs:string" select="substring-after($docURI,'#')" />
		<!--<xsl:copy-of select="doc($filename)//*[@id eq $fragment]/child::node()" />-->
		<xsl:apply-templates select="doc($filename)//*[@id eq $fragment]/child::node()"
			mode="docprose" />
	</xsl:template>
	<xsl:template match="*" mode="docprose">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="docprose" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[@class eq 'description']" mode="docprose" />
	<!-- Don't copy the description information -->


	<xsl:template match="attribute/data" mode="acm"> Some value of type <span class="rng-datatype">
			<xsl:value-of select="@type" />
		</span>
		<xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="attribute/text" mode="acm"> Any string <xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="data" mode="acm"> value(s) of type <span class="rng-datatype">
			<xsl:value-of select="@type" />
		</span>
		<xsl:apply-templates mode="acm" />
	</xsl:template>


	<xsl:template match="list" mode="acm"> A white space separated list of <xsl:apply-templates
			mode="acm" />
	</xsl:template>

	<xsl:template match="oneOrMore" mode="acm"> one or more <xsl:apply-templates mode="acm" />
	</xsl:template>


	<xsl:template match="param[@name eq 'pattern']" mode="acm"> satisfying the pattern<br />
		<xsl:text>"</xsl:text><span class="rng-pattern">
			<xsl:apply-templates mode="acm" />
		</span>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="choice" mode="acm">
		<!--<span class="rng">One of:</span>--> One of <xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="choice/value" mode="acm">
		<!--<xsl:text>&quot;</xsl:text>-->
		<span class="{concat('rng-value-',@type)}">
			<xsl:apply-templates mode="acm" />
		</span>
		<!--<xsl:text>&quot;</xsl:text>-->
		<xsl:choose>
			<xsl:when test="not(following-sibling::value)">.</xsl:when>
			<xsl:when test="count(following-sibling::value) = 1"> or </xsl:when>
			<!--			<xsl:when test="position() eq last()" />
			<xsl:when test="position() eq last()-1">
				<xsl:text> and </xsl:text>
			</xsl:when>
-->
			<xsl:otherwise>
				<xsl:text>, </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="acm">
		<div class="rng">
			<strong>
				<xsl:value-of select="local-name()" />
			</strong>
			<xsl:text>: </xsl:text>
			<xsl:apply-templates mode="acm" />
		</div>
	</xsl:template>


	<xsl:function name="hks:addNamespacePrefix" as="xs:string">
		<xsl:param name="name" as="xs:string" />
		<xsl:param name="ns" as="xs:string" />

		<xsl:choose>
			<xsl:when test="$namespaceMode = 2">
				<xsl:value-of
					select="
					concat(
						hks:namespace2Prefix(
							if ($ns eq '') then $defaultNamespace else $ns
						),
						':',
						$name
						)"
				 />
			</xsl:when>
			<xsl:when test="$namespaceMode = 1">
				<xsl:choose>
					<xsl:when test="$ns eq $defaultNamespace or $ns eq ''">
						<xsl:value-of select="$name" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(hks:namespace2Prefix($ns),':',$name)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="hks:namespace2Prefix" as="xs:string">
		<xsl:param name="n" as="xs:string" />

		<xsl:choose>
			<xsl:when test="doc($namespaceListURI)//nsl:namespace[. = $n]">
				<xsl:value-of select="doc($namespaceListURI)//nsl:namespace[. = $n]/@prefix" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'?'" />
				<!--<xsl:message> Unknow namespace: <xsl:value-of select="$n" /></xsl:message>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="testNamespaces">
		<xsl:for-each select="distinct-values(//@ns[. ne ''])">
			<xsl:if test="not(doc($namespaceListURI)//nsl:namespace[. = current()])">
				<xsl:message>
					<xsl:text>   !! The namespace </xsl:text>
					<xsl:value-of select="." />
					<xsl:text> is not defined in the namespace list.</xsl:text>
				</xsl:message>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
