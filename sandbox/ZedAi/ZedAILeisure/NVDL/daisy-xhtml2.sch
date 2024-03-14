<?xml version="1.0" encoding="utf-8"?>
<!-- oNVDL support for ISO Schematron is not in the downloadable release, TODO await release from code.google.com/p/jing-trang -->
<schema xmlns="http://www.ascc.net/xml/schematron" > 
  <ns prefix="xht" uri="http://www.w3.org/2002/06/xhtml2/" />
  <pattern name="h.count">
    <rule context="xht:section">
      <assert test="count(xht:h) = 1"
                 >There must be exactly One h element per section</assert>
    </rule>
  </pattern>

<!--
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
	schemaVersion="ISO19757-3">
  <title>ISO schematron additional constraints on the XHTML2 canonical RNG</title>

  <ns prefix="xht" uri="http://www.w3.org/2002/06/xhtml2/" />

  <pattern id="h.count">
    <title>Checking constraints on the xhtml section element</title>
    <rule context="xht:section">
      <assert test="count(xht:h) = 1"
                 >There must be exactly One h element per section</assert>
    </rule>
  </pattern>

</schema>
-->
</schema>


