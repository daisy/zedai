<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->

  <!-- an intro element must be provided, destination is a div -->
  <div class="intro">
    <p>The Z39.98 SVG CDR (Compound Document by Reference) feature enables the use of SVG,
      referenced as external documents via the <code><a href="#z3998.object.module"
          >object</a></code> element, or specializations thereof.</p>
    <p>The fallback mechanism defined by the <code>object</code> element is used to provide
      alternate content type renditions where needed.</p>
    <p>Note that this feature does not require alternate image format renditions to be provided,
      although this is highly recommended practice.</p>
  </div>

  <div class="normative-top">
    <div class="rd-section" id="content-reqs">
      <h3><code>object</code> Element requirements</h3>
      <p>The <code>object</code> elements that carry the SVG document references must contain a
        textual fallback, as defined in the <a href="#z3998.object.module">object module</a>. <!--<span
          class="ednote">TODO decide whether non-child annotation elements are to be considered
          textual fallbacks.</span>--></p>
      <p>The <code>object</code> elements that carry the SVG document references should contain at
        least one fallback using the image formats defined in <a href="#z3998.srctype.attrib">core
          image types</a>.</p>
      <h3>SVG Document Requirements</h3>
      <p>The referenced SVG documents must conform to one of the following versions of SVG:</p>
      <ul>
        <li><a href="http://www.w3.org/TR/SVG11/">SVG 1.1</a></li>
        <li><a href="http://www.w3.org/TR/SVGTiny12/">SVG 1.2 Tiny</a></li>
      </ul>
      <p>Note that the schema module provided by this feature does not validate the referenced SVG
        documents; validating processing agents must perform SVG validation as an additional
        routine.</p>
    </div>
  </div>

  <div class="rd-section" id="pa-reqs">
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a processing agent <em>supports</em> this feature, it must process encountered SVG
        references as dictated by the <a href="http://www.w3.org/TR/SVG11/">SVG 1.1</a> and <a
          href="http://www.w3.org/TR/SVGTiny12/">SVG 1.2 Tiny</a> specifications respectively.</p>
    </div>
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      <p>If a processing agent <em>recognizes but does not support</em> this feature, it must employ
        one of the following behaviors:</p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p>Upon encountering a document instance with this feature enabled, the processing agent
            issues a notification, and then aborts the processing.</p>
        </dd>
        <dt id="pa-reqs-recognized-ignore">Ignore</dt>
        <dd>
          <p>While traversing the document tree, the processing agent <em>ignores</em> any
            encountered <code>object</code> element referencing an SVG document, and continues
            processing its children.</p>
          <!--
          <p>If the the given <code>object</code> element has no children, nor any
              <code>annotation</code> elements associated with it, then the element has no alternate
            representations. In this instance, the processing agent must issue a notification, and
            then abort the processing.</p> -->
        </dd>
        <dt id="pa-reqs-recognized-discard">Discard</dt>
        <dd>
          <p>The processing agent <em>discards</em>
            <code>object</code> elements referencing SVG documents;</p>
          <ul>
            <li>Encountered <code>object</code> elements with SVG references are recursively
              replaced by their children, until the replacement consists of a media type that is
              supported by the processing agent. <!-- If the recursive replace process results in null
              content, then the processing agent must issue a notification, and then abort the
              processing. -->
              <!--<span class="ednote">TODO decide whether non-child annotation elements are part of
                this process.</span>--></li>
          </ul>
        </dd>
      </dl>
      <xi:include href="pa-reqs-recognized.xinc"/>
    </div>
  </div>

  <div id="public-components">
    <ul>
      <li>As this feature is an extension to the allowed content types of the <code>object</code>
        element, it has no <a href="#featureConformance">public components</a>.</li>
    </ul>
  </div>

</html>
