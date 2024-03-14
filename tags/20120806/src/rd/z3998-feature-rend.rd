<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

	<!-- see /util/rd/build-rd.xsl -->
	<!-- an intro element must be provided, destination is a div -->

	<div class="intro">
		<p>The Source Rendition Feature provides the ability to represent a limited set of
			typographic properties of a source document using inline attributes.</p>
		<p>Although it is expected that document authors will use generic styling mechanisms 
			for representing the source document (primarily <a href="http://www.w3.org/TR/CSS2/">CSS</a>), 
			this feature is provided for use when CSS alone may not be sufficient.</p>
		<p>This feature makes use of names and values drawn from CSS where applicable for compatibility,
			but direct translation of the attributes and functionality to CSS is not guaranteed.</p>
	</div>

	<div class="normative-top">
		<div class="rd-section">
			<h3>General document model requirements</h3>
			<p id="feature-ns">The namespace of all attribute components defined by this feature is:<br/><br/>
					<code>http://www.daisy.org/ns/z3998/authoring/features/rend/</code></p>
		</div>
	</div>

	<div class="rd-section" id="pa-reqs">
		<div class="rd-section">
			<h4 id="pa-reqs-supported">Feature supported</h4>
			<p id="pa-reqs-supported-activated">If the processing agent <em>supports</em> this
				feature and the client has <em>activated</em> processing of components defined by
				this feature, then the processing agent must process all encountered components
				defined by this feature in accordance with the semantics defined in <a
					href="#absdef">definitions</a> below. </p>
			<p id="pa-reqs-supported-deactivated">If the processing agent <em>supports</em> this
				feature and the client has <em>deactivated</em> processing of components defined by
				this feature, then the processing agent must employ the <a
					href="#pa-reqs-recognized-ignore">Ignore</a> or <a
					href="#pa-reqs-recognized-discard">Discard</a> behaviors as defined below. The
					<code>Ignore</code> behavior is the default; the <code>Discard</code> behavior
				must only be employed when client has explicitly instructed the processing agent to
				do so.</p>
			<p class="note">(Note that a document transformation where all or some of the
					CSS-compatible expressions defined by this feature are moved to an external CSS
					stylesheet does <em>not</em> comprise an example of the the <code>Discard</code>
					behavior.)</p>
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
					<p>While traversing the document tree and encountering an attribute in the <a
							href="#feature-ns">feature namespace</a>, the processing agent ignores
						the attribute, and continues the traversal. </p>
				</dd>
				<dt id="pa-reqs-recognized-discard">Discard</dt>
				<dd>
					<p>While traversing the document tree and encountering an attribute in the <a
							href="#feature-ns">feature namespace</a>, the processing agent
						<em>discards</em> the attribute, and continues the traversal.</p>
				</dd>
			</dl>
			<xi:include href="pa-reqs-recognized.xinc"/>
		</div>
	</div>

	<div id="public-components">
		<ul>
			<li><code><a href="#z3998.rend.symbol.attrib"/></code></li>
			<li><code><a href="#z3998.rend.list.ordered.prefix.attrib"/></code> (ordered <code>list</code>)</li>
			<li><code><a href="#z3998.rend.list.unordered.prefix.attrib"/></code>(unordered <code>list</code>)</li>
			<li><code><a href="#z3998.rend.list.item.prefix.attrib"/></code>(list <code>item</code>)</li>
			<li><code><a href="#z3998.rend.prefix.attrib"/></code></li>			
		</ul>
	</div>

	<div class="rd-section" id="absdef">
		<?absdef src="/mod/z3998-feature-rend.rng" ?>
	</div>

</html>
