<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->
  <!-- see _readme in this dir -->

  <div class="intro">
    <p>The DIAGRAM Description feature defines a markup model for the creation of accessible content descriptions.
      The feature encapsulates a set of informative descriptions that can be referenced by images, graphics and 
      other describable structures in any host grammar (e.g., HTML and EPUB).</p>
    <p>The Description feature is intended to function both as a standalone model for descriptions 
      (i.e., allowing descriptions to be authored and consumed on their own), to allow descriptions 
      to be collected into a single document for distribution and to be directly integrated into 
      host languages.</p>
  </div>
  
  <div class="normative-top">
    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p id="feature-ns">The namespace of all attribute components defined by this feature is:<br/><br/>
        <code>http://www.daisy.org/ns/z3986/authoring/features/description/</code></p>
    </div>
  </div>
  
  <div class="rd-section" id="pa-reqs">
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p id="pa-reqs-supported-activated">If the processing agent <em>supports</em> this
        feature and the client has <em>activated</em> processing of components defined by
        this feature, then the processing agent must process all encountered components
        defined by this feature in accordance with the semantics defined in the <a
          href="#absdef">definitions</a> below. </p>
      <p id="pa-reqs-supported-deactivated">If the processing agent <em>supports</em> this
        feature and the client has <em>deactivated</em> processing of components defined by
        this feature, then the processing agent must employ the <a
          href="#pa-reqs-recognized-ignore">Ignore</a> or <a
            href="#pa-reqs-recognized-discard">Discard</a> behaviors as defined below. The
        <code>Ignore</code> behavior is the default; the <code>Discard</code> behavior
        must only be employed when client has explicitly instructed the processing agent to
        do so.</p>
    </div>
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      <p>If a processing agent <em>recognizes but does not support</em> this feature, it must
        employ one of the following behaviors:</p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p>Upon encountering a document instance with this feature enabled, the
            processing agent issues a notification, and then aborts the processing.</p>
        </dd>
        <dt id="pa-reqs-recognized-ignore">Ignore</dt>
        <dd>
          <p>While traversing the document tree and encountering an element in the <a
            href="#feature-ns">feature namespace</a>, the processing agent ignores
            the element, and continues the traversal. </p>
        </dd>
        <dt id="pa-reqs-recognized-discard">Discard</dt>
        <dd>
          <p>While traversing the document tree and encountering an element in the <a
            href="#feature-ns">feature namespace</a>, the processing agent
            <em>discards</em> the element, and continues the traversal.</p>
        </dd>
      </dl>
      <xi:include href="pa-reqs-recognized.xinc"/>
    </div>
  </div>
  
  <div id="standalone">
    <!-- do not remove - triggers addition of standalone scheme -->
  </div>

  <div id="public-components">
    <ul>
      <li>The <code>description</code> element.</li>
    </ul>
  </div>

  <div class="examples">
    <p>A <a href="http://zednext.googlecode.com/svn/trunk/test/z3986/descriptions/valid/water-cycle.xml">minimally 
      complete example</a> of a description is available.</p>
  </div>
  
  <div class="rd-section" id="absdef">
    <?absdef src="/mod/z3986-feature-description.rng" ?>
  </div>
  
</html>
