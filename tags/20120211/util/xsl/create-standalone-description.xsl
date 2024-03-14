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
                <include href="./z3998-global-classes.rng" />
                
                <x:h3>Common Elements</x:h3>
                
                <include href="./z3998-document.rng">
                    <start combine="choice">
                        <notAllowed/>
                    </start>
                </include>
                <include href="./z3998-meta.rng"/>
                <include href="./z3998-linking.rng"/>    
                
                <include href="./z3998-section.rng"/>
                <include href="./z3998-headings.rng"/>
                <include href="./z3998-block.rng"/>
                <include href="./z3998-p.rng"/>
                <include href="./z3998-list.rng"/>
                <include href="./z3998-table.rng"/>  
                
                <include href="./z3998-code.rng"/>    
                <include href="./z3998-quote.rng"/>
                <include href="./z3998-citation.rng"/>
                <include href="./z3998-object.rng"/>
                
                <include href="./z3998-note.rng"/>
                <include href="./z3998-annotation.rng"/>
                <include href="./z3998-aside.rng"/>  
                <include href="./z3998-caption.rng"/>
                <include href="./z3998-verse.rng"/>  
                <include href="./z3998-description.rng"/>
                
                <include href="./z3998-span.rng"/>  
                <include href="./z3998-line.rng"/>    
                <include href="./z3998-pagebreak.rng"/>
                <include href="./z3998-s.rng"/>
                <include href="./z3998-w.rng"/>
                
                <include href="./z3998-abbr.rng"/>  
                <include href="./z3998-emph.rng" />
                
                <include href="./z3998-time.rng"/>
                <include href="./z3998-name.rng"/>  
                <include href="./z3998-definition.rng"/>
                <include href="./z3998-term.rng"/>  
                <include href="./z3998-d.rng"/>      
                <include href="./z3998-sub-sup.rng"/>
                <include href="./z3998-num.rng" />
                <include href="./z3998-char.rng" />
                
                <x:h3>Common Attributes</x:h3>  
                <include href="./z3998-core-attrib.rng"/>
                <include href="./z3998-i18n-attrib.rng"/>  
                <include href="./xlink.rng"/>  
                
                <include href="./rdfa-attrib.rng"/>
                <include href="./z3998-role-attrib.rng"/>    
                <include href="./z3998-by-attrib.rng"/>
                
                <x:h2>Profile Specific Modules</x:h2>  
                
                <x:h2>Optional Feature Modules</x:h2>
                
                <div x:id="ssml" x:class="feature">
                    <x:h2>SSML Integration Feature</x:h2>
                    <include href="./z3998-feature-ssml.rng"/>
                </div>
                
                <div x:id="its-ruby" x:class="feature">
                    <x:h2>ITS Ruby Feature</x:h2>
                    <include href="./z3998-feature-its-ruby.rng"/>
                </div>
                
                <div x:id="mathml" x:class="feature">
                    <x:h2>MathML Feature</x:h2>
                    <include href="./z3998-feature-mathml.rng"/>
                </div> 
                
                <div x:id="rend" x:class="feature">
                    <x:h2>Source Rendition Feature</x:h2>
                    <include href="./z3998-feature-rend.rng"/>
                </div>
                
                <div x:id="svg-cdr" x:class="feature">
                    <x:h2>SVG CDR Feature</x:h2>
                    <include href="./z3998-feature-svg-cdr.rng"/>
                </div>
                
                <x:h2>RDF Property Enumeration Modules</x:h2>
                <include href="./z3998-vocab-contrib-structure.rng"/>
                
                <x:h2>Support Modules</x:h2>  
                <include href="./z3998-datatypes.rng" />
                
                <!-- unused class defs -->
                <define name="z3998.Section.extern.class">
                    <notAllowed/>
                </define>
            </div>
            <start>
                <ref name="z3998.feature.description"/>
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
