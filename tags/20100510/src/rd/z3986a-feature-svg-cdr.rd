<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->

  <!-- an intro element must be provided, destination is a div -->
  <div class="intro">
    <p>The Z39.86 SVG CDR (Compound Document by Reference) feature enables the use of SVG, referenced as external documents via
    	the <code>object</code> element, or specializations thereof.</p>
    <p>The fallback mechanism defined by the object element is used to provide alternate content type renditions where needed.</p>
    <p>Note that this feature does not require alternate image format renditions to be provided, although this is highly recommended practice.</p>	
  </div>

  <div class="normative-top">
    <div class="rd-section" id="content-reqs">
      <h3><code>object</code> Element requirements</h3>
      
      <p>The <code>object</code> elements that carry the SVG document references must contain a textual fallback, as defined
        in the <a href="#z3986.object.module">object module</a>.</p> 
      
      <p>The <code>object</code> elements that carry the SVG document references should contain at least one fallback using 
        the image formats defined in <a href="#z3986.srctype.attrib">core image types</a>.</p>
      
      <h3>SVG Document Requirements</h3>
      <p>The referenced SVG documents must conform to one of the following versions of SVG:</p>
      <ul>
      <li><a href="http://www.w3.org/TR/SVG11/">SVG 1.1</a></li>
      <li><a href="http://www.w3.org/TR/SVGTiny12/">SVG 1.2 Tiny</a></li>
      </ul>
      <p>Note that the schema module provided by this feature does not validate the referenced SVG documents; validating
      	Processing Agents must perform SVG validation as an additional routine.</p>      	  
    </div>    
  </div>
  
  <div class="rd-section" id="pa-reqs">
        
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a Processing Agent <em>supports</em> this feature, it must process encountered SVG references as
        dictated by the <a href="http://www.w3.org/TR/SVG11/">SVG 1.1</a> and
        <a href="http://www.w3.org/TR/SVGTiny12/">SVG 1.2 Tiny</a> specifications respectively.</p>
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
            encountered <code>object</code> element referencing an SVG document, and continues processing its
            children.</p>
        </dd>
        <dt id="pa-reqs-recognized-discard">Discard</dt>
        <dd>
          <p>The Processing Agent <em>discards</em> object elements referencing SVG documents;</p>
          <ul>
            <li>Encountered <code>object</code> elements with SVG references are recursively replaced by their children, until
              the replacement consists of a media type that is supported by the Processing Agent.</li>              
          </ul>
        </dd>
      </dl>
      
      <xi:include href="pa-reqs-recognized.xinc"/>
      
    </div>    
  </div>
  
  <div id='public-components'>
    <ul>
      <li><code>svg</code> TODO make this a link to Per's schemadoc once his file/ID structure is predictable</li>
    </ul>  
  </div>  

</html>
