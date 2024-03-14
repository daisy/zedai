<?xml version="1.0" encoding="UTF-8"?>
<!-- toc.xsl generate the TOC and the links from TOC items to headings -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!-- add the xhtml+rdfa doctype decl and root version -->

	<xsl:output doctype-public="-//W3C//DTD XHTML+RDFa 1.0//EN" 
		doctype-system="http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd" 
		indent="yes" method="xml" >

	<xsl:template match="html">
		<xsl:attribute name="version">XHTML+RDFa 1.0</xsl:attribute>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
