<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">

  <!-- see /util/rd/build-rd.xsl -->

  <!-- an intro element must be provided, destination is a div -->

  <div class="intro">
    <p>The <code>Content Selection</code> feature provides a mechanism with which publishers can
      define alternate renderings of content fragments.</p>

    <p>One core use-case for this feature is to <strong>vary the information set of output
        documents</strong>, based on criteria such as <em>output content type</em>, or <em>target
        consumer group</em>. Specific variations of portions of the document can be associated
      exclusively with the Braille and e-text content types. "Simplified" versions of complex
      passages can be provided to meet the needs of persons with certain cognitive disabilities.</p>

    <p>In the Z39.86 Authoring and Interchange context, the feature may also be used to provide
        <strong>feature fallbacks</strong>. While a publisher would normally be in a situation where
      the feature support in used Processing Agents is known, this is not always the case,
      especially in a content interchange scenario. As an example, not knowing whether a processing
      chain has full support for the MathML feature, a publisher may choose to use the <code>Content
        Selection</code> feature to provide content fallback for MathML content.</p>

    <p>The <code>Content Selection</code> feature employs a conditional switch mechanism,
      represented by 1-n <code>when</code> elements appearing as children to the parent
        <code>select</code> element. There is an always-present default choice within the switch,
      represented by the <code>otherwise</code> element.</p>

  </div>

  <div class="normative-top">
    <div class="rd-section">
      <h3>Definition of terms</h3>
      <dl>

        <dt id="conditionalexpression">Conditional expression</dt>
        <dd>
          <p>The value of the <code>expr</code> attribute on the <code>when</code> element. A
            conditional expression is syntactically a combination of one or more <a href="#function">functions</a>, 
            zero or
            more <a href="#operators">operators</a>, and zero or more balanced parentheses. The result of the evaluation of a
            conditional expression must always be a boolean true or false.</p>
          <p>The syntax of a conditional expression is normatively defined in <a href="#ce-ebnf"
              >EBNF Definition of the Conditional Expression</a>.</p>
        </dd>

        <dt id="function">Function</dt>
        <dd>
          <p>A function is the core component of a conditional expression. The return value of a
            function must always be boolean true or false. A function can take zero or one
            parameters.</p>
          <p>A function is always prefixed; the prefix defines which <a href="#functionset">function
              set</a> the function belongs to.</p>
        </dd>

        <dt id="operators">Operators</dt>
        <dd>
          <p>This feature allows the operators <code>and</code>, <code>or</code> and
              <code>not</code>.</p>
          <p class="ednote">TODO define meaning of operators</p>
        </dd>

        <dt id="functionset">Function set</dt>
        <dd>
          <p>A Function set is a collection of 1-n functions. The set is defined by a canonical URI.
            When a function is used in a conditional expression, is uses a name prefix as a token
            for that URI. The association between prefixes and URIs is defined in the document head,
            and is thus static throughout the document scope.</p>
          <p>The content selection feature provides a set of <a href="#predef-functionsets"
              >predefined function sets</a>. 
              <a href="#additional-functionsets">Additional function sets may be defined.</a></p>
        </dd>

      </dl>

    </div>

    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p id="feature-ns">The namespace of all members of the <code>Content Selection</code> feature
        element set is <code>http://www.daisy.org/z3986/2010/auth/features/select/</code>.</p>
      <p>The <code>when</code> and <code>otherwise</code> elements must not contain any descendants
        in the <code>http://www.daisy.org/z3986/2010/auth/features/select/</code> namespace.</p>
    </div>


    <div class="rd-section" id="prefix-decl">
      <h3>Declaration of function prefix-URI mappings</h3>
      <p class="ednote">TODO</p>
    </div>  

    <div class="rd-section" id="ce-ebnf">
      <h3>EBNF Definition of the Conditional Expression</h3>
      <p class="ednote">TODO</p>
    </div>

    <div class="rd-section" id="predef-functionsets">
      <h3>Predefined Function Sets</h3>
      <p class="ednote">TODO</p>
    </div>

    <div class="rd-section" id="additional-functionsets">
      <h3>Defining Additional Function Sets</h3>
      <p class="ednote">TODO</p>
    </div>

    <div class="rd-section" id="pa-reqs">
      <h3>Processing Agent Processing Requirements</h3>
      <div>
        <h4>Processing the <code>select</code> element</h4>
        <!-- As with all features: a PA that does not recognize a feature must abort processing, so it will
        never even hit a select element (since features are declared in head, so the PA aborts before body)
        -->

        <p>From a document information set perspective, the result of the processing of a
            <code>select</code> element is that the <code>select</code> element is <em>replaced by
            the content of exactly one of the <code>select</code> element's <code>when</code> or
              <code>otherwise</code> children</em>.</p>

        <p>Processing Agents must process <code>select</code> elements in the following way:</p>
        <ol>
          <li>Evaluate the conditional expressions of each <code>when</code> child, starting with
            the first <code>when</code> child in document order.</li>
          <li>If the evaluation of the conditional expression on the current <code>when</code>
            element results in <code>true</code>, select the content of the current
              <code>when</code> element, and return.</li>
          <li>If the evaluation of the conditional expression on the current <code>when</code>
            element results in <code>false</code>, continue processing the next sibling in document
            order (which is a <code>when</code> or <code>otherwise</code> element).</li>
          <li>If the conditional expression uses a function from an unrecognized or unsupported
            function set, continue processing the next sibling in document order (which is a
              <code>when</code> or <code>otherwise</code> element). <em>Processing Agents should
            issue a warning when encountering unrecognized or unsupported function sets</em>. </li>
          <li>If none of the <code>when</code> tests evaluate to true, select the content of the
              <code>otherwise</code> child, and return.</li>
        </ol>
      </div>
      <div>
        <h4>Processing Conditional Expressions</h4>

        <p>Processing Agents must process <code>conditional expressions</code> (the value of the
            <code>expr</code> attribute on the <code>when</code> element) in the following way:</p>
        <ul>
          <li class="ednote">TODO</li>
          <li class="ednote">TODO if undefined function prefix, static error</li>
        </ul>
      </div>
    </div>

  </div>

</html>
