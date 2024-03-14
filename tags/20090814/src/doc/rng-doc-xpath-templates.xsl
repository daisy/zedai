<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xmlns:dr="http://www.daisy.org/ns/z3986/2008/docResources/" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a nsl dr">

	<!-- Documentation Resource Handling -->
	<xsl:template match="*" mode="dr">
		<xsl:copy>
			<xsl:copy-of select="@*, ancestor-or-self::dr:namespace/@nsURI" />
			<xsl:if test="ancestor::dr:namespace/@feature eq 'yes'">
				<xsl:copy-of
					select="ancestor::dr:namespace/@feature, ancestor::dr:namespace/@featureNicename"
				 />
			</xsl:if>
			<xsl:apply-templates mode="dr" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="dr:include" mode="dr">
		<!--		<xsl:message>* File referenced: <xsl:value-of select="@subDrURI"/></xsl:message>
			<xsl:message> * Base URI: <xsl:value-of select="base-uri(.)"/></xsl:message>
			<xsl:message> * Doc URI: <xsl:value-of select="document-uri(/)"/></xsl:message>
			<xsl:message> * Static base URI: <xsl:value-of select="static-base-uri()"/></xsl:message>
			<xsl:message> * Resolves to <xsl:value-of select="resolve-uri(@subDrURI,base-uri(.))"
			/></xsl:message>
			<xsl:message> * Resolves to (alt) <xsl:value-of select="resolve-uri(@subDrURI,document-uri(/))"
			/></xsl:message>-->
		<xsl:apply-templates select="doc(@subDrURI)//dr:docResources/dr:*" mode="dr" />
	</xsl:template>
	<xsl:template match="dr:docResources">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:for-each-group select="dr:namespace" group-by="@nsURI">

				<xsl:copy>
					<xsl:copy-of select="@*" />
					<xsl:apply-templates select="current-group()/dr:*" mode="dr" />
				</xsl:copy>
			</xsl:for-each-group>> </xsl:copy>
	</xsl:template>


	<xsl:template match="*" mode="attlist">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="attlist" />
		</xsl:copy>
	</xsl:template>
	<xsl:template
		match="*[count(child::*) gt 0][every $e in child::* satisfies local-name($e) eq 'ref']"
		mode="attlist">
		<xsl:comment>removed: <xsl:value-of select="local-name()" /></xsl:comment>
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
		<xsl:variable name="attlistFilename" as="xs:string" select="concat('_ats_',../@name,'.xml')" />
		<xsl:variable name="attribs" as="element()">
			<attlist element-name="{@name}" xmlns="http://relaxng.org/ns/structure/1.0">
				<group xmlns="http://relaxng.org/ns/structure/1.0">
					<xsl:apply-templates select="group/*" mode="attlist" />
				</group>
			</attlist>
		</xsl:variable>
		<xsl:variable name="dr" as="element()?" select="hks:getDRForElement(.)" />
		<!--<xsl:variable name="ei2" as="element()">
			<div>
				<div class="element-coreinfo">
					<xsl:call-template name="presentElementDescription">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						 />
					</xsl:call-template>
					<xsl:call-template name="presentElementShortSample">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						 />
					</xsl:call-template>
					<h2>Possible children</h2>
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
					<h2>Namespace</h2>
					<p>
						<span class="namespace">
							<xsl:value-of select="@ns" />
						</span>
					</p>
					<p>
						<xsl:choose>
							<xsl:when test="hks:elementIsAFeatureNew(.)">
								<xsl:text>This element belongs to the feature &#171;</xsl:text>
								<xsl:value-of select="hks:featureNicenameFromElement(.)" />
								<xsl:text>&#187;</xsl:text>
							</xsl:when>
							<xsl:otherwise>This element belongs to the core grammar.</xsl:otherwise>
						</xsl:choose>
					</p>
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

					<!-\-<xsl:call-template name="presentElementLongSample">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						/>
					</xsl:call-template>-\->
				</div>
				<xsl:if test="$docResource.available">
					<!-\- Element name -\->
					<xsl:variable name="e.name" as="xs:string" select="@name" />
					<!-\- ... and namespace -\->
					<xsl:variable name="e.ns" as="xs:string"
						select="if (@ns eq '') then $defaultNamespace else @ns" />
					<xsl:variable name="pattern.name" as="xs:string" select="../@name" />
					<xsl:variable name="ref.by" as="element()*"
						select="//define[some $e in descendant::ref satisfies $e/@name eq $pattern.name]" />
					<xsl:variable name="e.parents" as="xs:string*">
						<xsl:for-each select="$ref.by">
							<xsl:sequence
								select="concat(
								hks:namespace2Prefix(if (element/@ns eq '' or not(element/@ns)) then $defaultNamespace else element/@ns),
								':',
								if (not(element/@name)) then '*' else element/@name)" />
							<!-\-<xsl:sequence
								select="concat(
								hks:namespace2Prefix(if (element/@ns eq '') then $defaultNamespace else element/@ns),
								':',
								element/@name)"
								/>-\->
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="relevant.doc" as="element()*">
						<xsl:choose>
							<xsl:when
								test="count($e.parents) eq 1 and
								$docResource.elements//dr:element[
								@name eq $e.name 
								and @nsURI eq $e.ns
								and @context eq $e.parents
								]">
								<!-\- If possible, pick the element element with the correct name, namespace and context -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @nsURI eq $e.ns
									and @context eq $e.parents
									]"
								 />
							</xsl:when>
							<xsl:when
								test="count($e.parents) eq 1 and
								$docResource.elements//dr:element[
								@name eq $e.name 
								and @context eq $e.parents
								]">
								<!-\- If above not found, try to pick the element element with the correct name and context -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @context eq $e.parents
									]"
								 />
							</xsl:when>
							<xsl:otherwise>
								<!-\- As a last resort, try to pick the element element with the correct name and namespace (and with no context) -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @nsURI eq $e.ns
									and not(@context)
									]"
								 />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-\-<xsl:variable name="relevant.doc" as="element()?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/dr:element[@name eq $e.name]"/>-\->
					<xsl:variable name="default.doc.url" as="xs:string?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/@defaultDocURL" />

					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@descriptionInclude eq 'yes'">
									<div class="element-docprose">
										<xsl:call-template name="getDocProse">
											<xsl:with-param name="docURI" as="xs:string"
												select="$relevant.doc/@descriptionURI" />
										</xsl:call-template>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<div> More information about this element can be found at <br />
										<a target="_blank" href="{$relevant.doc/@descriptionURI}">
											<xsl:value-of select="$relevant.doc/@descriptionURI" />
										</a>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$default.doc.url">
									<!-\-<xsl:message>No specific documentation for <xsl:value-of select="hks:addNamespacePrefix(@name,@ns)"/> </xsl:message>-\->
									<div> Some general information about elements and attributes in
										this namespace may be found at <br />
										<a target="_blank" href="{$default.doc.url}">
											<xsl:value-of select="$default.doc.url" />
										</a>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<!-\-<xsl:message>No documentation resources for <xsl:value-of select="hks:addNamespacePrefix(@name,@ns)"/> </xsl:message>-\->
									<div> No further information about this element is available.
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>
		</xsl:variable>-->
		<!--		<div class="elementInformation">
			<div class="element-toc-container">
				<strong>On this page:</strong>
				<ul class="element-toc">

					<xsl:for-each select="$ei2//*[matches(local-name(),'^h[1-6]$')]">
						<li class="{local-name()}">
							<a href="{concat('#',$el.name,'-',generate-id())}">
								<xsl:value-of select="." />
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</div>
			<xsl:apply-templates select="$ei2/*:div" mode="ei">
				<xsl:with-param name="elementName" as="xs:string" select="@name" tunnel="yes" />
			</xsl:apply-templates>
		</div>
		<hr />
