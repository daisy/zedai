<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:nsl="http://www.daisy.org/ns/z3986/2008/namespacelist/"
	xmlns:dr="http://www.daisy.org/ns/z3986/2008/docResources/" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="hks xs x rng a nsl dr">

	<xsl:function name="hks:addNamespacePrefix" as="xs:string">
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="ns" as="xs:string"/>

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
						<xsl:value-of select="$name"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(hks:namespace2Prefix($ns),':',$name)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="hks:namespace2Prefix" as="xs:string">
		<xsl:param name="n" as="xs:string"/>

		<xsl:choose>
			<xsl:when test="doc($namespaceListURI)//nsl:namespace[. = $n]">
				<xsl:value-of select="doc($namespaceListURI)//nsl:namespace[. = $n]/@prefix"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'?'"/>
				<!--<xsl:message> Unknow namespace: <xsl:value-of select="$n" /></xsl:message>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="hks:profileContainsFeatures" as="xs:boolean">
		<xsl:param name="ns.list" as="xs:string*"/>
		<xsl:value-of
			select="some $ns in $ns.list satisfies doc($namespaceListURI)//nsl:namespace[. = $ns]/@feature eq 'yes'"
		/>
	</xsl:function>

	<xsl:function name="hks:profileContainsFeatureElements" as="xs:boolean">
		<xsl:param name="rng" as="element()"/>
		<xsl:variable name="someElementIsFeature" as="xs:boolean"
			select="some $e in $rng//element satisfies hks:elementIsAFeatureNew($e)"/>
		<!--		<xsl:message><xsl:value-of select="$rng"/></xsl:message>-->
		<xsl:value-of select="$someElementIsFeature"/>
	</xsl:function>

	<xsl:function name="hks:elementIsAFeatureNew" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<!--<xsl:message>element name: <xsl:value-of select="$element/@name"/></xsl:message>-->
		<xsl:variable name="element.namespace" as="xs:string"
			select="if ($element/@ns eq '') then $defaultNamespace else $element/@ns"/>
		<xsl:choose>
			<xsl:when test="hks:getDocResourceForElement($element)">
				<xsl:value-of
					select="if (hks:getDocResourceForElement($element)/@feature eq 'yes') then true() else false()"
				/>
			</xsl:when>
			<xsl:otherwise>
				<!-- There is no doc resource for this element, so we must look at the namespace element to see if this is a feature or not -->
				<xsl:variable name="namespaceElement" as="element()"
				select="$docResource.content//dr:namespace[@nsURI eq $element.namespace]"/>
				<xsl:value-of select="if ($namespaceElement/@feature eq 'yes') then true() else false()"/>
				<!--<xsl:value-of select="$namespaceElement/@feature eq 'yes'"/>-->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

	<xsl:function name="hks:featureNicenameFromElement" as="xs:string">
		<xsl:param name="element" as="element()"/>
		<xsl:variable name="element.namespace" as="xs:string"
			select="if ($element/@ns eq '') then $defaultNamespace else $element/@ns"/>
		<xsl:choose>
			<xsl:when test="hks:getDocResourceForElement($element)">
				<xsl:value-of
					select="hks:getDocResourceForElement($element)/@feature-nicename"
				/>
			</xsl:when>
			<xsl:otherwise>
				<!-- There is no doc resource for this element, so we must look at the namespace element to get the nice name -->
