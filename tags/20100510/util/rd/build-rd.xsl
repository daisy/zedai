<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:d="http://www.daisy.org/z3986#" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:rd="http://www.daisy.org/z3986/2010/vocab/resourcedirectory/#"
	xmlns:sel="http://www.daisy.org/ns/z3986/authoring/features/select/"
	exclude-result-prefixes="xs x rng d dc sel">

	<!--
		XSLT to build Resource Directories for Z3986 Profiles and Features
		Uses *.rd files as XSL input 
		
		The comments in <xsl:template match="x:html"> below describes
		which fields are brought in from the .rd files.
	-->

	<xsl:output method="xml" omit-xml-declaration="no" indent="yes"/>

	<!-- spec prefix -->
	<xsl:param name="spec-nicename-prefix" required="yes"/>
	<!-- human form of profile/feature name -->
	<xsl:param name="nicename" required="yes"/>
	<!-- machine form of profile/feature name -->
	<xsl:param name="machinename" required="yes"/>
	<!-- version of profile/feature -->
	<xsl:param name="version" required="yes"/>
	<!--  URL to doc with module listing, see rng-fileset.xsls -->
	<xsl:param name="schema-fileset"/>
	<xsl:variable name="modules" select="document($schema-fileset)"/>
	<!-- optional absolute URI to default vocab -->
	<xsl:param name="default-vocab-uri"/>
	<!-- Identity URI of the profile/feature, excluding version -->
	<xsl:param name="base-identity-uri" required="yes"/>
	<!-- z3986a or z3986b -->
	<xsl:param name="part-prefix" required="yes"/>
	<!-- required absolute uri to normative schema -->
	<xsl:param name="normative-schema-uri" required="yes"/>
	<!--  generated doc with informative schemas, is optional -->
	<xsl:param name="informative-schema-list"/>
	<!--  URI to a doc describing current version changes -->
	<xsl:param name="version-info-uri" required="no"/>

	<!-- profile or feature  -->
	<xsl:variable name="type">
		<xsl:choose>
			<xsl:when test="contains(lower-case($nicename), 'feature')">feature</xsl:when>
			<xsl:otherwise>profile</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- xml:base for online resolution -->
	<xsl:variable name="base">http://www.daisy.org/z3986/2010/auth/<xsl:value-of select="$type"
			/>s/<xsl:value-of select="$machinename"/>/<xsl:value-of select="$version"
		/>/</xsl:variable>

	<!-- title string -->
	<xsl:variable name="title">Resource Directory for the <xsl:value-of
			select="$spec-nicename-prefix"/>
		<xsl:value-of select="$nicename"/>, version <xsl:value-of select="$version"/></xsl:variable>
	
	<!-- link to the extracted schematron schema -->
	<xsl:variable name="sch-link">./resources/z3986a-<xsl:value-of select="$machinename"/>.sch</xsl:variable>

	<xsl:template match="x:html">

		<html version="XHTML+RDFa 1.0">
			<head>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<title>
					<xsl:value-of select="$title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="../../../../z3986-2010.css"/>
			</head>
			<body>
				<xsl:call-template name="doDocTitle"/>
				<xsl:call-template name="doStatusAlert"/>
				<xsl:call-template name="doIntroduction"/>
				<!-- from input, required, "x:div[@class='intro']" -->

				<div id="normative-references">
					<h2>Normative References</h2>
					<xsl:call-template name="doRFC2119"/>
					<xsl:copy-of select="x:div[@class='normative-top']/*"/>
					<!-- from input, optional, "x:div[@class='normative-top']" -->
					<xsl:call-template name="doVersionInfo"/>
					<xsl:call-template name="doIdentityURI"/>
					<xsl:call-template name="doSpecRef"/>
					<xsl:call-template name="doNormativeSchemas"/>
					<xsl:call-template name="doPublicComponents"/>
					<!-- from input, required, "x:div[@id='public-components']" -->
					<xsl:copy-of select="x:div[@class='normative-bottom']/*"/>
					<!-- from input, optional, "x:div[@class='normative-bottom']" -->
					<xsl:call-template name="doSupportedFeatures"/>
					<xsl:call-template name="doDefaultVocab"/>
					<xsl:call-template name="doProcessingAgentBehaviorReqs"/>
					<!-- from input, required, "x:div[@id='pa-reqs']" -->
					<xsl:call-template name="doAbsdef"/>
					<!-- from input, optional, "x:div[@id='absdef']" -->
				</div>

				<div id="informative-references">
					<h2>Informative References</h2>
					<xsl:if test="contains($type, 'profile')">
						<xsl:call-template name="doSchemaDocumentation"/>
						<xsl:call-template name="doTutorials"/>
						<xsl:call-template name="doInformativeSchemata"/>
						<xsl:call-template name="doCSS"/>
						<xsl:call-template name="doArchives"/>
					</xsl:if>
					<xsl:call-template name="doSupportingSoftware"/>
					<xsl:call-template name="doExamples"/>
					<!-- from input, optional, "x:div[@class='examples']" -->
				</div>

				<xsl:call-template name="doModuleList"/>
				<xsl:call-template name="doFooter"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="doRFC2119">
		<p class="RFC2119">The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
			"SHOULD", "RECOMMENDED", "MAY", and "OPTIONAL" in this section are to be interpreted as
			described in <a href="http://www.ietf.org/rfc/rfc2119.txt">RFC2119</a>.</p>
	</xsl:template>

	<xsl:template name="doDocTitle">
		<h1 property="dc:title">
			<span class="titlesub">Resource Directory for the <xsl:value-of
					select="$spec-nicename-prefix"/></span>
			<br/>
			<xsl:value-of select="$nicename"/>
			<span class="titlesub">
				<br/> version <xsl:value-of select="$version"/></span>
		</h1>
	</xsl:template>

	<xsl:template name="doStatusAlert">
		<p class="alert">This is a public review version, made available for testing and
			evaluation.</p>
	</xsl:template>

	<xsl:template name="doIntroduction">
		<div id="introduction">
			<h2>Introduction</h2>
			<!-- get from input *.rd doc -->
			<xsl:copy-of select="x:div[@class='intro']/*"/>

			<p id="maintenance-agency"> This <xsl:value-of select="$type"/> is maintained by the <a
					href="http://www.daisy.org/z3986/advisory/" rel="rd:maintenance-agency"
					>ANSI/NISO Z39.86 advisory committee</a> under the auspices of <a
					href="http://niso.org/">NISO</a>. </p>
		</div>
	</xsl:template>

	<xsl:template name="doIdentityURI">
		<div class="rd-section">
			<h3>Identity URI</h3>
			<p id="identity-uri"> The canonical identity URI of this version of this <xsl:value-of
					select="$type"/> is <code rel="rd:token-identifier"><xsl:value-of
						select="$base-identity-uri"/><xsl:value-of select="$version"/>/</code>. </p>
		</div>
	</xsl:template>

	<xsl:template name="doVersionInfo">
		<div class="rd-section">
			<h3>Version Information</h3>

			<p>This resource directory represents version <span property="rd:version"><xsl:value-of
						select="$version"/></span> of this <xsl:value-of select="$type"/>.</p>

			<xsl:choose>
				<xsl:when test="$version-info-uri">
					<p>
						<a href="{$version-info-uri}">A list of the changes introduced in this
							version is available.</a>
					</p>
				</xsl:when>
				<xsl:otherwise>
					<p>There is no explicit information available on changes introduced in this
						version.</p>
				</xsl:otherwise>
			</xsl:choose>

			<p id="version-listing">
				<a href="../index.html"> A listing of all public versions of this <xsl:value-of
						select="$type"/> is available. </a>
			</p>

			<p id="current-version"> The most recently published (current) version of this
					<xsl:value-of select="$type"/> is reachable through the static URI <a
					href="../current/" rel="current-version-uri"
						>http://www.daisy.org/z3986/2010/auth/<xsl:value-of select="$type"
						/>s/<xsl:value-of select="$machinename"/>/current/</a>. </p>
		</div>
	</xsl:template>

	<xsl:template name="doSpecRef">
		<div class="rd-section">
			<h3>Specification Compliance</h3>
			<p id="spec-ref"> This <xsl:value-of select="$type"/> is compliant with the <a
					href="../../../../Z3986-2010A.html" rel="rd:specification-compliance">Z3986-2010
					Part A Specification</a>. </p>
		</div>
	</xsl:template>

	<xsl:template name="doSupportedFeatures">
		<xsl:if test="contains($type,'profile')">
			<div class="rd-section">
				<h3>Supported Features</h3>
				<p>This profile supports the following features:</p>
				<ul>
					<xsl:for-each
						select="document(translate($normative-schema-uri,'\','/'))//rng:div[@x:class='feature']">
						<xsl:variable name="feature-id" select="./@x:id"/>
						<li>
							<a href="../../../features/{$feature-id}/index.html"
								rel="rd:z3986-feature">
								<xsl:value-of select="./x:h2"/>
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doSchemaDocumentation">
		<div class="rd-section">
			<h3 id="schema-documentation">Schema Documentation</h3>
			<p>
				<a href="./schemadoc/index.html" rel="rd:schema-documentation">Schema documentation
					is available online</a>, and is also included in the <a href="#archives"
					>downloadable archives</a>. </p>
		</div>
	</xsl:template>

	<xsl:template name="doTutorials">
		<div class="rd-section">
			<h3 id="tutorials">Tutorials and Primers</h3>
			<p>Refer to the <a href="http://www.daisy.org/zw/ZedAI_UserDocumentation">Z39.86-AI
					community portal</a> for further information on how to use this <xsl:value-of
					select="$type"/> .</p>
		</div>
	</xsl:template>

	<xsl:template name="doInformativeSchemata">
		<div class="rd-section">
			<h3 id="informative-schemas">Informative Schemata</h3>
			<p>The following informative schemata are available:</p>

			<xsl:variable name="schemas"
				select="document(translate($informative-schema-list,'\','/'))"/>

			<dl>
				<xsl:for-each select="$schemas//generated">
					<xsl:if test="@type!='core-rng-reduced'">
						<xsl:variable name="filename">
							<xsl:call-template name="filename">
								<xsl:with-param name="path" select="./@uri"/>
							</xsl:call-template>
						</xsl:variable>

						<dt>
							<!-- these schemas are in root profile directory -->
							<a href="./resources/{$filename}" rel="rd:informative-schema-alt">
								<xsl:value-of select="$filename"/>
							</a>
						</dt>
						<dd>
							<xsl:choose>
								<xsl:when test="@type='core-rng-simplified-full'"> A single file
									version of the normative RelaxNG schema in RelaxNG XML
									Syntax.</xsl:when>
								<xsl:when test="@type='core-rnc-simplified-full'"> A single file
									version of the normative RelaxNG schema in <a
										href="http://www.oasis-open.org/committees/relax-ng/compact-20021121.html"
										>RelaxNG Compact Syntax</a>. </xsl:when>
								<xsl:when test="@type='core-xsd-converted'"> A W3C XML Schema (XSD)
									version of the normative schema. This schema contains
									approximations. It is not guaranteed that instance documents
									valid to this schema will also be valid to the normative schema.
									This schema should be used for authoring purposes only; final
									validation should always be performed against the normative
									schema. </xsl:when>
								<xsl:otherwise> </xsl:otherwise>
							</xsl:choose>

						</dd>

					</xsl:if>
				</xsl:for-each>
				<xsl:if test="contains($type,'profile')">
					<dt id="sch-extracted"><a href="{$sch-link}"><xsl:call-template name="filename">
						<xsl:with-param name="path" select="$sch-link"/>
					</xsl:call-template></a></dt>
					<dd>An ISO Schematron schema that contains the Schematron rules embedded in the normative schema.</dd>
				</xsl:if>
			</dl>

			<h4 id="informative-schemata-feature-reduced">Feature-reduced schemata</h4>
			<p>These schemata are variants of the normative RelaxNG schema that have one or several
				features removed.</p>
			<p>They are provided for convenience during the authoring stage.</p>
			<p>An instance document valid to a feature-reduced schema will also be valid to the
				normative schema.</p>
			<dl>
				<xsl:for-each select="$schemas//generated[@type='core-rng-reduced']">
					<xsl:variable name="filename">
						<xsl:call-template name="filename">
							<xsl:with-param name="path" select="./@uri"/>
						</xsl:call-template>
					</xsl:variable>

					<dt>
						<!-- these schemas are in root profile directory -->
						<a href="{$filename}" rel="rd:informative-schema-alt">
							<xsl:value-of select="$filename"/>
						</a>
					</dt>
					<dd>The normative RelaxNG schema with <xsl:choose>
							<xsl:when test="contains(./@feature-nicename,'#all')">all
								features</xsl:when>
							<xsl:otherwise>the <xsl:value-of select="./@feature-nicename"/>
							</xsl:otherwise>
						</xsl:choose> removed.</dd>
				</xsl:for-each>
			</dl>
		</div>
	</xsl:template>

	<xsl:template name="doCSS">
		<div class="rd-section">
			<h3 id="default-css">Cascading Stylesheet (CSS)</h3>
			<p> A <a href="./resources/z3986a-base.css" rel="rd:default-css">default CSS
					stylesheet</a> is available for use with CSS-aware XML Editing applications. </p>

			<p> Refer to <a href="http://www.w3.org/TR/xml-stylesheet/"
					>http://www.w3.org/TR/xml-stylesheet/</a> for instructions on how to associate a
				CSS stylesheet with a document instance. </p>

			<p class="ednote">REMARK Reference may change as W3C is updating ASOCSS</p>
		</div>
	</xsl:template>

	<xsl:template name="doArchives">
		<div class="rd-section">
			<h3 id="archives">Archives</h3>
			<ul>
				<li> All schemas, documentation and resources of this directory <a
						href="{$part-prefix}-{$machinename}-{$version}.zip" rel="rd:archive"> in
							<code>zip</code> format </a>. </li>
				<li> All schemas, documentation and resources of this directory <a
						href="{$part-prefix}-{$machinename}-{$version}.tar.gz" rel="rd:archive"> in
							<code>tar gzip</code> format </a>. </li>
			</ul>
		</div>
	</xsl:template>

	<xsl:template name="doSupportingSoftware">
		<div class="rd-section" property="rd:supporting-software">
			<h3 id="supporting-software">Supporting software</h3>
			<p>Refer to the <a href="http://www.daisy.org/zw/ZedAI_UserDocumentation">Z39.86-AI
					community portal</a> for information on available software tools.</p>
		</div>
	</xsl:template>

	<xsl:template name="doNormativeSchemas">
		<div class="rd-section">
			<h3>Normative schemata</h3>
			<xsl:variable name="normative-schema-filename">
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="$normative-schema-uri"/>
				</xsl:call-template>
			</xsl:variable>

			<p> The normative schema of this <xsl:value-of select="$type"/> is <xsl:choose>
					<xsl:when test="contains($type,'profile')">
						<a href="{$normative-schema-filename}" rel="rd:normative-schema">
							<xsl:value-of select="$normative-schema-filename"/>
						</a> (<em>version <xsl:value-of select="$version"/></em>). </xsl:when>
					<xsl:otherwise>
						<!-- features are modules -->
						<a href="./mod/{$normative-schema-filename}" rel="rd:normative-schema">
							<xsl:value-of select="$normative-schema-filename"/>
						</a>. </xsl:otherwise>
				</xsl:choose>
			</p>

			<xsl:if test="contains($type,'feature')">
				<p>Note - this feature schema does not represent an entire document model; it is
					intended for inclusion in host profiles.</p>
			</xsl:if>

			<xsl:if test="contains($type,'profile')">				
				<p>Note - this schema includes embedded ISO Schematron assertions.  A <a href="{$sch-link}">
					standalone ISO Schematron schema</a> is provided for use in authoring
					tools that does not support embedded ISO Schematron.</p>
				<p class="ednote">REMARK - <a href="http://code.google.com/p/zednext/issues/detail?id=137">Issue 137</a></p>
			</xsl:if>

			<xsl:if test="count($modules/d:filelist/d:file) > 1">
				<p> The normative schema includes a number of modules and/or subschemas, which are
					listed in <a href="#module-list">Appendix 1</a>. </p>
			</xsl:if>
			<!--
			<p> The <em>latest version</em> of the normative schema is available at the
				canonical URI <xsl:choose>
					<xsl:when test="contains($type,'profile')">
						<a href="../../../../schema/{$normative-schema-filename}">
							http://www.daisy.org/z3986/2010/schema/<xsl:value-of
								select="$normative-schema-filename" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="../../../../schema/mod/{$normative-schema-filename}">
							http://www.daisy.org/z3986/2010/schema/mod/<xsl:value-of
								select="$normative-schema-filename" />
						</a>
					</xsl:otherwise>
				</xsl:choose>. </p>
			-->
		</div>
	</xsl:template>

	<xsl:template name="doDefaultVocab">
		<xsl:if test="boolean($default-vocab-uri) and contains($type,'profile')">
			<div class="rd-section">
				<h3>Default RDF vocabulary</h3>
				<!--
					only profiles express default vocabs - features inherit the
					defaultness in the instances. However, features can contribute
					vocabs, but they cant claim the default space for those vocabs.
				-->
				<xsl:variable name="vocabfilename">
					<xsl:call-template name="filename">
						<xsl:with-param name="path" select="translate($default-vocab-uri,'\','/')"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="vocab-canon-url">
					<xsl:choose>
						<xsl:when test="contains($vocabfilename, 'structure')">structure</xsl:when>
						<xsl:when test="contains($vocabfilename, 'book')">book</xsl:when>
						<xsl:when test="contains($vocabfilename, 'periodicals')"
							>periodicals</xsl:when>
						<xsl:when test="contains($vocabfilename, 'resourcedirectory')"
							>resourcedirectory</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<p> The default RDF vocabulary for this profile is the <a
						href="../../../../vocab/{$vocab-canon-url}/" rel="rd:z3986-default-vocab">
						<xsl:value-of
							select="document(translate($default-vocab-uri,'\','/'))//x:head/x:title"
						/>
					</a>. </p>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doExamples">
		<xsl:if test="x:div[@class='examples']/*">
			<div id="examples" property="rd:examples">
				<h3>Examples</h3>
				<xsl:copy-of select="x:div[@class='examples']/*"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doPublicComponents">
		<xsl:if test="contains($type,'feature')">
			<xsl:if test="count(x:div[@id='public-components']) &lt; 1">
				<xsl:message terminate="yes">No x:div[@id='public-components' in RD of <xsl:value-of
						select="$nicename"/></xsl:message>
			</xsl:if>
			<div id="public-components">
				<h3>Public Components</h3>
				<p>The <a href="../../../../Z3986-2010A.html#featuresMarkupModelPublic">public
						components</a> of this feature are:</p>
				<xsl:copy-of select="x:div[@id='public-components']/*"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doProcessingAgentBehaviorReqs">
		<xsl:if test="contains($type,'feature')">
			<xsl:if test="count(x:div[@id='pa-reqs']) &lt; 1">
				<xsl:message terminate="yes">No x:div[@id='pa-reqs' in RD of <xsl:value-of
						select="$nicename"/></xsl:message>
			</xsl:if>
			<div class="rd-section" id="pa-reqs">
				<h3>Processing Agent Behavior Requirements</h3>
				<xsl:copy-of select="x:div[@id='pa-reqs']/*"/>
				<!-- must contain pa-reqs-supported and pa-reqs-recognized -->
				<div class="rd-section">
					<!-- this is the same for all features, add last -->
					<h4 id="pa-reqs-notrecognized">Feature not recognized</h4>
					<p>If a Processing Agent <em>does not recognize</em> this feature, it must, as
						dictated by <a href="../../../../Z3986-2010A.html#featuresURIPA">the
							Z39.86-AI specification</a>, abort processing and issue an error
						message.</p>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doAbsdef">
		<xsl:if test="count(x:div[@id='absdef'])>0">
			<h3>Feature Modules - abstract definitions</h3>
			<p>The abstract definitions provided below follow the conventions defined in <a
					href="../../../../Z3986-2010A.html#coreModulePool">Abstract Definitions</a>.
					<span class="ednote">TODO fix link</span></p>
			<xsl:copy-of select="x:div[@id='absdef']"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doModuleList">
		<div id="module-list">
			<h2>Appendix 1: Listing of modules in the normative schema</h2>
			<p> Note: the canonical base URI of these modules is <a href="../../../../schema/mod/"
					>http://www.daisy.org/z3986/2010/schema/mod/</a> , where the modules are
				available in their <em>latest version</em>. </p>
			<p> The below list represents the modules at the time of version <xsl:value-of
					select="$version"/> of this <xsl:value-of select="$type"/>. </p>

			<p class="RFC2119">The occurence of the keywords "MUST", "MUST NOT", "REQUIRED",
				"SHALL", "SHALL NOT", "SHOULD", "RECOMMENDED", "MAY", and "OPTIONAL" in
				documentation fields embedded in these modules are to be interpreted as described in
					<a href="http://www.ietf.org/rfc/rfc2119.txt">RFC2119</a>.</p>

			<ul id="normative-schema-modules">
				<xsl:for-each select="$modules/d:filelist/d:file/@uri">
					<xsl:if test="contains(.,'mod')">
						<xsl:variable name="modname">
							<xsl:call-template name="filename">
								<xsl:with-param name="path" select="."/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="modpath" select="concat('./mod/',$modname)"/>
						<li>
							<a href="{$modpath}" rel="rd:schema-module">
								<!--
									todo could parse the module and get the nicename if its
									predictable, but wont be in the case of mathml.rng etc
								-->
								<xsl:value-of select="$modname"/>
							</a>
						</li>
					</xsl:if>
				</xsl:for-each>
			</ul>
		</div>
	</xsl:template>

	<xsl:template name="doFooter">
		<div class="footer">
			<p id="docinfo"> This document is a <em>Z39.86-2010 Resource Directory</em>, compliant
				with <a href="http://www.w3.org/TR/rdfa-syntax/">XHTML+RDFa</a> using the <a
					href="../../../../vocab/resourcedirectory/">Z3986-2010 Resource Directory
					Vocabulary</a>. </p>
		</div>
	</xsl:template>

	<xsl:template name="filename">
		<xsl:param name="path"/>
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="substring-after($path, '/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
