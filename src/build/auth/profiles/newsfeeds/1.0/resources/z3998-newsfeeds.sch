<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2"><!--generated: 2014-10-21T08:30:28.028-04:00--><!--input file: file:/C:/repos/daisy/z3998/temp/all-src-rng-preprocessed/z3998-newsfeeds.rng--><title>ISO Schematron tests for Newsfeed Aggregator Profile version 1.0</title>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="notes"
            match="default:note"
            use="@xml:id"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="noterefs"
            match="default:noteref"
            use="tokenize(@ref,'\s+')"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="annotations"
            match="default:annotation"
            use="@xml:id"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="annorefs"
            match="default:annoref"
            use="tokenize(@ref,'\s+')"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="descriptions"
            match="default:description"
            use="@xml:id|@sel:selid"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="descrefs"
            match="default:*[@desc]"
            use="tokenize(@desc,'\s+')"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="rdfprefix"
            match="default:document"
            use="tokenize(replace(@prefix,': +[^ ]+ *', ':'), ':')"/>
   <xsl:key xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="rdfprofile"
            match="default:document"
            use="document(//default:meta[@rel='z3998:rdfa-context']/@resource)//*[@property='rdfa:prefix']/text()"/>
   <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
   <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
   <ns uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#" prefix="rdf"/>
   <ns uri="http://purl.org/dc/terms/" prefix="dcterms"/>
   <ns uri="http://www.w3.org/2000/01/rdf-schema#" prefix="rdfs"/>
   <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
   <ns uri="http://www.daisy.org/ns/z3998/annotations/#" prefix="z"/>
   <ns uri="http://www.w3.org/2001/10/synthesis" prefix="ssml"/>
   <ns uri="http://relaxng.org/ns/compatibility/annotations/1.0" prefix="a"/>
   <ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
   <ns uri="http://docbook.org/ns/docbook" prefix="db"/>
   <ns prefix="default" uri="http://www.daisy.org/ns/z3998/authoring/"/>
   <ns prefix="sel" uri="http://www.daisy.org/ns/z3998/authoring/features/select/"/>
   <ns prefix="its" uri="http://www.w3.org/2005/11/its"/>
   <ns prefix="m" uri="http://www.w3.org/1998/Math/MathML"/>
   <ns prefix="d" uri="http://www.daisy.org/ns/z3998/authoring/features/description/"/>
   <pattern id="id-unique">
      <let name="id-set" value="//*[@xml:id]"/>
      <rule context="*[@xml:id]">
         <assert test="count($id-set[@xml:id = current()/@xml:id]) = 1">Duplicate ID '<sch:value-of select="current()/@xml:id"/>'</assert>
      </rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@about and starts-with(@about,'#')]">
         <sch:assert test="exists(//*[@xml:id eq substring-after(current()/@about,'#')])">The fragment URI in the about attribute must resolve to an ID in the document.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@associate]">
         <sch:assert test="child::*[@xml:id = current()/@associate]">The IDREF in the associate attribute must reference the ID of a child element.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@continuation]">
         <sch:assert test="every $id in tokenize(@continuation, '\s+') satisfies count(index-of(tokenize(@continuation, '\s+'), $id)) = 1">The continuation attribute must not reference the same ID multiple times.</sch:assert>
         <sch:assert test="every $id in tokenize(@continuation, '\s+') satisfies current() &lt;&lt; //*[@xml:id eq $id]">Elements referenced by a continuation attribute must be located after the referencing element (i.e., in document order).</sch:assert>
         <sch:assert test="every $id in tokenize(@continuation, '\s+') satisfies name(//*[@xml:id eq $id]) eq name(current())">Elements referenced by a continuation attribute must have the same QName as the referencing element.</sch:assert>
         <sch:assert test="every $id in tokenize(@continuation, '\s+') satisfies not(current() is //*[@xml:id eq $id])">Elements carrying a continuation attribute must not reference themselves.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@datatype]">
         <sch:assert test="every $prefix in substring-before(@datatype, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')">The datatype attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@property]">
         <sch:assert test="every $curie in tokenize(@property, '\s+') satisfies ( (every $prefix in substring-before($curie, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')))">The property attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@ref][namespace-uri()='http://www.daisy.org/ns/z3998/authoring/']">
         <sch:assert test="every $id in tokenize(@ref, '\s+') satisfies count(index-of(tokenize(@ref, '\s+'), $id)) = 1">The ref attribute must not reference the same ID multiple times.</sch:assert>
         <sch:assert test="every $id in tokenize(@ref, '\s+') satisfies //*[@xml:id = $id]">Each IDREF in the ref attribute must reference the ID of another element in the document.</sch:assert>
         <sch:assert test="every $id in tokenize(@ref, '\s+') satisfies not(current() is //*[@xml:id eq $id])">Elements carrying a ref attribute must not reference themselves.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@rel]">
         <sch:assert test="every $curie in tokenize(@rel, '\s+') satisfies ( (every $prefix in substring-before($curie, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')))">The rel attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@rev]">
         <sch:assert test="every $curie in tokenize(@rev, '\s+') satisfies ( (every $prefix in substring-before($curie, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')))">The rev attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@role]">
         <sch:assert test="every $curie in tokenize(@role, '\s+') satisfies ( (every $prefix in substring-before($curie, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')))">The role attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="*[@typeof]">
         <sch:assert test="every $curie in tokenize(@typeof, '\s+') satisfies ( (every $prefix in substring-before($curie, ':') satisfies (key('rdfprefix', $prefix) or key('rdfprofile', $prefix) or $prefix='')))">The typeof attribute contains an undeclared CURIE prefix.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="d:about">
         <sch:assert test="normalize-space(.) or *">The about element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="d:braille">
         <sch:assert test="normalize-space(.) or *">The braille element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="d:longdesc">
         <sch:assert test="normalize-space(.) or *">The longdesc element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="d:simplifiedLanguageDescription">
         <sch:assert test="normalize-space(.) or *">The simplifiedLanguageDescription element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="d:summary">
         <sch:assert test="normalize-space(.) or *">The summary element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:*[@desc]">
         <sch:assert test="every $descref in tokenize(current()/@desc,'\s+') satisfies key('descriptions', $descref)">Every IDREF in the desc attribute must resolve to a description element.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:*[@headers]">
         <sch:assert test="every $idref in tokenize(current()/@headers,'\s+') satisfies ancestor::default:table[not(descendant::default:table)]//default:th[@xml:id=$idref]">The headers attribute must resolve to a th in the current table.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:abbr">
         <sch:assert test="normalize-space(.) or *">The abbr element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:abbr[@ref]">
         <sch:assert test="some $exp in (//default:expansion, //default:name, //default:definition) satisfies current()/@ref eq $exp/@xml:id">The ref attribute on an abbr element must resolve to an expansion, name or definition element.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:address">
         <sch:assert test="normalize-space(.) or *">The address element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:annoref">
         <sch:report test="@value and (count(*|text()[normalize-space()]) &gt; 0)">The value attribute cannot be used on a non-empty annoref.</sch:report>
         <sch:report test="not(@value) and (count(*|text()[normalize-space()]) = 0)">An empty annoref element must include a value attribute.</sch:report>
         <sch:assert test="every $ref in tokenize(current()/@ref, ' +') satisfies key('annotations', $ref)">The IDREF(s) in the ref attribute must resolve to annotations.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:annotation[not(@role='temporary')]">
         <sch:assert test="key('annorefs', @xml:id) or id(current()/@ref)">The annotation element must be referenced by an annoref or reference another element in the document unless it has the role value temporary.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The annotation element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:block">
         <sch:assert test="normalize-space(.) or *">The block element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:byline">
         <sch:assert test="normalize-space(.) or *">The byline element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:caption">
         <sch:assert test="not(child::default:caption)">The caption element must not contain child caption elements.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The caption element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:citation">
         <sch:assert test="normalize-space(.) or *">The citation element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:citation//default:ref[@ref]">
         <sch:assert test="some $entry in //default:bibliography/default:entry satisfies current()/@ref eq $entry/@xml:id ">The ref attribute on the ref element must refer to an entry in a bibliography when nested inside a citation element.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:code">
         <sch:assert test="normalize-space(.) or *">The code element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:dateline">
         <sch:assert test="normalize-space(.) or *">The dateline element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:definition">
         <sch:assert test="normalize-space(.) or *">The definition element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:description">
         <sch:assert test="(normalize-space(.) or *) or @xlink:href">The description element must either contain text data or point to an external resource using the xlink:href attribute.</sch:assert>
         <sch:report test="(normalize-space(.) or *) and @xlink:href">The description element must not contain text data and also point to an external resource using the xlink:href attribute.</sch:report>
         <sch:report test="descendant::default:description">The description element must not contain descendant description elements.</sch:report>
         <sch:report test="descendant::default:object">The description element must not contain descendant object elements.</sch:report>
         <sch:report test="descendant::default:table">The description element must not contain descendant table elements.</sch:report>
         <sch:report test="descendant::*[namespace-uri(.) = 'http://www.w3.org/1998/Math/MathML']">The description element must not contain descendant elements from the MathML feature grammar.</sch:report>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:description[not(parent::default:object)]">
         <sch:assert test="key('descrefs', current()/@xml:id) or key('descrefs', current()/@sel:selid)">Every description element must be referenced by at least one element in the document.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:emph">
         <sch:assert test="normalize-space(.) or *">The emph element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:expansion">
         <sch:assert test="not(descendant::default:expansion)">The expansion element must not contain descendant expansion elements.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The expansion element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:h">
         <sch:assert test="normalize-space(.) or *">The h element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:hd">
         <sch:assert test="normalize-space(.) or *">The hd element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:head[parent::default:document]">
         <sch:assert test="descendant::default:meta[@rel='z3998:profile']">The head element must include a meta element identifying the Z39.98-AI profile the document conforms to (z3998:profile).</sch:assert>
         <sch:assert test="count(descendant::default:meta[@rel='z3998:profile'])">The document must not include more than one meta element identifying a Z39.98-AI profile.</sch:assert>
         <sch:assert test="descendant::default:meta[@rel='z3998:profile']/default:meta[@property='z3998:name'][not(normalize-space(@content)='')]                                                     or default:meta[@about = //descendant::default:meta[@rel='z3998:profile']/@resource][@property='z3998:name'][not(normalize-space(@content)='')]">A meta element containing the profile name must be specified (z3998:name).</sch:assert>
         <sch:assert test="descendant::default:meta[@rel='z3998:profile']/default:meta[@property='z3998:version'][not(normalize-space(@content)='')]                                                     or default:meta[@about = //descendant::default:meta[@rel='z3998:profile']/@resource][@property='z3998:version'][not(normalize-space(@content)='')]">A meta element containing the profile version must be specified (z3998:version).</sch:assert>
         <sch:assert test="every $feature in descendant::default:meta[@rel='z3998:feature']/@resource satisfies                                                      //default:meta[(@about = $feature) or parent::default:meta[@rel='z3998:feature'][@resource=$feature]][@property='z3998:name'][not(normalize-space(@content)='')]">Every feature must have its name specified (z3998:name).</sch:assert>
         <sch:assert test="every $feature in descendant::default:meta[@rel='z3998:feature']/@resource satisfies                                                      //default:meta[(@about = $feature) or parent::default:meta[@rel='z3998:feature'][@resource=$feature]][@property='z3998:version'][not(normalize-space(@content)='')]">Every feature must have its version specified (z3998:version).</sch:assert>
         <sch:assert test="descendant::default:meta[@property='dc:identifier']">The head element must include a meta element with a unique identifier (dc:identifier).</sch:assert>
         <sch:assert test="descendant::default:meta[@property='dc:publisher']">The head element must include a meta element identifying the document publisher (dc:publisher).</sch:assert>
         <sch:assert test="descendant::default:meta[@property='dc:date']">The head element must include a meta element indicating the document modification date (dc:date).</sch:assert>
         <sch:assert test="count(descendant::default:meta[@property='dc:date'])=1">The head element must include only a single dc:date property.</sch:assert>
         <sch:assert test="matches(descendant::default:meta[@property='dc:date']/@content, '[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T([0-1][0-9]|2[0-3])(:([0-5][0-9])){2}Z')">The dc:date property must be of the form CCYY-MM-DDThh:mm:ssZ.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:hpart">
         <sch:assert test="normalize-space(.) or *">The hpart element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:item">
         <sch:assert test="normalize-space(.) or *">The item element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:ln">
         <sch:assert test="not(descendant::default:ln)">The ln element must not contain descendant ln elements.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The ln element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:lnum">
         <sch:assert test="normalize-space(.) or *">The lnum element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:meta[@content]">
         <sch:assert test="string-length(normalize-space(@content)) &gt; 0">The meta content attribute must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:meta[@property='positionSequence']">
         <sch:assert test="matches(@content, '^\d+(\.\d+)*$')">The positionSequence property value must be a decimal-delimited series of integers when specified.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:meta[@property='revision']">
         <sch:assert test="matches(@content, '^\d+(\.\d+)*$')">The revision property value must be a decimal-delimited series of integers when specified.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:name">
         <sch:assert test="normalize-space(.) or *">The name element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:num">
         <sch:assert test="normalize-space(.) or *">The num element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:object">
         <sch:report test="descendant::*[namespace-uri(.) = 'http://www.w3.org/1998/Math/MathML']">The object element must not contain descendant elements from the MathML feature grammar.</sch:report>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:object">
         <sch:report test="count(descendant::default:description) &gt; 1">The object element may contain only one child description.</sch:report>
         <sch:report test="not(child::default:description) and descendant::default:description">description elements cannot be nested inside the children of an object element.</sch:report>
         <sch:report test="child::default:description and count(child::node()[normalize-space(.)]) &gt; 1">A single description element must be the only child of an object element when used.</sch:report>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:p">
         <sch:assert test="normalize-space(.) or *">The p element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:quote">
         <sch:assert test="normalize-space(.) or *">The quote element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:ref">
         <sch:report test="descendant::default:ref">The ref element must not contain descendant ref elements.</sch:report>
         <sch:assert test="normalize-space(.) or *">The ref element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:s">
         <sch:assert test="not(descendant::default:s)">The s element must not contain descendant s elements.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The s element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:span">
         <sch:assert test="normalize-space(.) or *">The span element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:sub">
         <sch:assert test="normalize-space(.) or *">The sub element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:sup">
         <sch:assert test="normalize-space(.) or *">The sup element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:term">
         <sch:assert test="normalize-space(.) or *">The term element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:term[@ref]">
         <sch:assert test="some $def in //default:definition satisfies current()/@ref eq $def/@xml:id">The ref attribute on a term element must resolve to a definition.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:time">
         <sch:assert test="not(descendant::default:time)">The time element must not contain descendant time elements.</sch:assert>
         <sch:assert test="normalize-space(.) or *">The time element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:w">
         <sch:assert test="normalize-space(.) or *">The word element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:wpart">
         <sch:assert test="normalize-space(.) or *">The wpart element must neither be empty nor contain only whitespace.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="its:rb">
         <sch:assert test="not(descendant::its:ruby)">The its:rb element must not contain its:ruby descendants.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="its:rt">
         <sch:assert test="not(descendant::its:ruby)">The its:rt element must not contain its:ruby descendants.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="its:rt[@rbspan]">
         <sch:assert test="not(parent::its:ruby)">The rbspan attribute must not be used on the its:rt element in simple ruby markup.</sch:assert>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:annoref" role="warning">
         <sch:report role="warning"
                     test="(count(node()[normalize-space()]) = 1) and child::default:sup">Superscripted referents should be included in a value attribute, not as text content.</sch:report>
      </sch:rule>
   </pattern>
   <pattern>
      <sch:rule context="default:annotation[@role='temporary']" role="warning">
         <sch:report test=".">Annotations with a role value of temporary must be removed prior to document finalization.</sch:report>
      </sch:rule>
   </pattern>
</schema>