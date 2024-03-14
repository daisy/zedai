<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="xs x">

	<xsl:param name="excludeList" as="xs:string" select="''" />

	<!-- Create a sequence of strings from the parameter -->
	<xsl:variable name="xList" as="xs:string*" select="tokenize(normalize-space($excludeList),' ')" />

	<!-- Get all the elements representing features to exclude -->
	<xsl:variable name="xFeatures" as="element()*"
		select="//*[some $id in $xList satisfies @x:id eq $id]" />

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="grammar/x:h1[1]">
		<!-- Prepend the original top heading -->
		<x:h1>
			<xsl:text>The Feature Reduced Version of </xsl:text>
			<xsl:apply-templates />
		</x:h1>
		<!-- and then list the excluded features -->
		<x:p>
			<xsl:text>This version of the driver does not offer the following features:</xsl:text>
			<x:ul>
				<xsl:for-each select="$xFeatures">

					<x:li>
						<xsl:value-of select="descendant::x:*[matches(local-name(.),'^h[1-6]$')][1]"
						 />
					</x:li>

				</xsl:for-each>
			</x:ul>
		</x:p>

	</xsl:template>

	<xsl:template match="*[some $id in $xList satisfies @x:id eq $id]">
		<!-- Only output a message and a comment for elements with an x:id equal to one of the ID's on the list  -->
		<!-- <xsl:message>
			<xsl:text>Excluded from driver: </xsl:text>
			<xsl:if test="x:h2">
				<xsl:value-of select="x:h2[1]" />
			</xsl:if>
			<xsl:value-of select="concat(' (',@x:id,')')" />
		</xsl:message>-->

		<xsl:if test="x:h2">
			<xsl:comment>The <xsl:value-of select="x:h2[1]" /> is not included in this version of
				the driver</xsl:comment>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
