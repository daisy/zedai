<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:db="http://docbook.org/ns/docbook" 
   xmlns:rng="http://relaxng.org/ns/structure/1.0"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
   xmlns:dcterms="http://purl.org/dc/terms/"
   xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
   xmlns:z="http://www.daisy.org/ns/z3986/annotations/#"
   xmlns:zf="http://www.daisy.org/ns/xslt/functions" 
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
   xmlns:x="http://www.w3.org/1999/xhtml">
   
   <xsl:output method="xml" encoding="utf-8" exclude-result-prefixes="z zf x xs db rng rdf dcterms rdfs db"/>
   
   <!--    
      THIS XSLT IS NOT USED 
      
      A transform that catches 'absdef' processing instructions
      and replaces them with RNG module or element/attribute documentation, 
      based on RDF islands in the modules.
      
      See trunk:src/schema/mod/_template-rdf.rng for syntax used in modules 
      
      TODO list:
      - pick up any inlined schematron assertion strings and append these to content model restrictions in table
      - inheritance description from RDF vocab
   -->

   <!-- base dir to resolve the absdef/@src relative URIs to -->
   <xsl:param name="schema-base-dir" required="yes"/>
   
   <!-- identifier string, used in the module RDF -->
   <xsl:param name="z3986-ai-canonical-uri" required="yes"/>
   
   <!-- base path for refs to canonical module locations -->
   <xsl:param name="module-www-basepath" required="yes"/>
      
   <xsl:template match="processing-instruction('absdef')" priority="2">
      
      <!-- the value of the absdef src pseudoattribute -->
      <xsl:variable name="module-rel-path" select="replace(replace(replace(.,'src=',''),'&#34;',''),' ','')"/>      
      <xsl:message>Expanding absdef for <xsl:value-of select="$module-rel-path"/></xsl:message>
      
      <!-- concat of inparam base dir and absdef src pseudoattribute -->
      <xsl:variable name="module-full-path" select="concat($schema-base-dir,$module-rel-path)" />      
      <xsl:if test="not(doc-available($module-full-path))">
         <xsl:message terminate="yes">Module not available: 
            <xsl:value-of select="$module-full-path"/></xsl:message>
      </xsl:if>
      
      <!-- load the module as a variable -->
      <xsl:variable name="module-doc" select="doc($module-full-path)" as="document-node()"/>

      <!-- the top-level rfd:Description (which is for the module) -->
      <xsl:variable name="module-rdf-description"
         select="$module-doc/rng:grammar/rdf:RDF/rdf:Description" as="element()"/>
           
      <!-- rfd:Description elements of actual module contributions (all except the top-level one) -->
      <xsl:variable name="rdf-descriptions"
         select="$module-doc/rng:grammar//rdf:RDF/rdf:Description[not(@rdf:about='')]"
         as="element()*"/>
           
      <db:section xml:id="{$module-doc/rng:grammar/@xml:id}" xreflabel="{$module-rdf-description/dcterms:title}">  
                            
          <xsl:call-template name="render-module-documentation">
             <xsl:with-param name="module-doc" select="$module-doc" />
             <xsl:with-param name="module-rdf-description" select="$module-rdf-description" />
             <xsl:with-param name="module-rel-path" select="$module-rel-path" />
             <xsl:with-param name="module-full-path" select="$module-full-path" />
             <xsl:with-param name="rdf-descriptions" select="$rdf-descriptions" />             
          </xsl:call-template>
         
         <xsl:call-template name="render-contribution-documentation">
            <xsl:with-param name="rdf-descriptions" select="$rdf-descriptions" />
            <xsl:with-param name="module-doc" select="$module-doc" />
            <xsl:with-param name="module-rdf-description" select="$module-rdf-description" />
         </xsl:call-template>   
         
      </db:section>
 
   </xsl:template>

   <xsl:template name="render-contribution-documentation">
      <!-- render documentation using all RDF islands found inside defines -->
      
      <xsl:param name="rdf-descriptions" required="yes"/>
      <xsl:param name="module-doc" required="yes" />
      <xsl:param name="module-rdf-description" required="yes" />
      
      <xsl:for-each select="$rdf-descriptions">
         <!-- loop over all elems, attrs or other defines that this module contributes -->
         <!-- rdf-descriptions is 1..n rdf:Description with an elem, attr, or other define ancestor (the latter for classes/models) -->
         
         <!-- get the ancestor being defined by the rdf:Description -->
         <xsl:variable name="defined" select="//*[@xml:id=replace(current()/@rdf:about,'#','')]"/>            
         <xsl:if test="not(count($defined)=1)">
            <xsl:message terminate="yes">rdf:Description/@rdf:about does not resolve:
               <xsl:value-of select="replace(current()/@rdf:about,'#','')"/></xsl:message>
         </xsl:if>
         
         <db:section>
            <xsl:attribute name="xml:id" select="$defined/@xml:id"/>
            <xsl:attribute name="xreflabel" select="current()/dcterms:title"/>
            <db:title>
               <xsl:value-of select="current()/dcterms:title"/>
            </db:title>
            <db:para role="formal-description">
               <xsl:call-template name="wiki-links-to-db-link">
                  <xsl:with-param name="text" select="current()/dcterms:description/text()"/>
               </xsl:call-template>
            </db:para>
            <xsl:call-template name="render-z-info">
               <xsl:with-param name="parent" select="current()"/>
            </xsl:call-template>
            
            <db:table role="abstract-definition" xml:id="{$defined/@xml:id}-absdef">
               <db:caption><xsl:value-of select="$module-rdf-description/dcterms:title"/>:
                  <xsl:value-of select="current()/dcterms:title"/> Abstract
                  Definition</db:caption>
               
               <xsl:variable name="defineType" as="xs:string" select="zf:get-define-type($defined)"/>
               
               <db:tr xml:id="{$defined/@xml:id}-name">
                  <db:th><xsl:value-of select="$defineType"/> name</db:th>
                  <db:td>
                     <xsl:choose>
                        <xsl:when test="$defineType eq 'element' or $defineType eq 'attribute'">
                           <xsl:choose>
                              <!-- clark notation -->
                              <xsl:when test="$defined/@ns">
                                 <xsl:text>{</xsl:text>
                                 <xsl:value-of select="$defined/@ns"/>
                                 <xsl:text>}</xsl:text>
                              </xsl:when>
                              <xsl:when test="$module-doc/rng:grammar/@ns and $defineType eq 'element'">
                                 <xsl:text>{</xsl:text>
                                 <xsl:value-of select="$module-doc/rng:grammar/@ns"/>
                                 <xsl:text>}</xsl:text>
                              </xsl:when>
                           </xsl:choose>
                           <xsl:value-of select="$defined/@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$defined/@name"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </db:td>
               </db:tr>
               
               <db:tr xml:id="{$defined/@xml:id}-inclusion">
                  <db:th>Inclusion</db:th>
                  <db:td>
                     <xsl:choose>
                        <xsl:when test="current()/dcterms:isRequiredBy[@rdf:resource='']"
                           >Required</xsl:when>
                        <xsl:otherwise>Optional</xsl:otherwise>
                     </xsl:choose>
                  </db:td>
               </db:tr>
               
               <xsl:if test="current()/z:content">
                  <db:tr xml:id="{$defined/@xml:id}-content">
                     <xsl:choose>
                        <xsl:when test="$defineType eq 'element'">
                           <db:th>Default Content Model</db:th>
                        </xsl:when>
                        <xsl:when test="$defineType eq 'attribute'">
                           <db:th>Default Values</db:th>
                        </xsl:when>
                        <xsl:otherwise>
                           <db:th>Default Content</db:th>
                        </xsl:otherwise>
                     </xsl:choose>                                          
                     <db:td>
                        <xsl:choose>
                           <xsl:when test="current()/z:content/text()">
                              <xsl:call-template name="wiki-links-to-db-link">
                                 <xsl:with-param name="text" select="current()/z:content/text()"/>
                              </xsl:call-template>
                           </xsl:when>                           
                           <xsl:otherwise>
                              This <xsl:value-of select="$defineType" /> is empty.
                           </xsl:otherwise>
                        </xsl:choose>                                                
                     </db:td>
                  </db:tr>
               </xsl:if>
               
               <xsl:if test="current()/z:context">
                  <db:tr xml:id="{$defined/@xml:id}-context">
                     <db:th>Default Context</db:th>
                     <db:td>
                        <xsl:call-template name="wiki-links-to-db-link">
                           <xsl:with-param name="text" select="current()/z:context/text()"/>
                        </xsl:call-template>
                     </db:td>
                  </db:tr>
               </xsl:if>
               
               <xsl:if test="current()/z:attlist" xml:id="{$defined/@xml:id}-attlist">
                  <db:tr xml:id="{$defined/@xml:id}-attlist">
                     <db:th>Minimal Attributes</db:th>
                     <db:td>
                        <xsl:call-template name="wiki-links-to-db-link">
                           <xsl:with-param name="text" select="current()/z:attlist/text()"/>
                        </xsl:call-template>
                     </db:td>
                  </db:tr>
               </xsl:if>
            </db:table>
         </db:section>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="render-module-documentation">
      
      <!-- render module documentation using the top-level (module) RDF --> 
      
      <xsl:param name="module-rdf-description" required="yes" />
      <xsl:param name="module-doc" required="yes"  />
      <xsl:param name="module-full-path" required="yes" />
      <xsl:param name="module-rel-path" required="yes"  />
      <xsl:param name="rdf-descriptions" required="yes" />
      
      <db:title>
         <xsl:value-of select="$module-rdf-description/dcterms:title"/>
      </db:title>
      <db:para role="formal-description">
         <xsl:call-template name="wiki-links-to-db-link">
            <xsl:with-param name="text"
               select="$module-rdf-description/dcterms:description/text()"/>
         </xsl:call-template>
      </db:para>
      <xsl:call-template name="render-z-info">
         <xsl:with-param name="parent" select="$module-rdf-description"/>
      </xsl:call-template>
      
      <db:table role="module-overview" xml:id="{$module-doc/rng:grammar/@xml:id}-overview">
         <db:caption><xsl:value-of select="$module-rdf-description/dcterms:title"/>:
            Overview</db:caption>
         
         <db:tr>
            <db:th>Profile inclusion</db:th>
            <db:td>
               <xsl:choose>
                  <xsl:when
                     test="$module-rdf-description/dcterms:isRequiredBy[@rdf:resource=$z3986-ai-canonical-uri]"
                     >Required</xsl:when>
                  <xsl:otherwise>Optional</xsl:otherwise>
               </xsl:choose>
            </db:td>
         </db:tr>
         
         <db:tr>
            <db:th>Contributes</db:th>
            <db:td>
               <xsl:for-each select="$rdf-descriptions">
                  <db:xref linkend="{replace(current()/@rdf:about,'#','')}"/>
                  <xsl:choose>
                     <xsl:when test="position() eq last()"/>
                     <xsl:when test="position() eq last()-1">
                        <xsl:text> and </xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>, </xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </db:td>
         </db:tr>
         
         <db:tr>
            <db:th>Internal dependencies</db:th> <!-- deps for this module to compile -->
            <db:td>
               <xsl:variable name="requires" select="$module-rdf-description/dcterms:requires"
                  as="element()*"/>
               <xsl:call-template name="render-dependencies">
                  <xsl:with-param name="dependencies" select="$requires"/>
                  <xsl:with-param name="module-full-path" select="$module-full-path"/>
               </xsl:call-template>
            </db:td>
         </db:tr>
         
         <db:tr>
            <db:th>External dependencies</db:th> <!-- deps in other modules on this module in order for them to compile -->
            <db:td>
               <xsl:variable name="requires"
                  select="$module-rdf-description/dcterms:isRequiredBy[not(@rdf:resource=$z3986-ai-canonical-uri)]"
                  as="element()*"/>
               <xsl:call-template name="render-dependencies">
                  <xsl:with-param name="dependencies" select="$requires"/>
                  <xsl:with-param name="module-full-path" select="$module-full-path"/>
               </xsl:call-template>
            </db:td>
         </db:tr>
         
         <db:tr>
            <db:th>Implementation</db:th> <!-- link to the shipped schema implementation -->
            <db:td>
               <db:link xlink:href="{concat($module-www-basepath,$module-rel-path)}">
                  <xsl:value-of select="replace($module-full-path,'^(.+)/(.+?)$','$2')"/>
               </db:link>
               <xsl:text> </xsl:text>
               <db:xref linkend="refRelaxNG"/>
            </db:td>
         </db:tr>
      </db:table>
      
   </xsl:template>

   <xsl:function name="zf:get-define-type" as="xs:string">
      <xsl:param name="node" as="element()"/>
      <xsl:choose>
         <xsl:when test="local-name($node) eq 'element'">
            <xsl:value-of>element</xsl:value-of>
         </xsl:when>
         <xsl:when test="local-name($node) eq 'attribute'">
            <xsl:value-of>attribute</xsl:value-of>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of>pattern</xsl:value-of>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:template name="render-dependencies">
      <xsl:param name="dependencies"/>
      <xsl:param name="module-full-path"/>
      <xsl:choose>
         <xsl:when test="count($dependencies)>0">
            <xsl:for-each select="$dependencies">
               <xsl:variable name="other-module-uri"
                  select="resolve-uri(current()/@rdf:resource,$module-full-path)"/>
               <xsl:if test="not(doc-available($other-module-uri))">
                  <xsl:message terminate="yes">Module not available: <xsl:value-of
                        select="$other-module-uri"/></xsl:message>
               </xsl:if>
               <xsl:variable name="other-module-doc" select="doc($other-module-uri)"/>
               <db:xref linkend="{$other-module-doc/rng:grammar/@xml:id}"/>
               <xsl:choose>
                  <xsl:when test="position() eq last()"/>
                  <xsl:when test="position() eq last()-1">
                     <xsl:text> and </xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>, </xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>None</xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="render-z-info">
      <!-- render 0..n z:info elements as docbook paras -->
      <xsl:param name="parent" as="element()"/> <!-- typically an rdf:Description parent -->            
      <xsl:for-each select="$parent/z:info">
         <db:para role="info">
            <xsl:call-template name="wiki-links-to-db-link">
               <xsl:with-param name="text" select="current()/text()"/>
            </xsl:call-template>
         </db:para>
      </xsl:for-each>      
   </xsl:template>

   <xsl:template name="wiki-links-to-db-link">
      <!-- Expand wiki-style links in inparam text node to docbook xref elements -->
      
      <!-- inparam: a text node, possibly containing 1..n '[[link label]]' subsegments, where label is optional -->
      <xsl:param name="text" as="text()"/>
      
      <!-- hack: force each '[[' to appear on its own line to get the friggin regex to work-->
      <xsl:analyze-string select="replace(normalize-space($text),'\[\[','&#xA;[[')" regex="\[{{2}}.+\]{{2}}">
         <xsl:matching-substring>
            <!-- get the string inside the [[...]] delimiters -->
            <xsl:variable name="string" select="normalize-space(replace(replace(.,'\[\[',''),'\]\]',''))"/>
            <!-- try to get the link segment, may fail if given string is [[#fragmenturi]] -->
            <xsl:variable name="link" select="string(substring-before($string,' '))" as="xs:string"/>
            <!-- try to get the label segment, may fail if given string is [[#fragmenturi]]-->
            <xsl:variable name="label" select="string(substring-after($string,' '))" as="xs:string" />
            <!-- if we have an explicit label, use db:link, else db:xref -->
            <xsl:choose>
               <xsl:when test="string-length($label)>0">
                  <xsl:choose>
                     <xsl:when test="starts-with($link,'#')">
                        <db:link linkend="{substring-after($link,'#')}"><xsl:value-of select="$label"/></db:link>
                     </xsl:when>
                     <xsl:otherwise>
                        <db:link xlink:href="{$link}"><xsl:value-of select="$label"/></db:link>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <xsl:when test="starts-with($string,'#')">
                        <db:xref linkend="{substring-after($string,'#')}"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:message terminate="yes">Cant use xref links for non-IDREF link types: <xsl:value-of select="$string" /> </xsl:message>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>

         </xsl:matching-substring>
         <xsl:non-matching-substring>
            <xsl:value-of select="."/>
         </xsl:non-matching-substring>
      </xsl:analyze-string>
   </xsl:template>

   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>

</xsl:stylesheet>
