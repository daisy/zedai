<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

	<!-- see /util/rd/build-rd.xsl -->
	<!-- an intro element must be provided, destination is a div -->

	<div class="intro">
		<p>The Source Rendition Feature provides the ability to represent a limited set of
			typographic/stylistic properties of a source document using inline attributes.</p>
		<p>While document authors will normally use generic mechanisms (primarily
			<a href="http://www.w3.org/TR/CSS2/">CSS</a> for this purpose, this feature is provided for use
			in non-CSS-aware production environments, in particular targeting existing Braille
			production infrastructures.</p>
		<p>The feature makes use of names and values drawn from CSS where applicable, but does so in
			a manner that allows information retrieval without the need for a complete CSS
			implementation.</p>
		<p> Further, this feature only contributes attribute components to the Z39.86-AI markup
			model in order to minimize the impact on the document structure.</p>
		<p>Note - this feature describes typographic/stylistic properties of the
				<strong>source</strong>; the information added to the Z39.86-AI document using this
			feature has no direct implications on the styling or formatting of the output.</p>
	</div>

	<div class="normative-top">
		<div class="rd-section">
			<h3>General document model requirements</h3>
			<p id="feature-ns">The namespace of all attribute components defined by this feature is
					<code>http://www.daisy.org/ns/z3986/authoring/features/rend/</code>.</p>
		</div>
	</div>

	<div class="rd-section" id="pa-reqs">
		<div class="rd-section">
			<h4 id="pa-reqs-supported">Feature supported</h4>
			<p id="pa-reqs-supported-activated">If the Processing Agent <em>supports</em> this
				feature and the client has <em>activated</em> processing of components defined by
				this feature, then the Processing Agent must process all encountered components
				defined by this feature in accordance with the semantics defined in <a
					href="#absdef">abstract definitions</a> below. </p>
			<p id="pa-reqs-supported-deactivated">If the Processing Agent <em>supports</em> this
				feature and the client has <em>deactivated</em> processing of components defined by
				this feature, then the Processing Agent must employ the <a
					href="pa-reqs-recognized-ignore">Ignore</a> or <a
					href="pa-reqs-recognized-discard">Discard</a> behaviors as defined below. The
					<code>Ignore</code> behavior is the default; the <code>Discard</code> behavior
				must only be employed when client has explicitly instructed the Processing Agent to
				do so.</p>
			<p class="note">(Note that a document transformation where all or some of the
					CSS-compatible expressions defined by this feature are moved to an external CSS
					stylesheet does <em>not</em> comprise an example of the the <code>Discard</code>
					behavior.)</p>
		</div>
		<div class="rd-section">
			<h4 id="pa-reqs-recognized">Feature recognized</h4>
			<p>If a Processing Agent <em>recognizes but does not support</em> this feature, it must
				employ one of the following behaviors:</p>
			<dl>
				<dt id="pa-reqs-recognized-abort">Abort</dt>
				<dd>
					<p>Upon encountering a document instance with this feature enabled, the
						Processing Agent issues a notification, and then aborts the processing.</p>
				</dd>
				<dt id="pa-reqs-recognized-ignore">Ignore</dt>
				<dd>
					<p>While traversing the document tree and encountering an attribute in the <a
							href="#feature-ns">feature namespace</a>, the Processing Agent ignores
						the attribute, and continues the traversal. </p>
				</dd>
				<dt id="pa-reqs-recognized-discard">Discard</dt>
				<dd>
					<p>While traversing the document tree and encountering an attribute in the <a
							href="#feature-ns">feature namespace</a>, the Processing Agent
						<em>discards</em> the attribute, and continues the traversal.</p>
				</dd>
			</dl>
			<xi:include href="pa-reqs-recognized.xinc"/>
		</div>
	</div>

	<div id="public-components">
		<ul>
			<li><code>rend</code> TODO make these links to Per's schemadoc once his file/ID
				structure is predictable</li>
		</ul>
	</div>

	<div class="rd-section" id="absdef">
		<?absdef src="/mod/z3986-feature-rend.rng" ?>
	</div>

</html>
