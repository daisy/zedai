<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://relaxng.org/ns/structure/1.0"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:x="http://www.w3.org/1999/xhtml">
    
    <xsl:output indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
     
    <xsl:template match="rng:grammar">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="child::db:info"/>
            <div>
                <!-- required includes for standalone parsing -->
                <x:h3>Content Model Definitions</x:h3>
                <include href="./z3986-global-classes.rng" />
                
                <x:h3>Common Elements</x:h3>
                
                <include href="./z3986-document.rng">
                    <start combine="choice">
                        <notAllowed/>
                    </start>
                </include>
                <include href="./z3986-meta.rng"/>
                <include href="./z3986-linking.rng"/>    
                
                <include href="./z3986-section.rng"/>
                <include href="./z3986-headings.rng"/>
                <include href="./z3986-block.rng"/>
                <include href="./z3986-p.rng"/>
                <include href="./z3986-list.rng"/>
                <include href="./z3986-table.rng"/>  
                
                <include href="./z3986-code.rng"/>    
                <include href="./z3986-quote.rng"/>
                <include href="./z3986-citation.rng"/>
                <include href="./z3986-object.rng"/>
                
                <include href="./z3986-note.rng"/>
                <include href="./z3986-annotation.rng"/>
                <include href="./z3986-aside.rng"/>  
                <include href="./z3986-caption.rng"/>
                <include href="./z3986-verse.rng"/>  
                <include href="./z3986-description.rng"/>
                
                <include href="./z3986-span.rng"/>  
                <include href="./z3986-line.rng"/>    
                <include href="./z3986-pagebreak.rng"/>
                <include href="./z3986-s.rng"/>
                <include href="./z3986-w.rng"/>
                
                <include href="./z3986-abbr.rng"/>  
                <include href="./z3986-emph.rng" />
                
                <include href="./z3986-time.rng"/>
                <include href="./z3986-name.rng"/>  
                <include href="./z3986-definition.rng"/>
                <include href="./z3986-term.rng"/>  
                <include href="./z3986-d.rng"/>      
                <include href="./z3986-sub-sup.rng"/>
                <include href="./z3986-num.rng" />
                <include href="./z3986-char.rng" />
                
                <x:h3>Common Attributes</x:h3>  
                <include href="./z3986-core-attrib.rng"/>
                <include href="./z3986-i18n-attrib.rng"/>  
                <include href="./xlink.rng"/>  
                
                <include href="./rdfa-attrib.rng"/>
                <include href="./z3986-role-attrib.rng"/>    
                <include href="./z3986-by-attrib.rng"/>
                
                <x:h2>Profile Specific Modules</x:h2>  
                
                <x:h2>Optional Feature Modules</x:h2>
                
                <div x:id="ssml" x:class="feature">
                    <x:h2>SSML Integration Feature</x:h2>
                    <include href="./z3986-feature-ssml.rng"/>
                </div>
                
                <div x:id="its-ruby" x:class="feature">
                    <x:h2>ITS Ruby Feature</x:h2>
                    <include href="./z3986-feature-its-ruby.rng"/>
                </div>
                
                <div x:id="mathml" x:class="feature">
                    <x:h2>MathML Feature</x:h2>
                    <include href="./z3986-feature-mathml.rng"/>
                </div> 
                
                <div x:id="rend" x:class="feature">
                    <x:h2>Source Rendition Feature</x:h2>
                    <include href="./z3986-feature-rend.rng"/>
                </div>
                
                <div x:id="svg-cdr" x:class="feature">
                    <x:h2>SVG CDR Feature</x:h2>
                    <include href="./z3986-feature-svg-cdr.rng"/>
                </div>
                
                <x:h2>RDF Property Enumeration Modules</x:h2>
                <include href="./z3986-vocab-contrib-structure.rng"/>
                
                <x:h2>Support Modules</x:h2>  
                <include href="./z3986-datatypes.rng" />
                
                <!-- unused class defs -->
                <define name="z3986.Section.extern.class">
                    <notAllowed/>
                </define>
            </div>
            <start>
                <ref name="z3986.feature.description"/>
            </start>
            <xsl:apply-templates select="child::*[not(self::db:info)]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
