<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hks="http://www.statped.no/huseby/xml/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:x="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="hks xs x">

	<!-- 
	20081003: Per Sennels (ps): Created 
-->

	<!-- VARIOUS PARAMETERS -->
	<xsl:param name="debug" as="xs:boolean" select="false()"/>
	<xsl:param name="docFoldername" as="xs:string" select="'Documentation'"/>
	<xsl:param name="docSubFoldername" as="xs:string" select="'subFiles'"/>
	<xsl:param name="docFilename" as="xs:string" select="'DAISYLeisure.html'"/>
	<xsl:param name="docTitle" as="xs:string" select="'The DAISY Leisure Profile'"/>

	<!-- VARIOUS VARIABLES -->
	<xsl:variable name="rngCompleteFilename" select="document-uri(.)"/>
	<xsl:variable name="rngFilename" select="replace($rngCompleteFilename,'^(.+)/(.+)$','$2')"/>
	<xsl:variable name="rngFolder" select="replace($rngCompleteFilename,'^(.+)/(.+)$','$1')"/>

	<xsl:variable name="rng.listOfFilenames" as="element()">
		<files xmlns="http://www.statped.no/huseby/xml/">
			<file helpfile-name="{$docFilename}">
				<completeFilename>
					<xsl:value-of select="$rngCompleteFilename"/>
				</completeFilename>
			</file>
			<xsl:apply-templates select="//include" mode="compile-lof"/>
		</files>
	</xsl:variable>

	<!--	<xsl:variable name="rng.listOfInvolvedFiles" as="element()*">
		<files xmlns="http://www.statped.no/huseby/xml/">
			<xsl:for-each select="$rng.listOfFilenames">
				<xsl:variable name="fn" as="xs:string" select="."/>
				<file name="{$fn}"/>
			</xsl:for-each>
		</files>
	</xsl:variable>-->
	<xsl:variable name="rng.listOfDefinitions" as="element()">
		<files xmlns="http://www.statped.no/huseby/xml/">
			<xsl:for-each select="$rng.listOfFilenames//hks:completeFilename">
				<file name="{.}">
					<xsl:for-each select="doc(.)//define">
						<definition name="{@name}" id="{concat(generate-id(),'-',@name)}">
							<xsl:copy-of select="@combine"/>
							<xsl:if test="ancestor::include">
								<xsl:attribute name="replaces"
									select="resolve-uri(ancestor::include[1]/@href,$rngFolder)"/>
							</xsl:if>
						</definition>
					</xsl:for-each>
				</file>
			</xsl:for-each>
		</files>
	</xsl:variable>
	<xsl:variable name="rng.listOfElements" as="element()">
		<elements xmlns="http://www.statped.no/huseby/xml/">
			<xsl:for-each select="$rng.listOfFilenames//hks:completeFilename">
				<xsl:variable name="fn" as="xs:string" select="."/>
				<xsl:for-each select="doc($fn)[descendant::element]">
					<xsl:for-each select="descendant::element">
						<element filename="{$fn}">
							<xsl:copy-of select="attribute::*"/>
							<xsl:copy-of select="child::*"/>
						</element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</elements>
	</xsl:variable>

	<xsl:variable name="rng.listOfReferences" as="element()">
		<references xmlns="http://www.statped.no/huseby/xml/">
			<xsl:for-each select="$rng.listOfFilenames//hks:completeFilename">
				<xsl:variable name="fn" as="xs:string" select="."/>
				<xsl:for-each select="doc($fn)[descendant::ref]">
					<xsl:for-each select="descendant::ref">
						<reference to="{@name}">
							<context>
								<file uri="{$fn}"/>
								<xsl:choose>
									<xsl:when test="ancestor::define">
										<define>
											<xsl:copy-of select="ancestor::define[1]/@*"/>
										</define>
									</xsl:when>
									<xsl:when test="ancestor::start">
										<start>
											<xsl:copy-of select="ancestor::define[1]/@*"/>
										</start>
									</xsl:when>
									<xsl:otherwise>
										<grammar/>
									</xsl:otherwise>
								</xsl:choose>
							</context>
							<!--							<xsl:copy-of select="attribute::*"/>
							<xsl:copy-of select="child::*"/>
