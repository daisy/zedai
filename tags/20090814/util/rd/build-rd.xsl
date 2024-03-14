<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:x="http://www.w3.org/1999/xhtml"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:d="http://www.daisy.org/z3986#" xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:rd="http://www.daisy.org/z3986/2010/vocab/resourcedirectory/#"
	exclude-result-prefixes="xs x rng d">

	<!--
		XSLT to build Resource Directories for Z3986 Profiles and Features
		Uses *.rd files as XSL input
	-->

	<xsl:output method="xml" omit-xml-declaration="no" indent="yes" />

    <!-- spec prefix -->
    <xsl:param name="spec-nicename-prefix" required="yes" />
	<!-- human form of profile/feature name -->
	<xsl:param name="nicename" required="yes" />
	<!-- machine form of profile/feature name -->
	<xsl:param name="machinename" required="yes" />
	<!-- version of profile/feature -->
	<xsl:param name="version" required="yes" />
	<!--  URL to doc with module listing, see rng-fileset.xsls -->
	<xsl:param name="schema-fileset" />
	<xsl:variable name="modules" select="document($schema-fileset)" />
	<!-- optional absolute URI to default vocab -->
	<xsl:param name="default-vocab-uri" />
	<!-- Identity URI of the profile/feature, excluding version -->
	<xsl:param name="base-identity-uri" required="yes" />
	<!-- z3986a or z3986b -->
	<xsl:param name="part-prefix" required="yes" />
	<!-- required absolute uri to normative schema -->
	<xsl:param name="normative-schema-uri" required="yes" />
	<!--  generated doc with informative schemas, is optional -->
	<xsl:param name="informative-schema-list" />
	<!-- profile or feature  -->
	<xsl:variable name="type">
		<xsl:choose>
			<xsl:when test="contains(lower-case($nicename), 'feature')">feature</xsl:when>
			<xsl:otherwise>profile</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- xml:base for online resolution -->
	<xsl:variable name="base">http://www.daisy.org/z3986/2010/auth/<xsl:value-of select="$type" />s/<xsl:value-of select="$machinename" />/<xsl:value-of select="$version" />/</xsl:variable>
	<xsl:variable name="title">Resource Directory for the <xsl:value-of select="$spec-nicename-prefix"
	  /> <xsl:value-of select="$nicename" />, version <xsl:value-of select="$version" /></xsl:variable>

	<xsl:template match="x:html">

		<html version="xhtml+rdfa"> <!-- xml:base="{$base}" makes saxon uriresolver crash-->
			<head>
				<meta http-equiv="content-type" content="text/html; charset=utf-8" />
				<title><xsl:value-of select="$title"/></title>
				<link rel="stylesheet" type="text/css" href="../../../../z3986-2010.css" />
				<!--  <base href="{$base}" /> -->
			</head>
			<body>
				<h1 property="dc:title"><span class="titlesub">Resource Directory for the <xsl:value-of 
				  select="$spec-nicename-prefix"/></span><br/>
				  <xsl:value-of select="$nicename" /><span class="titlesub"> <br/>
				  version <xsl:value-of select="$version" /></span>
			   </h1>
				
				<p class="alert">This is an early access version, made available for early
					testing and evaluation.</p>
				
				<div id="introduction"><h2>Introduction</h2>
					<!--  get from input *.rd doc -->
					<xsl:copy-of select="x:div[@class='intro']/*" />
				</div>
				
				<p id="maintenance-agency">
					This <xsl:value-of select="$type" /> is maintained by the <a href="http://www.daisy.org/z3986/advisory/" rel="rd:maintenance-agency"
					>ANSI/NISO Z39.86 advisory committee</a> under the auspices of <a href="http://niso.org/">NISO</a>.
				</p>
								
				<div id="normative-references">
					<h2>Normative References</h2>
					<xsl:copy-of select="x:div[@class='normative-top']/*" />
					
					<div class="rd-section">
						<h3>Identity URI</h3>
						<p id="identity-uri">
							The canonical identity URI of this version of this <xsl:value-of select="$type" /> is 
							<code rel="rd:token-identifier"><xsl:value-of select="$base-identity-uri"/><xsl:value-of select="$version"/>/</code>.
						</p>
					</div>
					
					<div class="rd-section">
						<h3>Specification Compliance</h3>
						<p id="spec-ref">
							This <xsl:value-of select="$type" /> is compliant with the
							<a href="../../../../z3986-2010a.html" rel="rd:specification-compliance">Z3986-2010 Part A Specification</a>.
						</p>
					</div>
					
					<div class="rd-section">
						<h3>Normative schemata</h3>
						<xsl:variable name="normative-schema-filename">
							<xsl:call-template name="filename">
								<xsl:with-param name="path" select="$normative-schema-uri" />
							</xsl:call-template>
						</xsl:variable>
	
						<p>
							The normative schema of this <xsl:value-of select="$type" /> is
							<xsl:choose>
								<xsl:when test="contains($type,'profile')">
									<a href="{$normative-schema-filename}" rel="rd:normative-schema">
										<xsl:value-of select="$normative-schema-filename" />
									</a> (<em>version <xsl:value-of select="$version" /></em>).
								</xsl:when>
								<xsl:otherwise> <!-- features are modules -->
									<a href="./mod/{$normative-schema-filename}" rel="rd:normative-schema">
										<xsl:value-of select="$normative-schema-filename" />
									</a>.
								</xsl:otherwise>
							</xsl:choose>
						</p>
	
						<xsl:if test="contains($type,'feature')">
							<p>Note - this feature schema does not represent an entire
								document model; it is intended for inclusion in host profiles.
							</p>
						</xsl:if>
	
						<p>
							The normative schema includes a number of modules and/or
							subschemas, which are listed in <a href="#module-list">Appendix 1</a>.
						</p>
	
						<p>
							The <em>latest version</em> of the normative schema is available at the canonical URI
							<xsl:choose>
								<xsl:when test="contains($type,'profile')">
									<a href="../../../../schema/{$normative-schema-filename}">
										http://www.daisy.org/z3986/2010/schema/<xsl:value-of select="$normative-schema-filename" />
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="../../../../schema/mod/{$normative-schema-filename}">
										http://www.daisy.org/z3986/2010/schema/mod/<xsl:value-of select="$normative-schema-filename" />
									</a>
								</xsl:otherwise>
							</xsl:choose>. 
						</p>
						
						<p id="version-listing">
							<a href="../index.html">
								A listing of all public versions of this <xsl:value-of select="$type" /> is available.
							</a>
						</p>
						
						<xsl:copy-of select="x:div[@class='normative-bottom']/*" />
						
					</div>
					
					<xsl:if test="contains($type,'profile')">
						<div class="rd-section">
							<h3>Supported Features</h3>
							<p>This profile supports the following optional features:</p>
							<ul>
								<xsl:for-each
									select="document(translate($normative-schema-uri,'\','/'))//rng:div[@x:class='feature']">
									<xsl:variable name="feature-id" select="./@x:id" />
									<li>
										<a href="../../../features/{$feature-id}/index.html" rel="rd:feature">
											<xsl:value-of select="./x:h2" />
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</div>	
					</xsl:if>

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
									<xsl:with-param name="path" select="translate($default-vocab-uri,'\','/')" />
								</xsl:call-template>
							</xsl:variable>
							
							<xsl:variable name="vocab-canon-url">
								<xsl:choose>
								  <xsl:when test="contains($vocabfilename, 'base')">print</xsl:when>
								  <xsl:when test="contains($vocabfilename, 'book')">book</xsl:when>
								  <xsl:when test="contains($vocabfilename, 'periodicals')">periodicals</xsl:when>
								  <xsl:when test="contains($vocabfilename, 'resourcedirectory')">resourcedirectory</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<p>
								The default RDF vocabulary for this profile is the
								<a href="../../../../vocab/{$vocab-canon-url}/" rel="rd:default-vocab">
									<xsl:value-of select="document(translate($default-vocab-uri,'\','/'))//x:head/x:title" />
								</a>.
							</p>
						</div>
					</xsl:if>
				</div>

				<div id="informative-references">
					<h2>Informative References</h2>

					<xsl:if test="contains($type, 'profile')">
						<div class="rd-section">
							<h3 id="schema-documentation">Schema Documentation</h3>
							<p>
								<a href="./schemadoc/index.html" rel="rd:schema-documentation">Schema documentation is available online</a>,
								and is also included in the
								<a href="#archives">downloadable archives</a>.
							</p>
						</div>
						
						<div class="rd-section">
							<h3 id="informative-schemas">Informative Schemata</h3>
							<p>The following informative schemata are available:</p>
							
							<xsl:variable name="schemas" select="document(translate($informative-schema-list,'\','/'))"/>
														
							<dl>
							 <xsl:for-each select="$schemas//generated"> 
							 <xsl:if test="@type!='core-rng-reduced'">
							    <xsl:variable name="filename">
								  <xsl:call-template name="filename">
									  <xsl:with-param name="path" select="./@uri" />
								  </xsl:call-template>
								</xsl:variable>

							   <dt>
							   <!-- these schemas are in root profile directory -->
							      <a href="./resources/{$filename}" rel="rd:informative-schema">
								    <xsl:value-of select="$filename"/>
								  </a>
							   </dt>
							   <dd>
							     <xsl:choose>
							     <xsl:when test="@type='core-rng-simplified-full'">
							       A single file version of the normative RelaxNG schema.
							     </xsl:when>
							     <xsl:when test="@type='core-xsd-converted'">
							      A W3C XML Schema (XSD) version of the normative schema. This schema contains
							      approximations. It is not guaranteed that instance documents valid to this
							      schema will also be valid to the normative schema. This schema should be used
							      for authoring purposes only; final validation should always be performed against
							      the normative schema.
							     </xsl:when>
							     <xsl:otherwise>
							     
							     </xsl:otherwise>
							     </xsl:choose>
							   
							   </dd>
							 
							 </xsl:if>
							 </xsl:for-each>
							</dl>
												
							<h4 id="informative-schemata-feature-reduced">Feature-reduced schemata</h4>
							<p>These schemas are variants of the normative RelaxNG schema that have one or several optional features removed.</p>
							<p>They are provided for convenience during the authoring stage.</p>
							<p>An instance document valid to a feature-reduced schema will also be valid to the normative schema.</p>
							<dl>
							  <xsl:for-each select="$schemas//generated[@type='core-rng-reduced']">
							    <xsl:variable name="filename">
								  <xsl:call-template name="filename">
									  <xsl:with-param name="path" select="./@uri" />
								  </xsl:call-template>
								</xsl:variable>
								
							    <dt> 
							      <!-- these schemas are in root profile directory -->
							      <a href="{$filename}" rel="rd:informative-schema">
								    <xsl:value-of select="$filename"/>
								  </a>
							    </dt>
							    <dd>The normative RelaxNG schema with <xsl:choose>
							        <xsl:when test="contains(./@feature-nicename,'#all')"
							        >all features</xsl:when>
							        <xsl:otherwise>the <xsl:value-of select="./@feature-nicename" />
							        </xsl:otherwise>
							      </xsl:choose> removed.</dd>
							  </xsl:for-each>
							</dl>
							<!-- 
							<ul>
								<xsl:for-each select="document(translate($informative-schema-list,'\','/'))//generated">
									<xsl:variable name="filename">
										<xsl:call-template name="filename">
											<xsl:with-param name="path" select="./@uri" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="contains(./@uri,'resources')">
											<li>
												<a href="./resources/{$filename}" rel="rd:informative-schema">
													<xsl:value-of select="./@desc" />
												</a>
											</li>
										</xsl:when>
										<xsl:otherwise>
											<li>
												<a href="{$filename}" rel="rd:informative-schema">
													<xsl:value-of select="./@desc" />
												</a>
											</li>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</ul>
							-->
						</div>
						
						<div class="rd-section">
							<h3 id="default-css">Cascading Stylesheet (CSS)</h3>
							<p>
								A <a href="./resources/z3986a-basic.css" rel="rd:default-css">default CSS stylesheet</a>
								is available for use with CSS-aware XML Editing applications.
							</p>
	
							<p>
								Refer to <a href="http://www.w3.org/TR/xml-stylesheet/">http://www.w3.org/TR/xml-stylesheet/</a>
								for instructions on how to associate a CSS stylesheet with a document instance.
							</p>
						</div>						

						<div class="rd-section">
							<h3 id="archives">Archives</h3>
							<ul>
								<li>
									All schemas, documentation and resources of this directory
									<a href="{$part-prefix}-{$machinename}-{$version}.zip" rel="rd:archive">
										in <code>zip</code> format
									</a>.
								</li>
								<li>
									All schemas, documentation and resources of this directory
									<a href="{$part-prefix}-{$machinename}-{$version}.tar.gz" rel="rd:archive">
										in <code>tar gzip</code> format
									</a>.
								</li>
							</ul>
						</div>

					</xsl:if>

					<div class="rd-section" property="d:supporting-software">
						<h3 id="supporting-software">Supporting software</h3>
						<p class="ednote">This section will contain references to transformation,
							validation etc software, once provisioning schemes are in place.</p>
					</div>
				</div>

				<xsl:if test="x:div[@class='examples']/*">
					<div id="examples" property="d:examples">
				  		<h2>Examples</h2>
				  		<xsl:copy-of select="x:div[@class='examples']/*" />
					</div>
				</xsl:if>
				
				<div id="module-list">
					<h2>Appendix 1: Listing of modules in the normative schema</h2>
					<p>
						Note: the canonical base URI of these modules is
						<a href="../../../../schema/mod/">http://www.daisy.org/z3986/2010/schema/mod/</a>
						, where the modules are available in their <em>latest version</em>.
					</p>
					<p>
						The below list represents the modules at the time of version
						<xsl:value-of select="$version" />
						of this <xsl:value-of select="$type" />.
					</p>

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
									<a href="{$modpath}" rel="rd:module">
										<!--
											todo could parse the module and get the nicename if its
											predictable
										-->
										<xsl:value-of select="$modname" />
									</a>
								</li>
							</xsl:if>
						</xsl:for-each>
					</ul>
				</div>
				<div class="footer">
					<p id="docinfo">
					  This document is a <em>Z39.86-2010 Resource Directory</em>, 
					  compliant with <a href="http://www.w3.org/TR/rdfa-syntax/">XHTML+RDFa</a> using the
					  <a href="../../../../vocab/resourcedirectory/">Z3986-2010 Resource Directory Vocabulary</a>.
					</p>				
				</div>
								
			</body>
		</html>
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

<!-- 
<xsl:template name="escapexml">
    <xsl:param name="block" />
    
    <xsl:for-each select="$block/*|$block/text()">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:value-of select=".">
                </xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> &lt;</xsl:text>
                <xsl:value-of select="name(.)"> </xsl:value-of>
                <xsl:for-each select="@*">
                    <xsl:value-of select="concat(' ', name())">
                    </xsl:value-of>
                    <xsl:text> ="</xsl:text>
                    <xsl:value-of select="."> </xsl:value-of>
                    <xsl:text> "</xsl:text>
                </xsl:for-each>
                <xsl:text> &gt; </xsl:text>
                <xsl:choose>
                    <xsl:when test="*">
                        <xsl:call-template name="escapexml">
                            <xsl:with-param name="block" select=".">
                                ; </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."> </xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> &lt;/</xsl:text>
                <xsl:value-of select="name(.)"> </xsl:value-of>
                <xsl:text> &gt; </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>
-->

</xsl:stylesheet>