<!--				<xsl:variable name="namespaceElement" as="element()"
					select="$docResource.content//dr:namespace[@nsURI eq $element.namespace]/@feature-nicename"/>-->
				<xsl:value-of select="$docResource.content//dr:namespace[@nsURI eq $element.namespace]/@feature-nicename"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	



	<xsl:function name="hks:parentsMatchesDRFContext" as="xs:boolean">
		<xsl:param name="parents" as="xs:string*"/>
		<xsl:param name="context" as="xs:string?"/>
		<xsl:message>* Parents: <xsl:value-of select="string-join($parents,' | ')"/></xsl:message>
		<xsl:message>* context: <xsl:value-of select="$context"/></xsl:message>
		<xsl:value-of select="true()"/>
	</xsl:function>

	<xsl:function name="hks:getDocResourceForElement" as="element()?">
		<xsl:param name="e" as="element()"/>
		<xsl:variable name="e.ns" as="xs:string"
			select="if ($e/@ns eq '') then $defaultNamespace else $e/@ns"/>
		<xsl:variable name="e.name" as="xs:string" select="$e/@name"/>
		<xsl:variable name="e.parentQnames" as="xs:string*"
			select="hks:QNamesForPossibleElementParents($e)"/>
		<xsl:variable name="dr.relevant" as="element()*"
			select="$docResource.content//dr:element[@name eq $e.name and @nsURI eq $e.ns]"/>
		<xsl:choose>
			<xsl:when test="count($dr.relevant) = 0">
				<!-- Don't return anything -->
			</xsl:when>
			<xsl:otherwise>
				<!-- There is more than one element in the DRF with mathcing name and namespace, 
					so we must find the one with a matching context:
					HOw do we do that?
					Anta at elementet har parent A, B og C.
					@context="A" er OK
					@context="A B" er OK
					@context="A B D" er ikke OK
					Altså alle elementer i @context må være lik et av parent-elementen
					HVis ikke match, ta den uten @context
				-->
				<xsl:variable name="dr.withMatchingContext" as="element()*">
					<xsl:for-each select="$dr.relevant[@context]">
						<xsl:variable name="context.qnamed" as="xs:string+"
							select="for $c in tokenize(normalize-space(@context),' ') return
							if (contains($c,':')) then $c else concat(hks:namespace2Prefix($defaultNamespace),':',$c)"/>
						<xsl:if
							test="every $c in $context.qnamed satisfies some $p in $e.parentQnames satisfies $p eq $c">
							<xsl:sequence select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$dr.withMatchingContext">
						<xsl:sequence select="$dr.withMatchingContext[1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$dr.relevant[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="hks:QNamesForPossibleElementParents" as="xs:string*">
		<!-- For element A in the schema, return zero or more qualified names for elements which references A, 
			that has A as a possible child -->
		<xsl:param name="e" as="element()"/>
		<xsl:variable name="parents" as="element()*" select="hks:possibleParentsForElement($e)"/>
		<xsl:for-each select="$parents">
			<xsl:value-of
				select="concat(
				hks:namespace2Prefix(
				if (@ns eq '') then $defaultNamespace else @ns
				),
				':',
				@name
				)"
			/>
		</xsl:for-each>
	</xsl:function>
	<xsl:function name="hks:namesForPossibleElementParents" as="xs:string*">
		<!-- For element A in the schema, return zero or more non-qualified names for elements which references A, 
			that has A as a possible child -->
		<xsl:param name="e" as="element()"/>
		<xsl:variable name="parents" as="element()*" select="hks:possibleParentsForElement($e)"/>
		<xsl:value-of select="$parents/@name"/>
	</xsl:function>

	<xsl:function name="hks:possibleParentsForElement" as="element()*">
		<!-- For a element A in the schema, returns zero or more element which references A, 
			that has A as a possible child -->
		<xsl:param name="e" as="element()"/>
		<xsl:variable name="e.define-name" as="xs:string">
			<xsl:for-each select="$e">
				<xsl:value-of select="../@name"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="rng.root" as="element()">
			<xsl:for-each select="$e">
				<xsl:sequence select="ancestor::*[position() eq last()]"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence
			select="$rng.root//element[some $n in descendant::ref/@name satisfies $n eq $e.define-name]"
		/>
	</xsl:function>

	<!-- Obsolete functions (start) -->
	<xsl:function name="hks:elementIsAFeature" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		
		<xsl:variable name="ns" as="xs:string"
			select="if ($element/@ns eq '') then $defaultNamespace else $element/@ns"/>
		<!--				<xsl:message>+ <xsl:value-of select="$element/@name"/>: ns: <xsl:value-of select="$ns"/></xsl:message>-->
		<xsl:value-of select="doc($namespaceListURI)//nsl:namespace[. = $ns]/@feature eq 'yes'"/>
	</xsl:function>

	<xsl:function name="hks:featureNicenameFromNamespace" as="xs:string">
		<xsl:param name="ns" as="xs:string"/>
		<xsl:value-of select="doc($namespaceListURI)//nsl:namespace[. = $ns]/@feature-nicename"/>
	</xsl:function>
	
	<!-- Obsolete functions (end) -->
</xsl:stylesheet>