-->
						</reference>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</references>
	</xsl:variable>

	<xsl:variable name="rng.DefinitionLookUpTable" as="element()">
		<dlut xmlns="http://www.statped.no/huseby/xml/">
			<!--<xsl:value-of select="count($rng.listOfDefinitions//hks:definition)" />-->
			<xsl:for-each-group select="$rng.listOfDefinitions//hks:definition" group-by="@name">
				<xsl:sort select="@name"/>
				<definition name="{current-grouping-key()}">
					<xsl:for-each select="current-group()">
						<xsl:variable name="fn" as="xs:string" select="../@name"/>
						<file name="{$fn}">
							<xsl:copy-of select="@combine, @id, @replaces"/>
							<xsl:if
								test="current-group()/@replaces and not(current()/@replaces or current()/@combine eq 'interleave')">
								<xsl:attribute name="replaced-by">
									<xsl:for-each select="current-group()[@replaces]">
										<xsl:value-of select="../@name"/>
									</xsl:for-each>
								</xsl:attribute>
							</xsl:if>
						</file>
					</xsl:for-each>
				</definition>
			</xsl:for-each-group>
		</dlut>
	</xsl:variable>

	<xsl:variable name="menuItems" as="element()">
		<items xmlns="http://www.statped.no/huseby/xml/">
			<item action="a" filename="{$docFilename}">Main documentation</item>
			<item action="b" filename="RelaxNGFileset.html">Relax NG Fileset</item>
			<item action="c" filename="Elements.html">Elements</item>
			<item action="d" filename="Defintions.html">Pattern definitions</item>
		</items>
	</xsl:variable>

	<xsl:variable name="documentHeadElement" as="element()">
		<head>
			<title>
				<xsl:value-of select="$docTitle"/>
			</title>
			<link rel="stylesheet" type="text/css" href="css/ProfileDocumentation.css"/>
		</head>
	</xsl:variable>

	<xsl:template match="*" mode="loe" priority="-5">
		<xsl:param name="elementName" as="xs:string" tunnel="yes"/>
		<xsl:if test="local-name() ne $elementName">
			<xsl:copy>
				<xsl:apply-templates mode="loe"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ref" mode="loe">
		<!--		<xsl:variable name="name" select="@name" as="xs:string"/>
		<xsl:variable name="def" select="$rng.DefinitionLookUpTable//hks:definition[@name eq $name]"
			as="element()"/>
		<xsl:for-each select="$def/hks:file">
			<xsl:apply-templates select="doc(@name)//define[@name eq $name]" mode="loe"/>
		</xsl:for-each>-->
	</xsl:template>

	<xsl:template match="define" mode="loe">
		<!--		<xsl:param name="defName" as="xs:string" tunnel="yes" select="'ps'"/>
		<xsl:if test="@name ne $defName">
			<xsl:apply-templates mode="loe">
				<xsl:with-param name="defName" as="xs:string" tunnel="yes" select="@name" />
			</xsl:apply-templates>
		</xsl:if>-->
	</xsl:template>


	<xsl:template match="include" mode="compile-lof">
		<xsl:variable name="includingRNG.completeFilename" as="xs:string"
			select="string(document-uri(/))"/>
		<xsl:variable name="includingRNG.filename" as="xs:string"
			select="replace($includingRNG.completeFilename,'^(.+)/(.+?)$','$2')"/>
		<xsl:variable name="includingRNG.folder" as="xs:string"
			select="replace($includingRNG.completeFilename,'^(.+)/(.+?)$','$1')"/>

		<xsl:variable name="includedRNG.completeFilename" as="xs:string"
			select="
			if (hks:isAbsoluteURI(@href))
			then @href
			else (: concat($includingRNG.folder,'/',@href) :)
				resolve-uri(@href,$includingRNG.completeFilename)"/>

		<xsl:variable name="includedRNG.filename" as="xs:string"
			select="replace($includedRNG.completeFilename,'^(.+)/(.+)$','$2')"/>
		<xsl:variable name="includedRNG.doc" select="doc($includedRNG.completeFilename)"/>

		<file href-value="{@href}" xmlns="http://www.statped.no/huseby/xml/"
			helpfile-name="{concat(replace($includedRNG.filename,'^(.+)\.(.+?)$','$1'),'-',generate-id(),'.html')}">
			<host>
				<xsl:value-of select="$includingRNG.completeFilename"/>
			</host>
			<completeFilename>
				<xsl:value-of select="$includedRNG.completeFilename"/>
			</completeFilename>
			<!--			<helpFile>
				<xsl:value-of select="
					lower-case(
						replace(
							substring-after(
								translate(
									translate(
										$includedRNG.completeFilename,
										'\',
										'/'
									),
									'/',
									''
								),
								':'
							),
							'^(.+)\.rng$',
							'$1.html'
						)
					)" />
			</helpFile>-->
		</file>
		<!--		<xsl:sequence select="$includedRNG.completeFilename"/>-->
		<!--<xsl:message>* <xsl:value-of select="$includedRNG.completeFilename" /></xsl:message>-->
		<xsl:apply-templates select="$includedRNG.doc//include" mode="compile-lof"/>
	</xsl:template>

	<xsl:template match="/" mode="first-time">
		<xsl:message>** Generating documentation for the profile <xsl:value-of select="$docTitle"
			/>,</xsl:message>
		<xsl:message>defined by the file <xsl:value-of select="$rngFilename"/>,</xsl:message>
		<xsl:message>located in folder: <xsl:value-of select="$rngFolder"/>.</xsl:message>
		<xsl:message>** Documentation will be generated as a set of files</xsl:message>
		<xsl:message>located in the folder <xsl:value-of select="$docFoldername"/>.</xsl:message>

		<!-- Store the driver rng in a variable; we will need it in other contexts later -->
		<xsl:variable name="RNG" as="node()" select="."/>

		<xsl:for-each select="$menuItems//hks:item">
			<xsl:variable name="fn" as="xs:string" select="@filename"/>
			<xsl:result-document href="{concat($docFoldername,'/',$fn)}" method="xhtml"
				encoding="UTF-8" indent="yes"
				doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
				doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<xsl:message>** Creating <xsl:value-of select="concat($docFoldername,'/',$fn)"
					/></xsl:message>
				<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
					<xsl:copy-of select="$documentHeadElement"/>
					<body id="topp">
						<h1 class="title">
							<xsl:value-of select="$docTitle"/>
						</h1>
						<div id="main-container">
							<div id="menu-and-info">
								<xsl:call-template name="createMenu">
									<xsl:with-param name="activeFile" as="xs:string" select="$fn"/>
								</xsl:call-template>
							</div>
							<div id="content">
								<xsl:choose>
									<xsl:when test="@action eq 'a'">
										<!--<xsl:call-template name="toc"/>-->
										<xsl:apply-templates select="$RNG">
											<xsl:with-param name="linkToSubFolder" as="xs:boolean" select="true()" tunnel="yes" />
										</xsl:apply-templates>
									</xsl:when>
									<xsl:when test="@action eq 'b'">
										<xsl:call-template name="createFileSetList"/>
									</xsl:when>
									<xsl:when test="@action eq 'c'">
										<xsl:call-template name="createElementList"/>
									</xsl:when>
									<xsl:when test="@action eq 'd'">
										<xsl:call-template name="createPatternList"/>
									</xsl:when>
									<xsl:otherwise/>
								</xsl:choose>
							</div>
						</div>
					</body>
				</html>
			</xsl:result-document>

		</xsl:for-each>

		<!-- Generate the main documentation -->
		<!--		<xsl:result-document href="{concat($docFoldername,'/',$docFilename)}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<xsl:message>** Creating <xsl:value-of select="concat($docFoldername,'/',$docFilename)" /></xsl:message>
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<xsl:copy-of select="$documentHeadElement"/>
				<body>
					<h1 class="title">
						<xsl:value-of select="$docTitle"/>
					</h1>
					<xsl:call-template name="createMenu">
						<xsl:with-param name="activeFile" as="xs:string" select="$docFilename"/>
					</xsl:call-template>
					<div id="main-content">
						<xsl:call-template name="toc"/>
						<xsl:apply-templates/>
					</div>
				</body>
			</html>
		</xsl:result-document>-->

		<!-- Generate a list of files in the schema file set -->
		<!--		<xsl:result-document href="{concat($docFoldername,'/RelaxNGFileset.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<xsl:message>** Creating <xsl:value-of select="concat($docFoldername,'/RelaxNGFileset.html')" /></xsl:message>
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<xsl:copy-of select="$documentHeadElement"/>
				<body>
					<h1 class="title">
						<xsl:value-of select="$docTitle"/>
					</h1>
					<xsl:call-template name="createMenu">
						<xsl:with-param name="activeFile" as="xs:string"
							select="'RelaxNGFileset.html'"/>
					</xsl:call-template>
					<div id="main-content">
						<xsl:call-template name="createFileSetList"/>
					</div>
				</body>
			</html>
		</xsl:result-document>-->

		<!-- Generate a list of elements in the schema -->
		<!--		<xsl:result-document href="{concat($docFoldername,'/Elements.html')}" method="xhtml"
			encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
				<xsl:copy-of select="$documentHeadElement"/>
				<body>
					<h1 class="title">
						<xsl:value-of select="$docTitle"/>
					</h1>
					<xsl:call-template name="createMenu">
						<xsl:with-param name="activeFile" as="xs:string" select="'Elements.html'"/>
					</xsl:call-template>
					<div id="main-content">
						<xsl:call-template name="createElementList"/>
					</div>
				</body>
			</html>
		</xsl:result-document>-->

		<!-- Create one file per schema file -->
		<xsl:for-each select="$rng.listOfFilenames//hks:file">
			<xsl:result-document
				href="{concat($docFoldername,'/',$docSubFoldername,'/',@helpfile-name)}"
				method="xhtml" encoding="UTF-8" indent="yes"
				doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
				doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
					<head>
						<title>Relax NG schema module</title>
						<link rel="stylesheet" type="text/css"
							href="../css/ProfileDocumentation.css"/>
					</head>
					<body>
						<h1 class="title">
							<xsl:value-of select="$docTitle"/>
						</h1>
						<xsl:apply-templates select="doc(hks:completeFilename)"/>
					</body>
				</html>
			</xsl:result-document>
		</xsl:for-each>

		<!-- Create one file per element -->
		<xsl:for-each select="distinct-values($rng.listOfElements//hks:element/@name)">
			<xsl:variable name="n" as="xs:string" select="."/>
			<xsl:variable name="elementDefs" as="element()+"
				select="$rng.listOfElements//hks:element[@name eq $n]"/>
			<xsl:result-document
				href="{concat($docFoldername,'/',$docSubFoldername,'/_',$n,'.html')}" method="xhtml"
				encoding="UTF-8" indent="yes"
				doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
				doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
					<head>
						<title>The <xsl:value-of select="$n"/><xsl:text>-element in </xsl:text>
							<xsl:value-of select="$docTitle"/>
						</title>
						<link rel="stylesheet" type="text/css"
							href="../css/ProfileDocumentation.css"/>
					</head>
					<body>
						<h1 class="title"> The <span class="name">
								<xsl:value-of select="$n"/>
							</span><xsl:text>-element in </xsl:text>
							<xsl:value-of select="$docTitle"/>
						</h1>
						<!--						<xsl:apply-templates select="$elementDefs"/>
						<hr />-->
						<xsl:for-each select="$elementDefs">
							<p>
								<xsl:text>Defined in </xsl:text>
								<span class="uri">
									<xsl:value-of select="@filename"/>
								</span>
								<xsl:text>:</xsl:text>
							</p>
							<xsl:apply-templates/>
							<xsl:if test="position() ne last()">
								<hr/>
							</xsl:if>
						</xsl:for-each>
						<!--						<hr />
						<div class="element">
							<div class="element-top"> The <span class="element">
								<xsl:value-of select="$n"/>
							</span>
								<xsl:text>-element</xsl:text>
							</div>
							<div class="element-content">
								<xsl:for-each select="$elementDefs">
									<p>
										<xsl:text>Defined in </xsl:text>
										<span class="uri">
											<xsl:value-of select="@filename"/>
										</span>
										<xsl:text>:</xsl:text>
									</p>
									<xsl:apply-templates>
										<xsl:with-param name="creatingElementList" as="xs:boolean" tunnel="yes"
											select="true()"/>
									</xsl:apply-templates>
									<xsl:if test="position() ne last()">
										<hr/>
									</xsl:if>
								</xsl:for-each>
							</div>
						</div>-->
						<xsl:call-template name="createElementList">
							<xsl:with-param name="activeElement" as="xs:string" select="$n"/>
						</xsl:call-template>
					</body>
				</html>
			</xsl:result-document>
		</xsl:for-each>

		<!-- Create one file for each defined pattern in the compound schema  -->
		<xsl:for-each select="$rng.DefinitionLookUpTable//hks:definition">
			<xsl:variable name="def.name" as="xs:string" select="@name"/>
			<xsl:result-document
				href="{concat($docFoldername,'/',$docSubFoldername,'/',$def.name,'.html')}"
				method="xhtml" encoding="UTF-8" indent="yes"
				doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
				doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
					<head>
						<title> The <xsl:value-of select="$def.name"/><xsl:text>-pattern in </xsl:text>
							<xsl:value-of select="$docTitle"/>
						</title>
						<link rel="stylesheet" type="text/css"
							href="../css/ProfileDocumentation.css"/>
					</head>
					<body>
						<h1 class="title"> The <span class="name">
								<xsl:value-of select="$def.name"/>
							</span><xsl:text>-pattern in </xsl:text>
							<xsl:value-of select="$docTitle"/>
						</h1>

						<div class="pattern">
							<div class="pattern-top"> The <span class="name">
									<xsl:value-of select="$def.name"/>
								</span>
								<xsl:text>-pattern defines:</xsl:text>
							</div>
							<div class="pattern-content">
								<xsl:choose>
									<xsl:when test="count(hks:file) eq 1">
										<xsl:apply-templates
											select="doc(hks:file/@name)//define[@name eq $def.name]"/>
										<p>This defintition is found in <span class="uri">
												<xsl:value-of select="hks:file/@name"/>
											</span>
										</p>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates
											select="doc(hks:file[not(@combine) and not(@replaced-by)]/@name)//define[@name eq $def.name]"/>
										<p>This defintition is found in <span class="uri">
												<xsl:value-of select="hks:file[not(@combine)]/@name"
												/>
											</span>
											<xsl:text>.</xsl:text>
										</p>
										<p>This is the primary definition of this pattern. However,
											the <span class="name">
												<xsl:value-of select="$def.name"/>
											</span>
											<xsl:text>-pattern is modified by definitions in other files:</xsl:text>
										</p>
										<xsl:for-each select="hks:file[@combine]">
											<xsl:apply-templates
												select="doc(@name)//define[@name eq $def.name]"/>
											<p> This definition is found in <span class="uri">
												<xsl:value-of select="@name"/>
												</span>
												<xsl:text>.</xsl:text>
											</p>
											<xsl:if test="position() ne last()">
												<hr/>
											</xsl:if>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>

						<xsl:call-template name="createReferenceList">
							<xsl:with-param name="activePattern" as="xs:string" select="$def.name"/>
						</xsl:call-template>

						<xsl:call-template name="createPatternList">
							<xsl:with-param name="activePattern" as="xs:string" select="$def.name"/>
						</xsl:call-template>
					</body>
				</html>
			</xsl:result-document>
		</xsl:for-each>

		<xsl:if test="$debug">
			<xsl:result-document href="_lod.xml" method="xml" indent="yes">
				<xsl:copy-of select="$rng.listOfDefinitions"/>
			</xsl:result-document>
			<xsl:result-document href="_loe.xml" method="xml" indent="yes">
				<xsl:copy-of select="$rng.listOfElements"/>
			</xsl:result-document>
			<xsl:result-document href="_dlut.xml" method="xml" indent="yes">
				<xsl:copy-of select="$rng.DefinitionLookUpTable"/>
			</xsl:result-document>
			<xsl:result-document href="_lof.xml" method="xml" indent="yes">
				<xsl:copy-of select="$rng.listOfFilenames"/>
			</xsl:result-document>
			<xsl:result-document href="_lorefs.xml" method="xml" indent="yes">
				<xsl:copy-of select="$rng.listOfReferences"/>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>



	<xsl:template match="x:h2 | x:h3 | x:h4" mode="toc">
		<li class="{concat('toc-',local-name())}">
			<a href="{concat('#',generate-id())}">
				<xsl:value-of select="."/>
			</a>
			<!--			<ul>
				<xsl:for-each-group select="current-group() except ." group-starting-with="h3">
					<xsl:apply-templates select="." mode="toc" />
				</xsl:for-each-group>
			</ul>-->
		</li>
	</xsl:template>


	<xsl:template match="include" mode="main-doc"> </xsl:template>
	<!--	<xsl:template match="define/*/ref | define/ref" mode="rng-def">
		<a href="{concat('_',@name,'.html')}">
			<xsl:value-of select="@name" />
		</a>
	</xsl:template>-->

	<xsl:template match="element()" priority="-5">
		<!--<xsl:message terminate="no">*** No matching template for the <xsl:value-of select="local-name(.)" /> element!</xsl:message>-->
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="x:*">
		<!-- Use whatever xhtml doc available -->
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="x:h1 | x:h2 | x:h3 | x:h4 | x:h4 | x:h6">
		<xsl:element name="{local-name()}">
			<xsl:attribute name="id" select="generate-id()"/>
			<xsl:attribute name="class" select="'xhtml'"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="x:a[@class eq 'module-description']">
		<xsl:variable name="link">
			<xsl:text>Follow the link to </xsl:text>
			<a href="{@href}" target="_blank">
				<xsl:text>&#171;</xsl:text>
				<xsl:value-of select="preceding::x:*[matches(local-name(),'^h[1-6]$')][1]"/>
				<xsl:text>&#187;</xsl:text>
			</a>
			<xsl:text> to learn more.</xsl:text>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="parent::x:p">
				<xsl:copy-of select="$link"/>
			</xsl:when>
			<xsl:otherwise>
				<p>
					<xsl:copy-of select="$link"/>
				</p>
			</xsl:otherwise>
		</xsl:choose>

		<!--		<p>
			<xsl:call-template name="informationLink"/>
		</p>-->
	</xsl:template>


	<xsl:template match="grammar | div">
		<xsl:apply-templates/>
	</xsl:template>

	<!--	<xsl:template match="define">
		<div class="define"> Defining pattern: <xsl:value-of select="@name"/><br/>
			<xsl:apply-templates/>
		</div>
	</xsl:template>-->

	<!--	<xsl:template match="element">
		<div class="element">Element: <xsl:value-of select="@name"/><br/>
			<xsl:apply-templates mode="element-description"/>
		</div>
	</xsl:template>-->

	<!--	<xsl:template match="element/ref" mode="element-description">
		<xsl:variable name="name" select="@name" as="xs:string"/>
		<xsl:variable name="def.list" as="element()"
			select="$rng.DefinitionLookUpTable//hks:definition[@name eq $name]"/>
		<xsl:if test="true()">
			<div class="ref"> Ref: <xsl:value-of select="$name"/><br/>
				<xsl:for-each select="$def.list//hks:file">
					<xsl:variable name="rng.file" as="xs:string" select="@name"/> &#8226;
					Definert i <xsl:value-of select="$rng.file"/>:<br/>
					<xsl:apply-templates select="doc($rng.file)//define[@name eq $name]" mode="element-description"/>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>-->

	<xsl:template match="include" priority="2">
		<!--<xsl:variable name="href" as="xs:string" select="@href" />-->
		<!-- get the location of the including file: -->
		<xsl:variable name="includingRNG.completeFilename" as="xs:string"
			select="string(document-uri(/))"/>
		<xsl:variable name="includingRNG.folder" as="xs:string"
			select="replace($includingRNG.completeFilename,'^(.+)/(.+?)$','$1')"/>

		<!--		<xsl:variable name="hrefExpandedToFullURI" as="xs:string"
			select="resolve-uri(@href,$includingRNG.completeFilename) (: if (hks:isAbsoluteURI(@href)) then @href else concat($includingRNG.folder,'/',@href) :)"/>-->
		<!-- psps-20081008: The following must be changed to handle general URI's -->
		<xsl:variable name="docFilename" as="xs:string"
			select="$rng.listOfFilenames//hks:file[@href-value eq current()/@href and hks:host eq $includingRNG.completeFilename]/@helpfile-name"/>

		<p>This module is defined in <span class="uri">
				<xsl:value-of select="resolve-uri(@href,$includingRNG.completeFilename)"/>
			</span>. You can find more information about this module in its <a>
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="$includingRNG.completeFilename eq $rngCompleteFilename">
							<xsl:value-of select="concat($docSubFoldername,'/',$docFilename)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$docFilename"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$includingRNG.completeFilename eq $rngCompleteFilename">
					<xsl:attribute name="target" select="'_blank'"/>
				</xsl:if>
				<xsl:text>associated documentation file (</xsl:text>
				<xsl:value-of select="$docFilename"/>
				<xsl:text>)</xsl:text>
			</a>.
		</p>
		<xsl:next-match />
	</xsl:template>

	<xsl:template match="include">
		<div class="rng">
			<xsl:call-template name="rngName"/>
			<span class="uri"><xsl:value-of select="@href"/><!--<xsl:value-of select="resolve-uri(@href,$includingRNG.completeFilename)"/>--></span>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	<!-- Templates for the relax NG syntax -->

	<xsl:template match="*">
		<div class="rng">
			<xsl:call-template name="rngName"/>
			<xsl:apply-templates/>
		</div>
		<!--<xsl:message>No template: <xsl:value-of select="local-name()" /></xsl:message>-->
