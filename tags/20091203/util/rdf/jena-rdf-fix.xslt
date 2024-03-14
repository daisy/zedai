<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xpath-default-namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

 	<!-- tweak the RDF output from Jena -->

	<!-- the uri of the vocab being fixed -->
	<xsl:param name="vocab-uri" required="yes" />

  	<xsl:output method="xml" version="1.0" encoding="UTF-8" 
  		omit-xml-declaration="no" indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates>
			<!-- TODO sort using some key -->
			<xsl:sort select="rdfs:subPropertyOf"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="rdf:Description">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*" />
			<!-- de-expand the full URIs to self -->
			<xsl:variable name="about" select="./@rdf:about" />
			<xsl:if test="starts-with($about, $vocab-uri)">
				<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<xsl:text>#</xsl:text><xsl:value-of select="substring-after($about, '#')" />
				</xsl:attribute>
			</xsl:if>	
			<!-- add an rdf:ID -->
			<xsl:if test="./rdfs:label">
				<xsl:attribute name="ID" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">				
					<xsl:value-of select="./rdfs:label" />				
				</xsl:attribute>
			</xsl:if>	
			<xsl:apply-templates />
		</xsl:element>		
	</xsl:template>

	<xsl:template match="*[@rdf:resource]">		
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*" />
			<xsl:variable name="resource" select="@rdf:resource" />
			<xsl:if test="starts-with($resource, $vocab-uri)">
				<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<xsl:text>#</xsl:text><xsl:value-of select="substring-after($resource, '#')" />
				</xsl:attribute>
			</xsl:if>	
			<xsl:apply-templates />
		</xsl:element>	
	</xsl:template>

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>