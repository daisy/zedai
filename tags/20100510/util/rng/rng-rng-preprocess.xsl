<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:rng="http://relaxng.org/ns/structure/1.0"	
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns="http://relaxng.org/ns/structure/1.0"
	xmlns:xsdp="http://www.daisy.org/ns/rng-preprocess/xsd"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:z="http://www.daisy.org/ns/z3986/annotations/#"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:db="http://docbook.org/ns/docbook"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" 
	exclude-result-prefixes="rng xsdp">

	<!-- Preprocessing of RNG files. Source is an RNG, result is an RNG
		This XSLT does things like autogenerating some of the RDF doc -->

	<!-- TODO dereference structure-vocab URIs -->

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- a comma separated list of the paths of all .rng files in current fileset  -->
	<!-- note that the path of the current transform source also appears in ${schema-list} -->
	<xsl:param name="schema-list" required="yes"/>
	
	<xsl:variable name="schema-list-tokenized" select="tokenize($schema-list, ',')"/>
	<xsl:variable name="current-src-schema" select="document-uri(.)"/>
	<xsl:variable name="current-src-schema-filename" as="xs:string"
		select="replace($current-src-schema,'^(.+)/(.+?)$','$2')"/>
	<xsl:variable name="current-src-schema-id" as="xs:string"
		select="concat(replace(replace($current-src-schema-filename,'.rng',''),'z3986-','z3986.'),'.module')"/>
	
	<!-- shared dcterms descriptions -->
	<xsl:variable name="common-dcterms-descs" select="document('../../src/doc/metadescs/ai-common-metadescs.xml')/db:article"/>
	
	<xsl:template match="rng:grammar">
		<grammar>
			<xsl:copy-of select="@*" />
			<!-- add a predictably generated ID to the root element -->
			<xsl:attribute name="xml:id" select="$current-src-schema-id"/>
			<xsl:apply-templates />
		</grammar>	
	</xsl:template>	
		
	<xsl:template match="rng:grammar/rdf:RDF/rdf:Description">
		<!-- match the module-level RDF only -->
		<rdf:Description>
			<xsl:copy-of select="@*" />
			<xsl:attribute name="rdf:about" select="concat('#',$current-src-schema-id)"/>
			<xsl:call-template name="add-xml-lang" />
			<xsl:apply-templates select="./*" />
			
		<!-- fill in <dcterms:requiredBy> in the top-level RDF element by looking at 
			the <dcterms:requires> field in the top-level RDF element of all other modules -->
		<xsl:for-each select="$schema-list-tokenized">			
			<xsl:if test="not(ends-with(current(),$current-src-schema-filename))"> <!-- dont check self -->
				<xsl:variable name="other-doc" as="node()" select="doc(replace(current(),'\\','/'))"/>
				<xsl:for-each select="$other-doc/rng:grammar/rdf:RDF/rdf:Description/dcterms:requires">					
					<xsl:if test="contains(current()/@rdf:resource,$current-src-schema-filename)">
						<!-- current otherdoc refs this as required -->							
						<dcterms:isRequiredBy rdf:resource="{replace(document-uri($other-doc),'^(.+)/(.+?)$','$2')}" />
					</xsl:if>
				</xsl:for-each>
			</xsl:if>	
		</xsl:for-each>
		</rdf:Description>
	</xsl:template>

	<xsl:template match="//rng:*[rdf:RDF and not(local-name(.) eq 'grammar')]">
		<!-- match all nodes with RDF child except the module-level one -->
		<!-- the immediate ancestor of the rdf:RDF (current context node) is what is being defined, so needs an ID -->
		<xsl:variable name="fragment-id" select="ancestor-or-self::rng:define[1 and @name]/@name"/>
		<!-- <xsl:message>GENERATED ID IS <xsl:value-of select="$fragment-id"></xsl:value-of></xsl:message> -->
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*" />
			<xsl:attribute name="xml:id" select="$fragment-id" />
			<xsl:apply-templates select="./*" mode="fragment-rdf" />
		</xsl:element>
	</xsl:template>	
	
	<xsl:template match="rdf:Description" mode="fragment-rdf">		
		<rdf:Description>			
			<xsl:copy-of select="@*" />
			<xsl:call-template name="add-xml-lang" />
			<!-- add a URI to the fragment of the ancestor being defined -->
			<xsl:attribute name="rdf:about" select="concat('#',ancestor::rng:define[1 and @name]/@name)" />
			<xsl:apply-templates select="./*" mode="fragment-rdf"/>
		</rdf:Description>
	</xsl:template>	
	
	<xsl:template match="dcterms:isRequiredBy[@rdf:resource='']" mode="fragment-rdf">
		<!-- normalize all these to using the period -->
		<dcterms:isRequiredBy rdf:resource="."/>
	</xsl:template>
		
	<xsl:template match="dcterms:description[@z:inherit]" mode="fragment-rdf">
		<xsl:variable name="inheritID" select="@z:inherit"/>
		<xsl:copy>
			<xsl:apply-templates select="$common-dcterms-descs/db:section[@about=$inheritID]/db:para[@role='desc']/node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="z:info[@z:inherit]" mode="fragment-rdf">
		<xsl:variable name="inheritID" select="@z:inherit"/>
		<xsl:for-each select="$common-dcterms-descs/db:section[@about=$inheritID]/db:para[@role='info']">
			<xsl:element name="z:info">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="add-xml-lang">
		<xsl:if test="not(./@xml:lang)">
			<xsl:attribute name="xml:lang">en</xsl:attribute>
		</xsl:if>
	</xsl:template>	
		
	<xsl:template match="*" mode="fragment-rdf">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="fragment-rdf"/>
		</xsl:copy>
	</xsl:template>	
		
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