<!--		<xsl:apply-templates/>-->
	</xsl:template>

	<xsl:template match="param[@name eq 'pattern']">
		<div class="rng">
			<span class="text">The value must match the following regular expression:</span>
			 <code><xsl:value-of select="." /></code>
		</div>
	</xsl:template>
	
	<xsl:template match="ref">
		<xsl:param name="linkToSubFolder" as="xs:boolean" tunnel="yes" select="false()"/>
		<div class="rng">
			<xsl:call-template name="rngName"/> Referencing <a class="ref"
				href="{concat(@name,'.html')}">
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="$linkToSubFolder">
							<xsl:value-of select="concat($docSubFoldername,'/',@name,'.html')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(@name,'.html')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$linkToSubFolder">
					<xsl:attribute name="target" select="'_blank'"/>
				</xsl:if>
				<xsl:value-of select="@name"/>
			</a>
		</div>
		<!--		<div class="ref"> &#8226; Referencing <a class="ref" href="{concat(@name,'.html')}">
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="$creatingElementList">
							<xsl:value-of select="concat($docSubFoldername,'/',@name,'.html')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(@name,'.html')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$creatingElementList">
					<xsl:attribute name="target" select="'_blank'"/>
				</xsl:if>
				<xsl:value-of select="@name"/>
			</a>
		</div>-->
	</xsl:template>

