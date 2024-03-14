<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://purl.oclc.org/dsdl/nvdl/ns/structure/1.0"
	exclude-result-prefixes="xs">
	
	<xsl:param name="profile" required="yes"/>
	
	<xsl:output encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
	
	<xsl:template match="/">
		
<rules startMode="document">
	
	<mode name="document">
		<namespace ns="http://www.daisy.org/ns/z3998/authoring/">
			<validate schema="z3998-{$profile}-single.rng" useMode="addNS"/>
			<validate schema="z3998-{$profile}.sch" useMode="addNS"/>
		</namespace>
	</mode>
	
	<mode name="addNS">
		<anyNamespace>
			<attach/>
		</anyNamespace>
	</mode>

</rules>
		
	</xsl:template>
	
</xsl:stylesheet>