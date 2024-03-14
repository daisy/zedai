<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
	xmlns="http://relaxng.org/ns/structure/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:rng="http://relaxng.org/ns/structure/1.0"			
	xmlns:xsdp="http://www.daisy.org/ns/rng-preprocess/xsd"	
	xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"	
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:db="http://docbook.org/ns/docbook"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:z="http://www.daisy.org/ns/z3998/annotations/#"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" 
	xmlns:ssml="http://www.w3.org/2001/10/synthesis"
	exclude-result-prefixes="rng xsdp">
	
	<!-- Preprocessing of RNG files. Source is an RNG, result is an RNG -->
		
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- a comma separated list of the paths of all .rng files in current fileset  -->
	<!-- note that the path of the current transform source also appears in ${schema-list} -->
	<xsl:param name="schema-list" required="yes"/>
	
	<xsl:variable name="schema-list-tokenized" select="tokenize($schema-list, ',')"/>
	<xsl:variable name="current-src-schema" select="document-uri(.)"/>
	<xsl:variable name="current-src-schema-filename" as="xs:string"
		select="replace($current-src-schema,'^(.+)/(.+?)$','$2')"/>
	<xsl:variable name="current-src-schema-id" as="xs:string"
		select="concat(replace(replace($current-src-schema-filename,'.rng',''),'z3998-','z3998.'),'.module')"/>
	
	<!-- shared documentation paras -->
	<xsl:variable name="common-dcterms-descs" select="document('../../src/doc/metadescs/ai-common-metadescs.xml')/db:article"/>
	
	<xsl:template match="rng:grammar">
		<grammar>
			<xsl:copy-of select="@*" />
			<!-- add a predictably generated ID to the root element -->
			<xsl:attribute name="xml:id" select="$current-src-schema-id"/>
			<xsl:apply-templates />
		</grammar>	
	</xsl:template>	
		
	<xsl:template match="rng:grammar/db:info">
		<!-- match the module-level db:info  -->
		<xsl:element name="info" namespace="http://docbook.org/ns/docbook">
			<xsl:copy-of select="@*" />			
			<xsl:call-template name="add-xml-lang" />
			<xsl:apply-templates />						
		</xsl:element>
	</xsl:template>

	<xsl:template match="rng:grammar/db:info/db:annotation">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates />
			
			<!-- fill in def-dependants list in the top-level db:info element by looking at 
				the def-dependencies list in the top-level db:info element of all other modules -->
			
			<xsl:variable name="names">
				<!-- build a variable which is a comma separated list of the modules that declares a dep on current -->
				<xsl:for-each select="$schema-list-tokenized">			
					<xsl:if test="not(ends-with(current(),$current-src-schema-filename))"> <!-- dont check self -->
						<xsl:variable name="other-doc" as="node()" select="doc(replace(current(),'\\','/'))"/>								
						<xsl:for-each select="$other-doc/rng:grammar/db:info/db:annotation/db:simplelist[@role='def-dependencies']/db:member">					
							<xsl:if test="contains(current()/@xlink:href,$current-src-schema-filename)">
								<!-- current otherdoc refs this as required -->								
								<xsl:value-of select="replace(document-uri($other-doc),'^(.+)/(.+?)$','$2')"/>
								<xsl:text>,</xsl:text>
							</xsl:if>
						</xsl:for-each>					
					</xsl:if>	
				</xsl:for-each>
			</xsl:variable>	
			
			<xsl:if test="string-length($names)>0">
				<xsl:element name="simplelist" namespace="http://docbook.org/ns/docbook">
					<xsl:attribute name="role">def-dependants</xsl:attribute>
					<xsl:for-each select="tokenize($names,',')">	
						<xsl:if test="string-length(normalize-space(current()))>0">
							<xsl:element name="member" namespace="http://docbook.org/ns/docbook">
								<xsl:attribute name="xlink:href" select="current()" />
							</xsl:element>	
						</xsl:if>	
					</xsl:for-each>
				</xsl:element>
			</xsl:if>	
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="//rng:*[db:annotation and not(local-name(.) eq 'grammar')]">
		<!-- match all elements with db:annotation child -->
		<!-- the immediate ancestor of the db:annotation (current context node) is what is being defined, so needs an ID -->
		<xsl:variable name="fragment-id" select="ancestor-or-self::rng:define[1 and @name]/@name"/>
		<!-- <xsl:message>GENERATED ID IS <xsl:value-of select="$fragment-id"></xsl:value-of></xsl:message> -->
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*" />
			<xsl:attribute name="xml:id" select="$fragment-id" />
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>	
			
	<!-- <para role="desc-main" xlink:role="inherit-common" xlink:href="z3998.object"/> -->		
	<xsl:template match="db:para[@xlink:role='inherit-common' and @role='desc-main']">
		<xsl:variable name="inheritID" select="@xlink:href"/>
		<xsl:copy-of select="$common-dcterms-descs/db:section[@about=$inheritID]/db:para[@role='desc-main']" />
	</xsl:template>

	<!-- <para role="desc-sub" xlink:role="inherit-common" xlink:href="z3998.object"/> -->		
	<xsl:template match="db:para[@xlink:role='inherit-common' and @role='desc-sub']">
		<xsl:variable name="inheritID" select="@xlink:href"/>
		<xsl:copy-of select="$common-dcterms-descs/db:section[@about=$inheritID]/db:para[@role='desc-sub']" />
	</xsl:template>
		
	<xsl:template name="add-xml-lang">
		<xsl:if test="not(./@xml:lang)">
			<xsl:attribute name="xml:lang">en</xsl:attribute>
		</xsl:if>
	</xsl:template>	
					
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