<!--	<xsl:template match="element">
		<div class="element">
			<div class="element-top">Element: <span class="name">
					<xsl:value-of select="@name"/>
				</span></div>
			<div class="element-content">
				<strong>Content model:</strong>
				<br/>
				<xsl:apply-templates/>
			</div>
		</div>
	</xsl:template>-->

	<xsl:template match="define | element | attribute">
		<div class="rng">
			<xsl:call-template name="rngName"/>
			<span class="name">
				<xsl:value-of select="@name" />
			</span>
			<xsl:if test="local-name() eq 'define' and local-name(..) eq 'include'">
				<br />
				<em>This defintion replaces the similar definition in the included file.</em>
			</xsl:if>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="text">
		<div class="rng">
			<xsl:call-template name="rngName"/> Zero or more text nodes. <xsl:apply-templates/>
		</div>
	</xsl:template>

<!--	<xsl:template match="attribute">
		<div class="attribute">
			<div class="attribute-top">Attribute: <span class="name">
					<xsl:value-of select="@name"/>
				</span></div>
			<div class="attribute-content">
				<strong>Content model:</strong>
				<br/>
				<xsl:if test="not(child::*)">
					<div class="text">Text</div>
				</xsl:if>
				<xsl:apply-templates/>
			</div>
		</div>
	</xsl:template>-->

	<xsl:template match="empty">
		<div class="rng">
			<xsl:call-template name="rngName"/> Defined to be empty </div>
	</xsl:template>

	<xsl:template match="optional">
		<div class="rng">
			<xsl:call-template name="rngName"/> The following is optional: <xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="choice">
		<div class="rng">
			<xsl:call-template name="rngName"/> A choice between at least one of:
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="oneOrMore">
		<div class="rng">
			<xsl:call-template name="rngName"/> One or more of: <xsl:apply-templates/>
		</div>
	</xsl:template>
	<xsl:template match="zeroOrMore">
		<div class="rng">
			<xsl:call-template name="rngName"/> Zero or more of: <xsl:apply-templates/>
		</div>
	</xsl:template>


	<!-- VARIOUS NAMED TEMPLATES -->
	<xsl:template name="rngName">
		<span class="rng">
			<xsl:value-of select="local-name()"/>
		</span>
		<xsl:text>: </xsl:text>
	</xsl:template>

	<xsl:template name="createPatternList">
		<xsl:param name="activePattern" as="xs:string" select="''"/>
		<h1>The patterns in this profile</h1>
		<p>
			<xsl:choose>
				<xsl:when test="$activePattern eq ''"> There are <xsl:value-of
						select="count($rng.DefinitionLookUpTable//hks:definition)"/> patterns
					defined in this profile. </xsl:when>
				<xsl:otherwise> The <span class="name">
						<xsl:value-of select="$activePattern"/>
					</span><xsl:text>-pattern is one of </xsl:text>
					<xsl:value-of select="count($rng.DefinitionLookUpTable//hks:definition)"/>
					patterns defined in this profile. Other patterns are listed below.
				</xsl:otherwise>
			</xsl:choose>

			<!--			The <span class="name"><xsl:value-of select="$activePattern" /></span><xsl:text>-pattern is one of </xsl:text>
			<xsl:value-of select="count($rng.DefinitionLookUpTable//hks:definition)" />
			patterns defined in this profile.
			Other patterns are listed below.-->
		</p>
		<div id="pattern-menu">
			<div id="pattern-menu-letters">
				<xsl:for-each-group select="$rng.DefinitionLookUpTable//hks:definition"
					group-by="upper-case(substring(@name,1,1))">
					<xsl:sort select="upper-case(@name)"/>
					<a href="{concat('#',current-grouping-key())}">
						<xsl:value-of select="current-grouping-key()"/>
					</a>
					<xsl:text> </xsl:text>
				</xsl:for-each-group>
			</div>
			<xsl:for-each-group select="$rng.DefinitionLookUpTable//hks:definition"
				group-by="upper-case(substring(@name,1,1))">
				<xsl:sort select="upper-case(@name)"/>
				<div class="pattern-group" id="{current-grouping-key()}">
					<xsl:for-each select="current-group()">
						<xsl:sort select="upper-case(@name)"/>
						<a>
							<xsl:attribute name="href">
								<xsl:choose>
									<xsl:when test="$activePattern eq ''">
										<xsl:value-of
											select="concat($docSubFoldername,'/',@name,'.html')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat(@name,'.html')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:if test="@name eq $activePattern">
								<xsl:attribute name="class" select="'selected-pattern'"/>
							</xsl:if>
							<xsl:if test="$activePattern eq ''">
								<xsl:attribute name="target" select="'_blank'"/>
							</xsl:if>
							<xsl:value-of select="@name"/>
						</a>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</div>
			</xsl:for-each-group>
		</div>
	</xsl:template>

	<xsl:template name="createFileSetList">
		<h1>The RelaxNG Fileset</h1>
		<p>
			<xsl:text>The schema file set consists of the following </xsl:text>
			<xsl:choose>
				<xsl:when test="count($rng.listOfFilenames//hks:file) eq 1">file:</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count($rng.listOfFilenames//hks:file)"/> files:
				</xsl:otherwise>
			</xsl:choose>
		</p>
		<ol>
			<xsl:for-each select="$rng.listOfFilenames//hks:file">
				<li>
					<span class="uri">
						<xsl:value-of select="hks:completeFilename"/>
					</span>
					<br/>
					<xsl:choose>
						<xsl:when test="$rngCompleteFilename eq hks:completeFilename"> This is the
							base file. </xsl:when>
						<xsl:otherwise> Referenced from <span class="uri">
								<xsl:value-of select="hks:host"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</li>
			</xsl:for-each>
		</ol>
	</xsl:template>

	<xsl:template name="createElementList">
		<xsl:param name="activeElement" as="xs:string" select="''"/>
		<xsl:variable name="names" as="xs:string+"
		select="distinct-values($rng.listOfElements//hks:element/@name)"/>
		<h1>The elements in this profile</h1>
		<p>
			<xsl:choose>
				<xsl:when test="$activeElement eq ''">
					<xsl:value-of select="count($names)"/> elements are defined for this profile: </xsl:when>
				<xsl:otherwise> The <span class="name">
						<xsl:value-of select="$activeElement"/>
					</span><xsl:text>-element is one of </xsl:text>
					<xsl:value-of select="count($names)"/> elements defined in this profile. Other
					elements are listed below. </xsl:otherwise>
			</xsl:choose>

		</p>
		<div id="element-menu">
			<xsl:for-each select="$names">
				<xsl:sort select="."/>
				<xsl:variable name="n" as="xs:string" select="."/>
				<a>
					<xsl:attribute name="href">
						<xsl:choose>
							<xsl:when test="$activeElement eq ''">
								<xsl:value-of select="concat($docSubFoldername,'/_',$n,'.html')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('_',$n,'.html')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="$activeElement eq $n">
						<xsl:attribute name="class" select="'selected-element'"/>
					</xsl:if>
					<xsl:if test="$activeElement eq ''">
						<xsl:attribute name="target" select="'_blank'"/>
					</xsl:if>
					<xsl:value-of select="."/>
					<xsl:if test="count($rng.listOfElements//hks:element[@name eq $n]) gt 1">
						<xsl:text> *</xsl:text>
					</xsl:if>
				</a>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</div>
		<p>Elements marked with * are multiply defined</p>

		<!--		<xsl:for-each select="$names">
			<xsl:variable name="n" as="xs:string" select="."/>
			<xsl:variable name="elementDefs" as="element()+"
				select="$rng.listOfElements//hks:element[@name eq $n]"/>
			<div class="element" id="{$n}">
				<div class="element-top"> The <span class="element">
						<xsl:value-of select="$n"/>
					</span>
					<xsl:text>-element</xsl:text>
				</div>
				<div class="element-content">
					<xsl:for-each select="$elementDefs">
						<p>
							<xsl:text>Defined in </xsl:text>
							<span class="uri">
								<xsl:value-of select="@filename"/>
							</span>
							<xsl:text>:</xsl:text>
						</p>
						<xsl:apply-templates>
							<xsl:with-param name="creatingElementList" as="xs:boolean" tunnel="yes"
								select="true()"/>
						</xsl:apply-templates>
						<xsl:if test="position() ne last()">
							<hr/>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:for-each>-->
	</xsl:template>

	<xsl:template name="createReferenceList">
		<xsl:param name="activePattern" as="xs:string" select="''"/>
		<xsl:variable name="refList" as="element()*"
			select="$rng.listOfReferences//hks:reference[@to eq $activePattern]"/>
		<div id="refList">
			<p>
				<xsl:text>The pattern </xsl:text>
				<span class="name">
					<xsl:value-of select="$activePattern"/>
				</span>
				<xsl:text> is referenced </xsl:text>
				<xsl:value-of select="count($refList)"/>
				<xsl:text> times:</xsl:text>
			</p>
			<ol>
				<xsl:for-each select="$refList">
					<li>
						<xsl:choose>
							<xsl:when test="hks:context/hks:define"> Referenced from the definition
								of the <xsl:if
									test="hks:context/hks:define/@combine eq 'interleave'">
									<em>interleaved</em>
								</xsl:if>
								<a href="{concat(hks:context/hks:define/@name,'.html')}">
									<span class="name">
										<xsl:value-of select="hks:context/hks:define/@name"/>
									</span>
									<xsl:text>-pattern</xsl:text>
								</a> located in <span class="uri">
									<xsl:value-of select="hks:context/hks:file/@uri"/>
								</span>
							</xsl:when>
							<xsl:when test="hks:context/hks:start"> Referenced from the <span
									class="element">start</span>-element in <span class="uri">
									<xsl:value-of select="hks:context/hks:file/@uri"/>
								</span>
							</xsl:when>
							<xsl:otherwise> Referenced from an unknown context in <span class="uri">
									<xsl:value-of select="hks:context/hks:file/@uri"/>
								</span>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
			</ol>
		</div>
	</xsl:template>
	<xsl:template name="toc">
		<ul class="toc">
			<xsl:apply-templates select="//x:h2 | //x:h3 | //x:h4" mode="toc"/>
		</ul>
	</xsl:template>

	<xsl:template name="createMenu">
		<xsl:param name="activeFile" as="xs:string"/>
		<div id="menu-container">
			<ul id="menu">
				<xsl:for-each select="$menuItems//hks:item">
					<li>
						<xsl:if test="@filename eq $activeFile">
							<xsl:attribute name="id" select="'item-selected'"/>
						</xsl:if>
						<a href="{@filename}">
							<xsl:value-of select="."/>
						</a>
					</li>
				</xsl:for-each>
			</ul>
		</div>
		<p>This profile documentation was automatically generated from the schema files used in this
			profile. Be sure to regenerate the documentation if any of the files in the schema file
			set is being changed. </p>
		<p> Last generated: <xsl:value-of
				select="format-dateTime(current-dateTime(),'[D1o] [MNn] [Y] at [H01]:[m01]')"/>
		</p>
	</xsl:template>

	<!-- VARIOUS FUNCTIONS -->
	<xsl:function name="hks:isAbsoluteURI" as="xs:boolean">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:value-of select="matches($uri,'^(http:|file:).+$','i')"/>
	</xsl:function>

</xsl:stylesheet>
