<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->

  <!-- an intro element must be provided, destination is a div -->

  <div class="intro">
    <p>The Z39.86 SSML Integration Feature recasts a subset of the W3C <a
        href="http://www.w3.org/TR/speech-synthesis11/">Speech Synthesis Markup Language (SSML)
        Version 1.1</a> as a Feature for incorporation in Z39.86-AI Profiles.</p>

    <p>The Z39.86 SSML Integration Feature is designed to be used in authoring contexts where
        <em>speech output</em> is targeted. The feature's content model definitions are designed so
      that a Processing Agent can safely ignore or filter out the SSML fragments when speech-related
      information is not relevant.</p>

    <p>Each element contributed by the feature inherits the corresponding semantics as defined 
      by SSML 1.1, unless specified otherwise.</p>

  </div>

  <div class="rd-section" id="pa-reqs">
    
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a Processing Agent <em>supports</em> this feature, it must comply to the
        following:</p>
      <dl>
        <dt>Processing of <code>phoneme</code></dt>
        <dd>
          <p>The Processing Agent must support the SSML <code>
            <a href="ssml.phoneme">phoneme</a>
          </code> element, and process it as dictated by the SSML specification.</p>
          
          <p> Upon encountering the <code>ssml:ph</code> and associated <code>ssml:alphabet</code>
            attributes on a non-SSML namespace element, the Processing Agent must process the
            element equally to the SSML <code>
              <a href="#ssml.phoneme">phoneme</a>
            </code> element.</p>
          
        </dd>
        
        <dt>Processing of <code>token</code></dt>
        <dd>
          <p>The Processing Agent must support the SSML <code>
            <a href="ssml.token">token</a>
          </code> element, and process it as dictated by the SSML specification.</p>
          
          <p>The <code>w</code> (word) element from the Z39.86-AI default namespace must be
            regarded a synonym of to the SSML <code>
              <a href="#ssml.token">token</a>
            </code> element.</p>
        </dd>
        
        <dt>Processing of <code>lexicon</code></dt>
        <dd>
          <p>The Processing Agent must support the SSML <code>
            <a href="ssml.lexicon">lexicon</a>
          </code> element, and process it as dictated by the SSML specification.</p>
          
          <p>The Processing Agent must support the PLS (<code>application/pls+xml</code>) media
            type, and process PLS documents as dictated by <a
              href="http://www.w3.org/TR/speech-synthesis11/#ref-pls">PLS</a>.</p>
        </dd>
        
        <dt>Processing of <code>prosody</code>, <code>say-as</code>, <code>sub</code> and <code>break</code></dt>
        <dd>
          <p>The Processing Agent should support the SSML <code>
            <a href="#ssml.prosody">prosody</a>
          </code>, <code>
            <a href="#ssml.say-as">say-as</a>
          </code>, <code>
            <a href="#ssml.sub">sub</a>
          </code>  and <code>
            <a href="#ssml.break">break</a>
          </code> elements, and process them as dictated by the SSML specification.</p>
          <p>If it does not support these elements, the Processing Agent must employ the behavior
            defined in <a href="#pa-reqs-recognized-ignore">Ignore</a> below.</p>
        </dd>
        
        <dt>Phonetic Alphabets</dt>
        <dd><p>Processing Agents should support the <code>
          <a href="http://www.phon.ucl.ac.uk/home/sampa/index.html">X-SAMPA</a>
        </code> phonetic alhabet.</p></dd>
        
        <dt>Processing in non-speech output contexts</dt>
        <dd>In a non-speech output context, the Processing Agent must employ one of the the
          behaviors defined in <a href="#pa-reqs-recognized">Feature recognized</a> below.</dd>
      </dl>
    </div>
    
    
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      
      <p>If a Processing Agent <em>recognizes but does not support</em> this feature, it must
        employ one of the following behaviors:</p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p>Upon encountering a document instance with this feature enabled, the Processing Agent issues
            a notification, and then aborts the processing.</p>
        </dd>                    
        <dt id="pa-reqs-recognized-ignore">Ignore</dt>
        <dd>
          <p>While traversing the document tree, the Processing Agent <em>ignores</em> any
            encountered XML element in the SSML namespace, and continues processing its
            children.</p>
          <p>Any encountered attributes in the SSML namespace occuring on non-SSML namespace
            elements are also ignored.</p>
        </dd>
        <dt id="pa-reqs-recognized-discard">Discard</dt>
        <dd>
          <p>The Processing Agent <em>discards</em> all elements and attributes contributed by
            this feature;</p>
          <ul>
            <li>Encountered elements in the SSML namespace are recursively replaced by their children, or by
              void if no children exist;</li>
            <li>any encountered attributes in the SSML namespace occuring on non-SSML namespace
              elements are removed.</li>
          </ul>
        </dd>
      </dl>
      
      <xi:include href="pa-reqs-recognized.xinc"/>
      
    </div>
    
  </div>

  <div class="rd-section" id="absdef">    
    <?absdef src="/mod/ssml-11.rng" ?>
    <?absdef src="/mod/ssml-phoneme-attrib.rng" ?>
    <?absdef src="/mod/ssml-datatypes.rng" ?>    
  </div>
  
  <div id='public-components'>
    <ul>
      <li><code>TODO</code> TODO make these links to Per's schemadoc once his file/ID structure is predictable</li>
    </ul>  
  </div>

</html>
