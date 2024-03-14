<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->

  <!-- an intro element must be provided, destination is a div -->
  <div class="intro">
    <p> The Z39.98 MathML Feature defines the W3C <a href="http://www.w3.org/TR/MathML3/"
        >Mathematical Markup Language (MathML) Version 3.0</a> as a feature for use in Z39.98-AI
      Profiles.</p>
    <p>Each element contributed by this feature inherits the corresponding semantics as defined by
    MathML 3.</p>
  </div>

  <div class="normative-top">
    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p>As compared to <a href="http://www.w3.org/Math/RelaxNG/mathml3/mathml3.rnc">the W3C Full
          MathML 3 schema</a>, this feature adds the following constraints to the use of MathML
        within Z39.98-AI profiles:</p>
      <dl>
        <dt id="primary-representation">Presentation MathML as primary expression form</dt>
        <dd>
          <p> In this feature, the MathML 3 <a href="http://www.w3.org/TR/MathML3/chapter3.html"
              >Presentation elements</a> constitute the primary expression form for mathematical
            notation. The <code>math</code> element only allows descendants from the Presentation
            elements group, with the exception of the optional <code>annotation-xml</code> element,
            inside which <a href="http://www.w3.org/TR/MathML3/chapter4.html">Content markup</a> is
            allowed. </p>
        </dd>

        <dt>Deprecated elements attributes not allowed</dt>
        <dd>
          <p> Elements and attributes deprecated by MathML 3 must not occur. </p>
        </dd>

        <dt>Use of the <code>annotation framework</code></dt>
        <dd>
          <p>This feature allows the use of the MathML <a
              href="http://www.w3.org/TR/MathML3/chapter5.html">annotation framework</a> for
            providing <em>parallell markup</em>, i.e. alternate representations of the primary
            representation.</p>
          <p>The following restrictions apply to the use of the annotation framework:</p>
          <dl>
            <dt>Use of <code>alttext</code> and <code>altimg</code> on <code>math</code></dt>
            <dd>
              <p>Processing agents must not consider the the <code>alttext</code> and
                  <code>altimg</code> attributes on the <code>math</code> element as sources for
                alternate representations, instead recognizing the <code>annotation</code> and
                  <code>annotation-xml</code> elements for this purpose. </p>
            </dd>

            <dt>Restriction on image content types</dt>
            <dd>
              <p> When providing images as alternate representations to MathML markup, the image
                content types used must not be other than those globally allowed by the Z39.98-AI
                profile. Concretely, this means that image references appearing on or inside a
                  <code>math</code> element are restricted to the same set as specified by the
                  <code>srctype</code> attribute on the <a href="#z3998.object.module">object</a>
                element in the given profile. </p>
            </dd>

            <dt>Restriction on allowed content types in <code>annotation-xml</code></dt>
            <dd>
              <p> The MathML <a
                  href="http://www.w3.org/TR/MathML3/chapter5.html#mixing.elements.annotation.xml"
                  >annotation-xml</a> element provides a mechanism to provide alternate XML
                representation forms of the primary representation. </p>
              <p> This feature restricts the XML languages that are allowed inside the
                  <code>annotation-xml</code> element. This restriction holds regardless of whether
                the <a href="http://www.w3.org/TR/MathML3/chapter5.html#mixing.annotation.keys"
                  >annotation key</a> used is <code>alternate-representation</code> or
                  <code>contentequiv</code>. </p>
              <p> In this version of this feature, the allowed XML content types are: </p>
              <dl>
                <dt>Content MathML</dt>
                <dd>
                  <p>Documents must use and processing agents must recognize the values
                      <code>application/mathml-content+xml</code> and <code>MathML-Content</code> as
                      <code>encoding</code> identifiers for this content type. (See further <a
                      href="http://www.w3.org/TR/MathML3/chapter6.html#encoding-names">Names of
                      MathML Encodings</a>.) </p>
                  <p>The XML content inside an <code>annotation-xml</code> element using the
                      <code>Content MathML</code> encoding is restricted to the <a
                      href="http://www.w3.org/TR/MathML3/appendixa.html#parsing.rnc.content">Grammar
                      for Content MathML</a>.</p>
                </dd>

                <dt>Presentation Mathml</dt>
                <dd>
                  <p>Documents must use and processing agents must recognize the values
                      <code>application/mathml-presentation+xml</code> and
                      <code>MathML-Presentation</code> as <code>encoding</code> identifiers for this
                    content type. (See further <a
                      href="http://www.w3.org/TR/MathML3/chapter6.html#encoding-names">Names of
                      MathML Encodings</a>.) </p>
                  <p>The XML content inside an <code>annotation-xml</code> element using the
                      <code>Presentation MathML</code> encoding is restricted to the <a
                      href="http://www.w3.org/TR/MathML3/appendixa.html#parsing.rnc.pres">Grammar
                      for Presentation MathML</a>.</p>
                </dd>

                <dt>Z39.98-AI Core markup</dt>
                <dd>
                  <p>Documents must use and processing agents must recognize the string
                      <code>Z39.98-AI</code> as the <code>encoding</code> identifier for this
                    content type. </p>
                  <p>The XML content inside an <code>annotation-xml</code> element using the
                      <code>Z39.98-AI</code> encoding is restricted to elements from the <a
                      href="#coreNamespace">Z39.98-AI Core namespace</a>, and elements in other
                    namespaces from features supported by the given profile. However, elements from
                    the MathML namespace must not occur within an <code>annotation-xml</code>
                    element that declares the <code>Z39.98-AI</code> content type. Use of elements
                    from other Z39.98-AI features is discouraged.</p>
                </dd>
              </dl>
              <p> Note that subsequent versions of this feature may extend this set to include
                additional XML content types. </p>
              <p> Refer to <a href="#pa-reqs">processing agent requirements</a> below for
                information on requirements regarding processing of the <code>annotation</code> and
                  <code>annotation-xml</code> elements. </p>
            </dd>

            <dt>Restriction on annotation keys</dt>
            <dd>
              <p> Processing agents are not required to recognize any other annotation keys than
                  <code>alternate-representation</code> and <code>contentequiv</code>. Refer to <a
                  href="http://www.w3.org/TR/MathML3/chapter5.html#mixing.annotation.keys"
                  >Annotation keys</a> for information on the semantics of these keys. </p>
            </dd>

          </dl>
        </dd>

      </dl>
      <h3>Deviations from the Z39.98 Global Attributes class</h3>
      <p> This features overrides the following attribute contributions from the Z39.98-AI <a
          href="#z3998.global.attrib">Global attributes</a> class: </p>
      <ul>
        <li>The MathML-native <code>id</code> attribute is used instead of the Z39.98-AI-global
            <code>xml:id</code> attribute</li>
        <li>The MathML-native <code>href</code> attribute is used instead of the Z39.98-AI-global
            <code>xlink:href</code> attribute</li>
        <li>The Z39.98-AI-global <code>meta</code> and <code>i18n</code> attribute classes are 
        	not contributed to elements in the MathML namespace</li>
      </ul>
    </div>
  </div>

  <div class="rd-section" id="pa-reqs">
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a processing agent <em>supports</em> this feature, it must comply to the following:</p>
      <p> The processing agent must process the <a href="#primary-representation">primary
          representation</a> as defined by the MathML 3 specification. </p>
      <p> The processing agent may support an operating mode where it lets the client invoke
        processing behaviors that includes utilization of <code>annotation</code> and/or
          <code>annotation-xml</code> elements in a way that effectively leaves the <a
          href="#primary-representation">primary representation</a> unused. </p>
      <p> The processing agent may support content types beyond that of the <a
          href="#primary-representation">primary representation</a> in annotations that has a
          <code>contentequiv</code> relationship to the main expression. When a processing agent
        encounters a <code>contentequiv</code> annotation that it does not support, it must abort
        the processing unless the client has explicitly expressed that the given
          <code>contentequiv</code> annotation is ignorable. (This is because, as stated in <cite><a
            href="http://www.w3.org/TR/MathML3/chapter5.html#mixing.content.equiv">5.1.4 Content
            equivalents</a></cite>, <q>annotations with the contentequiv key cannot be ignored
          without potentially changing the behavior of an expression.</q>)</p>
    </div>
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      <p>If a processing agent <em>recognizes but does not support</em> this feature, it must employ
        one of the following behaviors:</p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p> Upon encountering a document instance with this feature enabled, the processing agent
            issues a notification, and then aborts the processing. </p>
        </dd>

        <dt id="pa-reqs-recognized-fallback">Fallback</dt>
        <dd>
          <p>While traversing the document tree and encountering an <code>math</code> element, the
            processing agent evaluates the content-type of any <code>annotation</code> and
              <code>annotation-xml</code> element descendants of the given <code>math</code>
            element: </p>
          <ul>
            <li>
              <p> If no <code>annotation</code> or <code>annotation-xml</code> elements with a
                supported content type are given, the processing agent issues a notification, and
                then aborts the processing. </p>
            </li>
            <li>
              <p> If <code>annotation</code> or <code>annotation-xml</code> elements with a
                supported content type are given, the processing agent replaces the current
                  <code>math</code> element with the content of the supported
                  <code>annotation</code> or <code>annotation-xml</code> element. </p>
              <p> The following precedence order must be followed in the case where multiple
                supported <code>annotation</code> or <code>annotation-xml</code> are given, and if
                the client has provided no explicit instructions on fallback prioritization: </p>
              <ol>
                <li><code>annotation-xml</code> takes precedence over <code>annotation</code>;</li>
                <li>Among multiple <code>annotation-xml</code> elements, the first element in
                  document order takes precedence;</li>
                <li>Among multiple <code>annotation</code> elements, the first element in document
                  order takes precedence.</li>
              </ol>
            </li>
          </ul>
        </dd>
      </dl>
      <p> The <code>abort</code> behavior is the default; the <code>fallback</code> behavior must
        only be employed when the processing agent is explicitly instructed to do so by the
        client.<br/> Processing agents that employ the <code>fallback</code> behavior should issue a
        notification. </p>
    </div>
  </div>

  <div id="public-components">
    <ul>
      <li><code><a href="http://www.w3.org/TR/MathML3/chapter2.html#interf.toplevel"
        >math</a></code></li>
    </ul>
  </div>


</html>
