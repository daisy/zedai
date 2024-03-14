<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">

	<!-- see /util/rd/build-rd.xsl -->

	<!-- an intro element must be provided, destination is a div -->
	<div class="intro">
		<p>The Source Rendition Feature allows capturing of a limited set of
			typographic properties of a source document.</p>

		<p>While document authors will normally use generic mechanisms (such
			as CSS) for this purpose, this feature is provided for use in
			non-CSS-aware production environments, enabling for example efficient Braille
			transcription.</p>

		<p>Note - this feature captures properties of the <strong>source</strong> - 
			this has no direct implications on the styling or formatting of
			output.</p>

	</div>
	
	<div class="normative-top">
      <div class="rd-section">
           <h3>General document model requirements</h3>
             <p id="feature-ns">The namespace of all members of the <code>Source Rendition</code> feature
               element/attribute set is <code>http://www.daisy.org/z3986/2010/auth/features/rend/</code>.</p>
      </div>
    </div>  
	
</html>