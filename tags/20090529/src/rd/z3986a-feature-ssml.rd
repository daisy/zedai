<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">  
  
  <!-- see /util/rd/build-rd.xsl -->
  
  <!-- an intro element must be provided, destination is a div -->
  <div class="intro">
    <p>The Z39.86 SSML Integration Feature recasts a subset of the W3C 
      <a href="http://www.w3.org/TR/speech-synthesis11/">Speech Synthesis Markup Language (SSML) 
      Version 1.1</a> as a Feature for incorporation in Z39.86-2010 Profiles. 
    </p>
    
    <p>The Z39.86 SSML Integration Feature targets authoring contexts where
      <em>speech output</em> is targeted. The feature's content model definitions
      are designed so that a Processing Agent can safely ignore the SSML fragments
      when speech-related information is not relevant.</p>
      
    <p>Each element of the feature fully inherits the corresponding semantics as defined by 
      SSML 1.1. 
    </p>
    
    
  </div>
 
  <div class="normative-top">
    <div class="rd-section" id="pa-reqs">
      <h3>Processing Agent Processing Requirements</h3>
      <!--  as always, if a PA does not recognize the feature, it must abort -->
      <!--  if it recognizes it, the following applies: -->
      <dl>
      <dt>Processing in speech-output contexts</dt>
      <dd>
        <p>In speech-output processing contexts, Processing Agents should process
          each encountered element or attribute in the SSML namespace as dictated by the SSML 1.1 specification.        
        </p>
        <p>
          Upon encountering the <code>ph</code> and associated <code>alphabet</code> attributes on a non-SSML namespace element, 
          a Processing Agent should process the element equally to the SSML <code>phoneme</code> element.
        </p>
        <p>Processing Agents should consider the Z39.86 <code>w</code> element as equal to the SSML <code>token</code> element.</p>
        <p>Processing Agents that fail to meet the above behavioral expectations should issue a warning.</p>
      </dd>
 
      <dt>Processing in non-speech-output contexts</dt>
      <dd><p>In non-speech-output processing contexts, a Processing Agent <em>must ignore</em>
        any encountered XML element in the SSML namespace, and continue processing its 
        children. Attributes in the SSML namespace occuring on non-SSML namespace elements
        must also be ignored.</p>
	  </dd>
      </dl>
    </div>
 </div>
   
</html>
