<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xmlns:dr="http://www.daisy.org/ns/z3986/2008/docResources/" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a nsl dr">


	<!--	<xsl:template name="presentElements">
		<xsl:param name="elementsToPresent" as="element()*"/>
		<xsl:for-each select="$elementsToPresent">
			<xsl:sort select="element/@name"/>
			<xsl:variable name="e" as="element()" select="element"/>
			<xsl:if
				test="not(preceding-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns])">
				<xsl:choose>
					<xsl:when
						test="following-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]">
						<a class="element" href="{concat('Elements/_',@name,'.html')}">
							<xsl:value-of select="hks:addNamespacePrefix(element/@name,element/@ns)"/>
							<xsl:text> *</xsl:text>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a class="element" href="{concat('Elements/',@name,'.html')}">
							<xsl:value-of select="hks:addNamespacePrefix(element/@name,element/@ns)"
							/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>
	</xsl:template>-->

	<xsl:template name="presentElementDescription">
		<xsl:param name="elementDR" as="element()?" tunnel="yes" />
		<xsl:variable name="filename" as="xs:string"
			select="substring-before($elementDR/@descriptionURI,'#')" />
		<xsl:variable name="fragment" as="xs:string"
			select="substring-after($elementDR/@descriptionURI,'#')" />
		<xsl:variable name="description" as="element()*">
			<xsl:if test="doc-available($filename)">
				<xsl:apply-templates
					select="doc($filename)//*[@id eq $fragment]/*[@class eq 'description']"
					mode="docprosedescription" />
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$description">
			<h2>Description</h2>
			<xsl:copy-of select="$description" />
		</xsl:if>
		<!--		Description: <xsl:value-of select="$filename"/>: <xsl:value-of select="doc-available($filename)"/> <br />
		Description: <xsl:value-of select="resolve-uri($filename)"/>: <xsl:value-of select="doc-available(resolve-uri($filename))"/><br /> -->
	</xsl:template>
	<xsl:template name="presentElementShortSample">
		<xsl:param name="elementDR" as="element()?" tunnel="yes" />
		<xsl:variable name="filename" as="xs:string"
			select="substring-before($elementDR/@shortSampleURI,'#')" />
		<xsl:variable name="fragment" as="xs:string"
			select="substring-after($elementDR/@shortSampleURI,'#')" />
		<xsl:variable name="sample" as="element()*">
			<xsl:if test="doc-available($filename)">
				<xsl:apply-templates select="doc($filename)//*[@id eq $fragment]/*"
					mode="docprosedescription" />
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$filename ne ''">
			<xsl:variable name="t.filename" as="xs:string"
				select="translate(replace($filename,'^(.+)/(.+?)$','$2'),'.','_')" />
			<!--<xsl:variable name="t.uri" as="xs:string"
				select="concat('file:/',$tempFolder,$t.filename,'_',$fragment,'.txt')" />-->
			<xsl:variable name="t.uri" as="xs:string"
				select="concat($tempFolder,$t.filename,'_',$fragment,'.txt')" />
			<!--			<xsl:message>
				<xsl:value-of select="$t.uri" />
			</xsl:message>-->
			<xsl:variable name="t.content" as="xs:string?" select="unparsed-text($t.uri)" />
			<h2>Short Sample</h2>
			<pre>
				<xsl:value-of select="replace($t.content,' xmlns=&quot;http://www.w3.org/1999/xhtml&quot;','')" />
			</pre>
		</xsl:if>
	</xsl:template>
	<xsl:template name="presentElementAdditionalInfo">
		<xsl:param name="elementDR" as="element()?" tunnel="yes" />
		<xsl:variable name="filename" as="xs:string"
			select="substring-before($elementDR/@additionalInfoURI,'#')" />
		<xsl:variable name="fragment" as="xs:string"
			select="substring-after($elementDR/@additionalInfoURI,'#')" />
		<xsl:if test="doc-available($filename)">
			<h2>Additional Information</h2>
			<xsl:apply-templates select="doc($filename)//*[@id eq $fragment]/*"
				mode="docprosedescription" />
		</xsl:if>
		<!--<br />Long Sample: <xsl:value-of select="$filename"/>: <xsl:value-of select="doc-available($filename)"/> <br />
		Long Sample: <xsl:value-of select="resolve-uri($filename)"/>: <xsl:value-of select="doc-available(resolve-uri($filename))"/> -->
	</xsl:template>
	<xsl:template name="presentElements">
		<xsl:param name="elementsToPresent" as="element()*" />
		<xsl:for-each select="$elementsToPresent">
			<xsl:sort select="element/@name" />
			<xsl:variable name="e" as="element()" select="element" />
			<!-- Avoid duplicating elements with the same name and namespace -->
			<xsl:if
				test="not(preceding-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns])">
				<xsl:choose>
					<xsl:when
						test="following-sibling::define[element/@name eq $e/@name and element/@ns eq $e/@ns]">
						<li>
							<a href="{concat('Elements/_',@name,'.html')}">
								<xsl:value-of
									select="hks:addNamespacePrefix(element/@name,element/@ns)" />
								<xsl:text> *</xsl:text>
							</a>
						</li>
					</xsl:when>
					<xsl:otherwise>
						<li>
							<a href="{concat('Elements/',@name,'.html')}">
								<xsl:value-of
									select="hks:addNamespacePrefix(element/@name,element/@ns)" />
							</a>
						</li>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="createDuplicatedElementInfo">
		<xsl:variable name="defs" as="element()+"
			select="//define[element/@name eq current()/element/@name and element/@ns eq current()/element/@ns]" />

		<xsl:result-document href="{concat('Elements/_',@name,'.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<head>
					<title>Schema Documentation: <xsl:value-of select="$docTitle" /> - the
							<xsl:value-of select="element/@name" /> element</title>
					<link rel="stylesheet" type="text/css" href="../rng-doc.css" />
				</head>
				<!--<body style="margin-top:4em;margin-bottom:2em;">-->
				<body>
					<xsl:call-template name="createNavigationBox" />
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
							<xsl:variable name="parent.names" as="xs:string+">
								<xsl:for-each select="$ref.by.filtered">
									<xsl:sort select="@name" />
									<xsl:sequence
										select="hks:addNamespacePrefix(
										//define[@name eq current()/@name]/element/@name,
										//define[@name eq current()/@name]/element/@ns
										)"
									 />
								</xsl:for-each>
							</xsl:variable>
							<li>
								<a href="{concat('#',generate-id(element))}">
									<xsl:text>The </xsl:text>
									<span class="element">
										<xsl:value-of select="element/@name" />
									</span>
									<xsl:text> element as child of </xsl:text>
									<xsl:for-each select="distinct-values($parent.names)">
										<span class="element">
											<xsl:value-of select="." />
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
									<!--									<xsl:for-each select="$ref.by.filtered">
										<xsl:sort select="@name"/>
										<span class="element">
											<xsl:value-of
												select="hks:addNamespacePrefix(
												//define[@name eq current()/@name]/element/@name,
												//define[@name eq current()/@name]/element/@ns
												)"
											/>
										</span>
										<xsl:choose>
											<xsl:when test="position() eq last()"/>
											<xsl:when test="position() eq last()-1">
												<xsl:text> or </xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>, </xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>-->
								</a>
							</li>
						</xsl:for-each>
					</ul>

					<xsl:for-each select="$defs">
						<!-- Get the possible parents -->
						<xsl:variable name="ref.by" as="element()+"
							select="//define[some $e in descendant::ref satisfies $e/@name eq current()/@name]" />
						<xsl:variable name="ref.by.filtered" as="element()+"
							select="$ref.by[not(element/@name eq current()/element/@name and current()/element/@ns)]" />
						<xsl:variable name="parent.names" as="xs:string+">
							<xsl:for-each select="$ref.by.filtered">
								<xsl:sort select="@name" />
								<xsl:sequence
									select="hks:addNamespacePrefix(
									//define[@name eq current()/@name]/element/@name,
									//define[@name eq current()/@name]/element/@ns
									)"
								 />
							</xsl:for-each>
						</xsl:variable>
						<h1 id="{generate-id(element)}">
							<xsl:text>The </xsl:text>
							<span class="element">
								<xsl:value-of select="element/@name" />
							</span>
							<xsl:text> element as child of </xsl:text>
							<xsl:for-each select="distinct-values($parent.names)">
								<span class="element">
									<xsl:value-of select="." />
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
						</h1>
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
					<title>Schema Documentation: <xsl:value-of select="$docTitle" /> - the
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
			<xsl:if test="preceding-sibling::define[element/@name]">
				<a class="previous-element"
					href="{concat(preceding-sibling::define[element/@name][1]/@name,'.html')}">
					<xsl:text>Previous: </xsl:text>
					<xsl:value-of
						select="hks:addNamespacePrefix(preceding-sibling::define[element/@name][1]/element/@name,preceding-sibling::define[element/@name][1]/element/@ns)"
					 />
				</a>
			</xsl:if>
			<a class="toc-link" href="../index.html">Back to element toc</a>
			<xsl:if test="following-sibling::define[element/@name]">
				<a class="next-element"
					href="{concat(following-sibling::define[element/@name][1]/@name,'.html')}">
					<xsl:text>Next: </xsl:text>
					<xsl:value-of
						select="hks:addNamespacePrefix(following-sibling::define[element/@name][1]/element/@name,following-sibling::define[element/@name][1]/element/@ns)"
					 />
				</a>
			</xsl:if>
		</div>
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
				<th>Description</th>
			</tr>

			<xsl:for-each select="$a[not(ancestor::optional)]">
				<!--<xsl:sort select="@name"/>-->
				<xsl:sort
					select="concat(
					hks:namespace2Prefix(
					if (@ns eq '') then $defaultNamespace else @ns
					),
					':',
					@name
					)" />
				<xsl:call-template name="createAttributeInfo" />
			</xsl:for-each>
			<xsl:for-each select="$a[ancestor::optional]">
				<!--<xsl:sort select="@name"/>-->
				<xsl:sort
					select="concat(
					hks:namespace2Prefix(
					if (@ns eq '') then $defaultNamespace else @ns
					),
					':',
					@name
					)" />
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
				<!--<xsl:choose>
					<xsl:when test="ancestor::optional"> Optional </xsl:when>
					<xsl:otherwise> Required </xsl:otherwise>
				</xsl:choose>
				/-->
				<xsl:choose>
					<xsl:when test="not(ancestor::optional)">
						<!-- Well, if it's not optional, then it's required --> Required </xsl:when>
					<xsl:when
						test="count(ancestor::optional) = 2 and local-name(ancestor::*[2]) eq 'group'">
						<!-- This one is rather shaky, but
							if this attribute has 2 optional elements as ancestors
							and
							if this attribute has a group not too far up in the ancestor axis
							then we'll assume it is co-dependant on something
						-->
						Co-dependant on <xsl:for-each select="ancestor::group[1]/attribute">
							<code>
								<xsl:value-of select="hks:addNamespacePrefix(@name,@ns)" />
							</code>
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
					</xsl:when>
					<xsl:otherwise>
						<!-- We'll assume that everything else is optional --> Optional
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:if test="$docResource.available">
					<!--					<div>
						<xsl:value-of select="concat('e.name: ',$e.name)"/><br />
						<xsl:value-of select="concat('e.ns: ',$e.ns)"/><br />
						<xsl:value-of select="concat('attrib.name: ',$attrib.name)"/><br />
						<xsl:value-of select="concat('attrib.ns: ',$attrib.ns)"/>
					</div>-->
					<!-- Present some documentation prose -->
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
					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@descriptionInclude eq 'yes'">
									<xsl:call-template name="getDocProse">
										<xsl:with-param name="docURI" as="xs:string"
											select="$relevant.doc/@descriptionURI" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>More information about this attribute can be found at </xsl:text>
									<br />
									<a target="_blank" href="{$relevant.doc/@descriptionURI}">
										<xsl:value-of select="$relevant.doc/@descriptionURI" />
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
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="hks:elementIsAFeature(.)">
					<!-- State that this attribute belongs to a feature -->
					<xsl:if test="$docResource.available">
						<br />
					</xsl:if>
					<xsl:text>This attribute belongs to the feature &#171;</xsl:text>
					<xsl:value-of select="hks:featureNicenameFromNamespace(@ns)" />
					<xsl:text>&#187;</xsl:text>
				</xsl:if>
				<xsl:if test="$docResource.available or hks:elementIsAFeature(.)">
					<br />
				</xsl:if>
				<strong>Value:</strong>
				<xsl:apply-templates mode="acm" />

			</td>
		</tr>
		<!--		<xsl:if test="$docResource.available">
			<xsl:variable name="relevant.doc" as="element()*">
				<xsl:choose>
					<xsl:when
						test="$docResource.attributes//dr:attribute[
						@name eq $attrib.name 
						and @nsURI eq $attrib.ns
						and @contextLocalName eq $e.name
						and @contextNamespace eq $e.ns
						]">
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
						<xsl:sequence
							select="$docResource.attributes//dr:attribute[
							@name eq $attrib.name 
							and @nsURI eq $attrib.ns
							and not(@contextLocalName)
							]"
						/>
					</xsl:when>
					<xsl:otherwise>
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
				select="$docResource.content//dr:namespace[@nsURI eq $attrib.ns]/@defaultDocURL"/>
			<tr valign="top">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="ancestor::optional">
							<xsl:value-of select="'attribdoc-optional'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'attribdoc-required'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<td colspan="2"/>
				<td>
					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@descriptionInclude eq 'yes'">
									<xsl:call-template name="getDocProse">
										<xsl:with-param name="docURI" as="xs:string"
											select="$relevant.doc/@descriptionURI"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>More information about this attribute can be found at </xsl:text>
									<br/>
									<a target="_blank" href="{$relevant.doc/@descriptionURI}">
										<xsl:value-of select="$relevant.doc/@descriptionURI"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$default.doc.url">
									<xsl:text>Some general information about elements and attributes in this namespace may be found at</xsl:text>
									<br/>
									<a target="_blank" href="{$default.doc.url}">
										<xsl:value-of select="$default.doc.url"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>No further information about this attribute is
										available.</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</td>

			</tr>
		</xsl:if>-->
		<!--		<xsl:if test="hks:elementIsAFeature(.)">
			<tr valign="top">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="ancestor::optional">
							<xsl:value-of select="'attribdoc-optional'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'attribdoc-required'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<td colspan="2"/>
				<td>
					<xsl:text>This attribute belongs to the feature &#171;</xsl:text>
					<xsl:value-of select="hks:featureNicenameFromNamespace(@ns)"/>
					<xsl:text>&#187;</xsl:text>
				</td>
			</tr>
		</xsl:if>-->
	</xsl:template>

	<xsl:template name="presentContentModel">
		<xsl:variable name="cm" as="element()*"
			select="group/child::*[not(descendant-or-self::attribute)]" />
		<!--<xsl:variable name="cm" as="element()*" select="descendant::ref"/>-->
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
						<xsl:text> contain the following children: </xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
						</xsl:call-template>
						<xsl:text>. </xsl:text>
					</xsl:if>
					<xsl:if test="$c.optional">
						<xsl:text>It </xsl:text>
						<em>may</em>
						<xsl:text> contain the following children: </xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.optional" />
						</xsl:call-template>
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="($c.mandatory or $c.optional) and not($textAllowed)">
					<xsl:text>This element </xsl:text>
					<em>can not</em>
					<xsl:text> contain text. </xsl:text>
					<xsl:if test="$c.mandatory">
						<xsl:text>It </xsl:text>
						<em>must</em>
						<xsl:text> contain the following children: </xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.mandatory" />
						</xsl:call-template>
						<xsl:text>. </xsl:text>
					</xsl:if>
					<xsl:if test="$c.optional">
						<xsl:text>It </xsl:text>
						<em>may</em>
						<xsl:text> contain the following children: </xsl:text>
						<xsl:call-template name="listChildren">
							<xsl:with-param name="c" as="element()*" select="$c.optional" />
						</xsl:call-template>
						<xsl:text>. </xsl:text>
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


	<xsl:template name="listChildren">
		<xsl:param name="c" as="element()*" />
		<!-- Changed so that it will not list the same element more than once -->
		<!--		<xsl:for-each select="$c">
			<xsl:sort select="@name"/>
			<a class="element" href="{concat(@name,'.html')}">
			<xsl:value-of
			select="hks:addNamespacePrefix(
			//define[@name eq current()/@name]/element/@name,
			//define[@name eq current()/@name]/element/@ns
			)"
			/>
			</a>
			<xsl:choose>
			<xsl:when test="position() eq last()"/>
			<xsl:when test="position() eq last()-1">
			<xsl:text> and </xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:text>, </xsl:text>
			</xsl:otherwise>
			</xsl:choose>
			</xsl:for-each>-->
		<!--<xsl:for-each select="$c">
			<xsl:value-of select="local-name(.)"/>
			</xsl:for-each>-->
		<xsl:variable name="elements" as="element()*"
			select="for $n in distinct-values($c/@name) return $sRNGdefs[@name eq $n]/element" />
		<xsl:for-each select="$elements[@name]">
			<xsl:sort select="@name" />
			<xsl:variable name="n" as="xs:string" select="@name" />
			<a class="element" href="{concat(../@name,'.html')}">
				<xsl:value-of select="hks:addNamespacePrefix(@name,@ns)" />
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
		<xsl:if test="$elements[@name] and $elements[nsName]">
			<xsl:text> and </xsl:text>
		</xsl:if>
		<xsl:for-each select="$elements[nsName]">
			<xsl:text> all elements in the namespace </xsl:text>
			<code>
				<xsl:value-of select="nsName/@ns" />
			</code>
		</xsl:for-each>
		<xsl:if
			test="($elements[anyName] and $elements[@name]) or ($elements[anyName] and $elements[nsName])">
			<xsl:text>, and </xsl:text>
		</xsl:if>
		<xsl:for-each select="$elements[anyName]">
			<xsl:text> all elements </xsl:text>
			<xsl:if test="anyName/except//nsName">
				<xsl:text> except elements in the following namespace(s): </xsl:text>
				<xsl:for-each select="anyName/except//nsName">
					<xsl:choose>
						<xsl:when test="@ns eq ''">
							<xsl:text>default namespace</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<code>
								<xsl:value-of select="@ns" />
							</code>
						</xsl:otherwise>
					</xsl:choose>
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
			</xsl:if>
			<xsl:if test="anyName/except//nsName and anyName/except//name">, and </xsl:if>
			<xsl:if test="anyName/except//name">
				<xsl:text> except  </xsl:text>
				<xsl:for-each select="anyName/except//name">
					<code>
						<xsl:value-of
							select="hks:addNamespacePrefix(.,if (@ns eq '' or not(@ns)) then $defaultNamespace else @ns)"
						 />
					</code>
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
			</xsl:if>
		</xsl:for-each>
		<!--		<xsl:for-each select="distinct-values($c/@name)">
			<xsl:sort select="." />
			<xsl:variable name="n" as="xs:string" select="." />
			<a class="element" href="{concat($n,'.html')}">
				<xsl:value-of
					select="hks:addNamespacePrefix(
					$sRNGdefs[@name eq $n]/element/@name,
					$sRNGdefs[@name eq $n]/element/@ns
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
		</xsl:for-each>-->
	</xsl:template>


	<xsl:template name="getDocProse">
		<xsl:param name="docURI" as="xs:string" />
		<xsl:variable name="filename" as="xs:string" select="substring-before($docURI,'#')" />
		<!--<xsl:variable name="filename" as="xs:anyURI"
			select="resolve-uri(substring-before($docURI,'#'),base-uri($docResource.content))"/>-->
		<xsl:variable name="fragment" as="xs:string" select="substring-after($docURI,'#')" />
		<!--<xsl:copy-of select="doc($filename)//*[@id eq $fragment]/child::node()" />-->
		<xsl:apply-templates select="doc($filename)//*[@id eq $fragment]/child::node()"
			mode="docprose" />
	</xsl:template>

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


	<xsl:template name="createShortSampleTempFiles">
		<xsl:for-each select="distinct-values($docResource.content//@shortSampleURI)">
			<xsl:variable name="uri" as="xs:anyURI" select="resolve-uri(.)" />
			<xsl:variable name="filename.long" as="xs:string" select="substring-before($uri,'#')" />
			<xsl:variable name="fragment" as="xs:string" select="substring-after($uri,'#')" />
			<xsl:variable name="ss.content" as="element()"
				select="doc($filename.long)//*[@id eq $fragment]" />

			<xsl:if test="$ss.content">
				<xsl:variable name="filename.short" as="xs:string"
					select="replace($filename.long,'^(.+)/(.+?)$','$2')" />
				<!--<xsl:result-document
					href="{concat('file:/',$tempFolder,translate($filename.short,'.','_'),'_',$fragment,'.txt')}"
					format="shortSamples">-->
				<xsl:result-document
					href="{concat($tempFolder,translate($filename.short,'.','_'),'_',$fragment,'.txt')}"
					format="shortSamples">
					<xsl:copy-of select="$ss.content/child::node()" copy-namespaces="no" />
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
