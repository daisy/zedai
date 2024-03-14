<xsl:stylesheet version="2.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:zf="http://www.daisy.org/ns/xslt/functions"
  exclude-result-prefixes="zf" >

  <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="no" indent="yes" />
  
  <xsl:include href="../xsl/wiki-link-handler.xsl"/>
  
  <!-- the canonical URI of the vocab being rendered -->
  <xsl:param name="vocab-uri" required="yes"/>	

  <!-- a relative link to this vocab in Notation3 syntax -->
  <xsl:param name="vocab-as-n3" required="no"/>

  <!-- a relative link to this vocab in RDF/XML syntax -->
  <xsl:param name="vocab-as-rdfxml" required="no"/>
		
  <!-- the rdf:Description that describes the vocab being rendered -->	
  <xsl:variable name="vocab-rdf-description" as="element()" select="//rdf:Description[@rdf:about=$vocab-uri]|//rdf:Description[@rdf:about='']|//rdf:Description[@rdf:about='.']" />
  
  <xsl:template match="rdf:RDF">
  	<html version="XHTML+RDFa 1.0">
  		<head>
  			<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>  			
  			<xsl:for-each select="$vocab-rdf-description/*">
  				<xsl:choose>
  					<xsl:when test="name(.) eq 'dcterms:title'">
  						<title><xsl:value-of select="."/></title>
  					</xsl:when>
  					<xsl:when test="name(.) eq 'dcterms:description'" />
  					<xsl:otherwise>
  						<meta property="{name(.)}" content="{.}"/>  
  					</xsl:otherwise>	
  				</xsl:choose>  				  								
  			</xsl:for-each>
  			<link rel="stylesheet" type="text/css" href="../../z3986-2011.css"/>
  		</head>
  		<body>
  			<h1 property="dcterms:title"><xsl:call-template name="wiki-links-to-xhtml">
  				<xsl:with-param name="text" select="$vocab-rdf-description/dcterms:title/text()"/>
  			</xsl:call-template></h1>
  			
  			<div>
	  			<h2>About this vocabulary</h2>
	  			<xsl:if test="$vocab-rdf-description/dcterms:description">
	  				<div property="dcterms:description">
		  				<xsl:for-each select="$vocab-rdf-description/dcterms:description">
		  					<p><xsl:call-template name="wiki-links-to-xhtml">
		  						<xsl:with-param name="text" select="./text()"/>
		  					</xsl:call-template></p>
		  				</xsl:for-each>
	  				</div>	
	  			</xsl:if>
	  			<p id="vocab-forms">You are currently reading the normative <a href="http://www.w3.org/TR/rdfa-syntax/"
	  					>W3C XHTML+RDFa</a> expression of this vocabulary. <xsl:choose>
	  				<xsl:when test="$vocab-as-n3 and not($vocab-as-rdfxml)"
	  					>It is also <a href="{$vocab-as-n3}">available in an informative Notation3 syntax version</a></xsl:when>
	  				<xsl:when test="$vocab-as-rdfxml and not($vocab-as-n3)"
	  					>It is also <a href="{$vocab-as-rdfxml}">available in an informative RDF/XML syntax versions</a></xsl:when>
	  				<xsl:otherwise>It is also available in informative <a href="{$vocab-as-n3}"
	  					>Notation3</a> and <a href="{$vocab-as-rdfxml}">RDF/XML</a> syntax versions</xsl:otherwise>
	  					</xsl:choose>.</p> 	
  				
  				<p class="vocab-date">Document last updated: <xsl:value-of select="//rdf:Description[@rdf:about=$vocab-uri]/dcterms:date"/></p>
  			</div>
  			
  			<div id="vocab" class="vocabulary">
  				<xsl:apply-templates />
  			</div>	
  		</body>	
  	</html>	
  </xsl:template>
	
  <xsl:template match="rdf:Bag">
  	<xsl:variable name="id" select="./@rdf:ID"/>
  	<div id="{$id}" about="#{$id}" typeof="rdf:Bag">
  		<xsl:element name="{zf:get-heading-for-bag(.)}">
  			<xsl:attribute name="id">h_<xsl:value-of select="$id"/></xsl:attribute>
  			<xsl:attribute name="about">#<xsl:value-of select="$id"/></xsl:attribute>
  			<xsl:attribute name="rev">dcterms:title</xsl:attribute> 
  			<xsl:call-template name="wiki-links-to-xhtml">
  				<xsl:with-param name="text" select="./dcterms:title/text()"/>
  			</xsl:call-template>
  		</xsl:element>	
  		<xsl:if test="./dcterms:description">
  			<xsl:for-each select="./dcterms:description">
  				<p about="#{$id}" rev="dcterms:description"><xsl:call-template name="wiki-links-to-xhtml">
  					<xsl:with-param name="text" select="./text()"/>
  				</xsl:call-template></p>
  			</xsl:for-each>
  		</xsl:if>	
  		<dl about="#{$id}" rev="rdfs:member">
  			<xsl:apply-templates />
  		</dl>	
  	</div>	
  </xsl:template>	
  
	<xsl:template match="rdf:Bag/rdf:Description">	
		<xsl:variable name="about" select="@rdf:ID"/>
		<dt id="{$about}" about="#{$about}" typeof="{zf:get-type(rdf:type/@rdf:resource)}"><xsl:value-of select="rdfs:label"/></dt>
		<!-- create a datatype variable -->
		<xsl:variable name="datatype">
			<xsl:choose>
				<!-- <rdfs:datatype rdf:resource="http://www.w3.org/2001/XMLSchema#integer"/> -->
				<xsl:when test="rdfs:datatype"><xsl:value-of select="replace(rdfs:datatype/@rdf:resource,'http://www.w3.org/2001/XMLSchema#','xsd:')"/></xsl:when>
				<xsl:otherwise>xsd:string</xsl:otherwise>
			</xsl:choose>							
		</xsl:variable>
		
		<!-- first a generic loop -->
		<xsl:for-each select="./*[not(matches(name(.),'rdfs:label|rdf:type|rdfs:subPropertyOf|rdfs:subClassOf|rdfs:seeAlso|owl:sameAs|owl:equivalentProperty|rdfs:datatype'))]">
			<dd about="#{$about}" property="{name(.)}" datatype="{$datatype}">
				<p><xsl:call-template name="wiki-links-to-xhtml">
					<xsl:with-param name="text" select="./text()"/>
				</xsl:call-template>
				<xsl:if test="@rdf:resource"><xsl:text> </xsl:text>
					<a href="@rdf:resource"><xsl:value-of select="@rdf:resource"/></a>
				</xsl:if></p>
				<xsl:if test="not(matches($datatype, 'xsd:string'))">
					<p>Datatype: <code><xsl:value-of select="$datatype"/></code>.</p>
				</xsl:if>	
			</dd>
		</xsl:for-each>
		<!-- then get the non-generic stuff with specialized rendering -->
		<xsl:if test="rdfs:subPropertyOf|rdfs:subClassOf">
			<xsl:call-template name="render-sub-dl">
				<xsl:with-param name="label">Inherits from:</xsl:with-param>
				<xsl:with-param name="about" select="$about"/>
				<xsl:with-param name="members" select="rdfs:subPropertyOf|rdfs:subClassOf"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="rdfs:seeAlso">
			<xsl:call-template name="render-sub-dl">
				<xsl:with-param name="label">See also:</xsl:with-param>
				<xsl:with-param name="about" select="$about"/>
				<xsl:with-param name="members" select="rdfs:seeAlso"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="owl:sameAs">
			<xsl:call-template name="render-sub-dl">
				<xsl:with-param name="label">Same as:</xsl:with-param>
				<xsl:with-param name="about" select="$about"/>
				<xsl:with-param name="members" select="owl:sameAs"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="owl:equivalentProperty">
			<xsl:call-template name="render-sub-dl">
				<xsl:with-param name="label">Equivalent to:</xsl:with-param>
				<xsl:with-param name="about" select="$about"/>
				<xsl:with-param name="members" select="owl:equivalentProperty"/>
			</xsl:call-template>
		</xsl:if>
  </xsl:template>

 <xsl:template name="render-sub-dl">
 	<xsl:param name="label" as="xsd:string" />
 	<xsl:param name="members" as="element()*"/>
 	<xsl:param name="about" as="xsd:string"/> 	
 	<dd>
 		<dl>
 			<dt><xsl:value-of select="$label"/></dt>
 			<xsl:for-each select="$members">
 				<xsl:choose> 					
	 				<xsl:when test="@rdf:resource">	 				
		 				<dd about="#{$about}" rel="{name(.)}" resource="{@rdf:resource}">
		 					<a href="{@rdf:resource}">
		 						<xsl:value-of select="zf:get-link-label(@rdf:resource,ancestor::rdf:RDF)"/>
		 					</a>
		 				</dd>	
	 				</xsl:when>
	 				<xsl:otherwise>
	 					<dd about="#{$about}" rel="{name(.)}">	 						
	 						<xsl:call-template name="wiki-links-to-xhtml">
	 							<xsl:with-param name="text" select="./text()"/>
	 						</xsl:call-template>	 						
	 					</dd>	
	 				</xsl:otherwise>
	 			</xsl:choose>
 			</xsl:for-each>
 		</dl>	
 	</dd>
 </xsl:template>
	
  <xsl:function name="zf:get-link-label">  	
  	<xsl:param name="uri" as="xsd:string" />
  	<xsl:param name="root" as="element()" />  	
  	<xsl:choose>
  		<xsl:when test="starts-with($uri,'#') or starts-with($uri,$vocab-uri)">
  			<!-- local link -->
  			<xsl:variable name="target" select="substring-after($uri,'#')" />
  			<xsl:variable name="dest" select="$root//rdf:Description[@rdf:ID=$target]/rdfs:label" />
  			<xsl:if test="not($dest) or $dest eq ''">
  				<xsl:message>WARNING: Could not resolve destination <xsl:value-of select="$target"/></xsl:message>
  				<xsl:value-of select="$target"/>
  			</xsl:if>
  			<xsl:call-template name="wiki-links-to-xhtml">  				
  				<xsl:with-param name="text" select="$dest/text()"/>
  			</xsl:call-template>  			
  		</xsl:when>
  		<xsl:otherwise>
  			<!-- external link -->
  			<xsl:value-of select="$uri"/>
  		</xsl:otherwise>  		
  	</xsl:choose>  	  	
  </xsl:function>	
  
  <xsl:function name="zf:get-type"> 
  	<xsl:param name="uri" as="xsd:string" />
  	<xsl:choose>
  		<xsl:when test="$uri eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#Property'">
  			<xsl:value-of>rdf:Property</xsl:value-of>
  		</xsl:when>
  		<xsl:when test="$uri eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#class'">
  			<xsl:value-of>rdf:class</xsl:value-of>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:message>WARNING: unknown URI in zf:get-type: <xsl:value-of select="$uri" /></xsl:message>
  		</xsl:otherwise>
  	</xsl:choose>  	  	
  </xsl:function>	
	
	<xsl:function name="zf:get-heading-for-bag"> 
		<xsl:param name="bag" as="element()" />
		<xsl:variable name="ancestors" select="count($bag/ancestor::*)" as="xsd:integer"/>
		<xsl:value-of select="concat('h',string($ancestors+1))" />			
	</xsl:function>	
	
  <xsl:template match="*" />
	
</xsl:stylesheet>