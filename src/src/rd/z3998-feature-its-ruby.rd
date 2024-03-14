<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->
  <!-- an intro element must be provided, destination is a div -->

  <div class="intro">

    <p> "Ruby" is the term used for short runs of text alongside the base text, typically used in
      East Asian documents to indicate pronunciation, or to provide a short annotation. </p>

    <p> The Z39.98 ITS Ruby Feature defines <a href="http://www.w3.org/TR/its/#ruby-annotation">ITS
        1.0 Ruby</a> as a feature for use in Z39.98-AI profiles. Note that this feature only
      supports the LOCAL Ruby type, as defined in ITS 1.0. </p>

    <!-- <p>The structure of ITS ruby markup is identical to the structure of ruby markup as
      defined in <a href="http://www.w3.org/TR/ruby/">Ruby Annotations</a> (as used by <a
        href="http://www.w3.org/TR/xhtml11/">XHTML 1.1</a>). </p> -->

  </div>

  <div class="rd-section" id="pa-reqs">
        
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a processing agent <em>supports</em> this feature, it must process encountered
        <code>its:ruby</code> elements as defined in <a
          href="http://www.w3.org/TR/its/#ruby-annotation">ITS 1.0 Ruby</a>. </p>
      <p>(Implementors should note that ITS 1.0 Ruby explictly inherits all fundamental traits of
        ruby markup from <a href="http://www.w3.org/TR/ruby/">Ruby Annotation</a>).</p>
    </div>
       
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      
      <p>If a processing agent <em>recognizes but does not support</em> this feature, it must
        employ one of the following behaviors:</p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p>Upon encountering a document instance with this feature enabled, the processing agent issues
            a notification, and then aborts the processing.</p>
        </dd>
        <dt id="pa-reqs-recognized-ignore">Ignore</dt>
        <dd>
          <p>While traversing the document tree and encountering an <code>its:ruby</code> element, 
            the processing agent <em>ignores</em> any <code>its:rt</code>, <code>its:rp</code>.
            <code>its:rbc</code> and <code>its:rtc</code> descendants, and processes only the
            content of <code>its:rb</code> descendant elements.</p>
        </dd>
        <dt id="pa-reqs-recognized-discard">Discard</dt>
        <dd>
          <p>The processing agent <em>discards</em> the elements and attributes contributed by
            this feature:</p>
          <ul>
            <li>Each encountered <code>its:ruby</code> element is replaced by the content of its
              <code>its:rb</code> descendants.</li>
          </ul>
        </dd>
      </dl>
      
      <xi:include href="pa-reqs-recognized.xinc"/>
            
    </div>
        
  </div>
  
  <div class="rd-section" id="absdef">
    <?absdef src="/mod/z3998-feature-its-ruby.rng" ?>
  </div>

  <div id='public-components'>
    <ul>
      <li><code><a href="#its-ruby"/></code></li>
    </ul>  
  </div>

</html>