-->
		<xsl:variable name="elementInformation" as="element()">
			<div>
				<div class="element-coreinfo">
					<xsl:call-template name="presentElementDescription">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						 />
					</xsl:call-template>
					<xsl:call-template name="presentElementShortSample">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						 />
					</xsl:call-template>
					<h2>Possible children</h2>
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
					<h2>Namespace</h2>
					<p>
						<span class="namespace">
							<xsl:value-of select="@ns" />
						</span>
					</p>
					<p>
						<xsl:choose>
							<xsl:when test="hks:elementIsAFeatureNew(.)">
								<xsl:text>This element belongs to the feature &#171;</xsl:text>
								<xsl:value-of select="hks:featureNicenameFromElement(.)" />
								<xsl:text>&#187;</xsl:text>
							</xsl:when>
							<xsl:otherwise>This element belongs to the core grammar.</xsl:otherwise>
						</xsl:choose>
					</p>
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

					<xsl:call-template name="presentElementAdditionalInfo">
						<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
						 />
					</xsl:call-template>
				</div>
				<!--				<xsl:call-template name="presentElementAdditionalInfo">
					<xsl:with-param name="elementDR" as="element()?" select="$dr" tunnel="yes"
					/>
				</xsl:call-template>-->
				<!--<xsl:if test="$docResource.available">
					<!-\- Element name -\->
					<xsl:variable name="e.name" as="xs:string" select="@name" />
					<!-\- ... and namespace -\->
					<xsl:variable name="e.ns" as="xs:string"
						select="if (@ns eq '') then $defaultNamespace else @ns" />
					<xsl:variable name="pattern.name" as="xs:string" select="../@name" />
					<xsl:variable name="ref.by" as="element()*"
						select="//define[some $e in descendant::ref satisfies $e/@name eq $pattern.name]" />
					<xsl:variable name="e.parents" as="xs:string*">
						<xsl:for-each select="$ref.by">
							<xsl:sequence
								select="concat(
								hks:namespace2Prefix(if (element/@ns eq '' or not(element/@ns)) then $defaultNamespace else element/@ns),
								':',
								if (not(element/@name)) then '*' else element/@name)" />
							<!-\-<xsl:sequence
								select="concat(
								hks:namespace2Prefix(if (element/@ns eq '') then $defaultNamespace else element/@ns),
								':',
								element/@name)"
								/>-\->
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="relevant.doc" as="element()*">
						<xsl:choose>
							<xsl:when
								test="count($e.parents) eq 1 and
								$docResource.elements//dr:element[
								@name eq $e.name 
								and @nsURI eq $e.ns
								and @context eq $e.parents
								]">
								<!-\- If possible, pick the element element with the correct name, namespace and context -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @nsURI eq $e.ns
									and @context eq $e.parents
									]"
								 />
							</xsl:when>
							<xsl:when
								test="count($e.parents) eq 1 and
								$docResource.elements//dr:element[
								@name eq $e.name 
								and @context eq $e.parents
								]">
								<!-\- If above not found, try to pick the element element with the correct name and context -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @context eq $e.parents
									]"
								 />
							</xsl:when>
							<xsl:otherwise>
								<!-\- As a last resort, try to pick the element element with the correct name and namespace (and with no context) -\->
								<xsl:sequence
									select="$docResource.elements//dr:element[
									@name eq $e.name 
									and @nsURI eq $e.ns
									and not(@context)
									]"
								 />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-\-<xsl:variable name="relevant.doc" as="element()?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/dr:element[@name eq $e.name]"/>-\->
					<xsl:variable name="default.doc.url" as="xs:string?"
						select="$docResource.content//dr:namespace[@nsURI eq $e.ns]/@defaultDocURL" />

					<xsl:choose>
						<xsl:when test="$relevant.doc">
							<xsl:choose>
								<xsl:when test="$relevant.doc/@descriptionInclude eq 'yes'">
									<div class="element-docprose">
										<xsl:call-template name="getDocProse">
											<xsl:with-param name="docURI" as="xs:string"
												select="$relevant.doc/@descriptionURI" />
										</xsl:call-template>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<div> More information about this element can be found at <br />
										<a target="_blank" href="{$relevant.doc/@descriptionURI}">
											<xsl:value-of select="$relevant.doc/@descriptionURI" />
										</a>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$default.doc.url">
									<!-\-<xsl:message>No specific documentation for <xsl:value-of select="hks:addNamespacePrefix(@name,@ns)"/> </xsl:message>-\->
									<div> Some general information about elements and attributes in
										this namespace may be found at <br />
										<a target="_blank" href="{$default.doc.url}">
											<xsl:value-of select="$default.doc.url" />
										</a>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<!-\-<xsl:message>No documentation resources for <xsl:value-of select="hks:addNamespacePrefix(@name,@ns)"/> </xsl:message>-\->
									<div> No further information about this element is available.
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>-->
			</div>
		</xsl:variable>

		<div class="elementInformation">
			<div class="element-toc-container">
				<strong>On this page:</strong>
				<ul class="element-toc">

					<xsl:for-each select="$elementInformation//*[matches(local-name(),'^h[1-6]$')]">
						<li class="{local-name()}">
							<a href="{concat('#',$el.name,'-',generate-id())}">
								<xsl:value-of select="." />
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</div>
			<xsl:apply-templates select="$elementInformation/*:div" mode="ei">
				<xsl:with-param name="elementName" as="xs:string" select="@name" tunnel="yes" />
			</xsl:apply-templates>
		</div>

		<!-- Create the element specific file with information about attributes 
		<xsl:if test="descendant::attribute">
			<xsl:result-document href="{concat('_attribs_',ancestor::define[1]/@name,'.html')}">
				<html xml:lang="en">
					<head>
						<title>Attributes for the <xsl:value-of select="@name"/>-element</title>
					</head>
					<body>
						<xsl:for-each select="descendant::attribute">
							<div id="{generate-id()}">
								<p>The <code><xsl:value-of select="@name"/></code>-attribute:</p>
								<xsl:apply-templates mode="ccm" />
							</div>
						</xsl:for-each>
					</body>
				</html>
			</xsl:result-document>
			</xsl:if>-->
	</xsl:template>

	<!--<xsl:template match="*" mode="altacm" priority="-5">
		<div class="rng">
			<span class="rng-x">
				<xsl:value-of select="local-name()" />
			</span>
			<div class="rng-content">
				<xsl:apply-templates mode="altacm" />
			</div>
		</div>
	</xsl:template>-->

	<!--<xsl:template match="choice" mode="altacm">
		<div class="rng">
			<span class="rng"> One of: </span>
			<div class="rng-content">
				<xsl:apply-templates mode="altacm" />
			</div>
		</div>
	</xsl:template>-->

	<!--	<xsl:template match="attribute" mode="altacm">
		<div class="rng">
			<span class="rng"> the <strong>
					<xsl:value-of select="@name" />
				</strong>-attribute, with value </span>
			<div class="rng-content">
				<xsl:apply-templates mode="altacm" />
			</div>
		</div>
	</xsl:template>-->

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

	<xsl:template match="*" mode="docprose">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="docprose" />
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[@class eq 'description']" mode="docprose" />
	<!-- Don't copy the description information -->

	<xsl:template match="*" mode="docprosedescription">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="docprosedescription" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" mode="shortsample">
		<xsl:choose>
			<xsl:when test="child::element() or text()">
				<xsl:text>&lt;</xsl:text>
				<xsl:value-of select="name()" />
				<xsl:for-each select="@*">
					<xsl:text> </xsl:text>
					<xsl:value-of select="name(.)" />
					<xsl:text>=&quot;</xsl:text>
					<xsl:value-of select="." />
					<xsl:text>&quot;</xsl:text>
				</xsl:for-each>
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="shortsample" />
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()" />
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>	<!-- Empty element -->
				<xsl:text>&lt;</xsl:text>
				<xsl:value-of select="name()" />
				<xsl:for-each select="@*">
					<xsl:text> </xsl:text>
					<xsl:value-of select="name(.)" />
					<xsl:text>=&quot;</xsl:text>
					<xsl:value-of select="." />
					<xsl:text>&quot;</xsl:text>
				</xsl:for-each>
				<xsl:text> /&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="attribute/data" mode="acm">
		<xsl:text>Some value of type </xsl:text>
		<code>
			<xsl:value-of select="@type" />
		</code>
		<!--		<span class="rng-datatype">
			<xsl:value-of select="@type" />
		</span>-->
		<xsl:if test="param">
			<xsl:text> satisfying </xsl:text>
		</xsl:if>
		<xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="attribute/text" mode="acm">
		<xsl:text>Any string </xsl:text>
		<xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="data" mode="acm">
		<xsl:text>value(s) of type </xsl:text>
		<code>
			<xsl:value-of select="@type" />
		</code>
		<!--<span class="rng-datatype">
			<xsl:value-of select="@type" />
		</span>-->
		<xsl:if test="param">
			<xsl:text> satisfying </xsl:text>
		</xsl:if>
		<xsl:apply-templates mode="acm" />
	</xsl:template>


	<xsl:template match="list" mode="acm">
		<xsl:text>A white space separated list of </xsl:text>
		<xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="oneOrMore" mode="acm">
		<xsl:text> one or more </xsl:text>
		<xsl:apply-templates mode="acm" />
	</xsl:template>


	<xsl:template match="param[@name eq 'pattern']" mode="acm">
		<div class="indent">
			<xsl:text>  &#8226; the pattern </xsl:text>
			<xsl:text>"</xsl:text>
			<code>
				<xsl:apply-templates mode="acm" />
			</code>
			<!--<span class="rng-pattern">
				<xsl:apply-templates mode="acm" />
			</span>-->
			<xsl:text>"</xsl:text>
		</div>
	</xsl:template>

	<xsl:template match="param[@name eq 'minLength']" mode="acm">
		<div class="indent">
			<xsl:text> &#8226; a minimum length of </xsl:text>
			<xsl:apply-templates mode="acm" />
		</div>
	</xsl:template>

	<xsl:template match="choice" mode="acm">
		<!--<span class="rng">One of:</span>-->
		<p>One of</p>
		<xsl:apply-templates mode="acm" />
	</xsl:template>

	<xsl:template match="choice[value]" mode="acm">
		<!-- Store all the value elements for later processing -->
		<xsl:variable name="value" as="element()+" select="value" />
		<p>One of</p>
		<!-- Process all children except the value elems -->
		<xsl:apply-templates select="*[local-name(.) ne 'value']" mode="acm" />
		<!-- Process (and sort) the value elems -->
		<xsl:apply-templates select="$value" mode="acm">
			<xsl:sort select="." />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="choice/data | choice/value | choice/list" mode="acm">
		<div class="indent">
			<xsl:text> &#8226; </xsl:text>
			<xsl:next-match />
		</div>
	</xsl:template>

	<xsl:template match="value" mode="acm">
		<code>
			<xsl:apply-templates mode="acm" />
		</code>
		<!--		<span class="{concat('rng-value-',@type)}">
			<xsl:apply-templates mode="acm" />
		</span>-->
		<!--		<span class="{concat('rng-value-',@type)}">
			<xsl:apply-templates mode="acm"/>
			</span>
			<xsl:choose>
			<xsl:when test="not(following-sibling::value)">.</xsl:when>
			<xsl:when test="count(following-sibling::value) = 1"> or </xsl:when>
			<xsl:otherwise>
			<xsl:text>, </xsl:text>
			</xsl:otherwise>
			</xsl:choose>-->
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

</xsl:stylesheet>
