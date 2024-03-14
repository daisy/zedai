<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns="http://relaxng.org/ns/structure/1.0" 
	xmlns:xsdp="http://www.daisy.org/ns/rng-preprocess/xsd"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="xs">
	
	
	<!--  	
		Preprocessing of RNG files to enable conversion to XSD using trang. 
		
		The following tokens (in namespace http://www.daisy.org/ns/rng-preprocess/xsd)
		are supported in the xsd-gen RNG file:
		
		- @replace : replace the define with an @name matching the specficied @replace value. To differentiate between defines
		                  that specify content models and classes from defines that include components into them, xml:id
		                  attributes must be added to the former. Adding an xml:id to an element or attribute inclusion could
		                  result in multiple inclusions of xsd replacements.
		- @for : inserts the defined content model inclusion after the define named in @for value
	-->
	
	<xsl:param name="replace-mathml-include-with-dummy" select="false" /> <!-- true|false -->
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />	
	
	<!-- xsd replacements/additions -->
	<xsl:variable name="xsd" select="document('../../src/schema/mod/xsd-gen.rng')"/>
	
	<!--   Example: <define name="z3986.section.content" xml:id="z3986.section.content" xsdp:replace="z3986.section.content.xsd">  -->
	<xsl:template match="define[@xml:id][$xsd//define[@xsdp:replace=current()/@name]]">
		
		<xsl:variable name="xsdElement" select="$xsd//define[@xsdp:replace=current()/@name]"/>
		
		<xsl:element name="define">
			<xsl:attribute name="name">
				<xsl:value-of select="@name" />
			</xsl:attribute>
			<xsl:variable name="target" select="$xsdElement/@name" />	    
			<xsl:comment>xsdp: replacing define <xsl:value-of 
				select="./@name"/> with define <xsl:value-of 
					select="$target"/></xsl:comment>	    	    	      
			<xsl:apply-templates select="$xsdElement/*"/>
		</xsl:element>
		
		<!-- and add the define for downstream processing -->
		<xsl:copy-of select="$xsdElement"/>
		
		<!-- add any inclusions if an element is defined -->
		<xsl:if test="$xsdElement/element">
			<xsl:call-template name="add-includes">
				<xsl:with-param name="for" select="@name"/>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="add-includes">
		<xsl:param name="for"/>
		<xsl:for-each select="$xsd//define[@xsdp:for=$for]">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>
	
	<!-- replace the mathml include in driver if inparam set to true -->
	<xsl:template match="include[@href='./mod/z3986-feature-mathml.rng']">
		<xsl:choose>
			<xsl:when test="$replace-mathml-include-with-dummy eq 'true'">		
				<xsl:comment>The below three dummy math defines inserted by rng-xsd-preprocess.xsl 
					because the param replace-mathml-include-with-dummy was set to true</xsl:comment>				
				<define name="math">
					<element name="math" ns="http://www.w3.org/1998/Math/MathML">
						<empty/>
					</element>						
				</define>					
				<define name="z3986.Phrase.contrib.class" combine="choice">
					<ref name="math"/>
				</define>				
				<define name="z3986.Block.contrib.class" combine="choice">
					<ref name="math"/>
				</define>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
		
		<!-- add any xsd inclusions for the defined element -->
		<xsl:if test="self::define and child::element">
			<xsl:call-template name="add-includes">
				<xsl:with-param name="for" select="@name"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>