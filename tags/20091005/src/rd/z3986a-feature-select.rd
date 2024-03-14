<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <!-- see /util/rd/build-rd.xsl -->
  <!-- an intro element must be provided, destination is a div -->
  <div class="intro">
    <p>The <code>Content Selection</code> feature provides a mechanism with which publishers can
      define alternate renditions of content fragments, and a mechanism for defining conditional
      expressions that allows runtime selection of these renditions.</p>
    <p>One core use-case for this feature is to <strong>vary the information set of output
        documents</strong>, based on criteria such as <em>output content type</em>, or <em>target
        consumer group</em>. As examples, </p>
    <ul>
      <li>specific variations of portions of the document can be associated exclusively with the
        Braille and e-text content types;</li>
      <li>"simplified" versions of complex passages can be provided to meet the needs of persons
        with certain cognitive disabilities.</li>
    </ul>
    <p>In the Z39.86 Authoring and Interchange context, the feature may also be used to provide
          <strong><a href="../../">feature</a> fallbacks</strong>. While a publisher would normally
      be in a situation where the feature support in used Processing Agents is known, this is not
      always the case, especially in a content interchange scenario. As an example, not knowing
      whether a processing chain has full support for the MathML feature, a publisher may choose to
      use the <code>Content Selection</code> feature to provide a fallback for MathML content.</p>
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
          <p>An expression used at runtime to test whether a content segment should be selected or
            not. The expression appears as the value of the <code>expr</code> attribute on the
              <code>when</code> element. A conditional expression is syntactically a combination of
            one or more <a href="#function">functions</a>, and zero or more <a href="#operators"
              >operators</a>. The result of the evaluation of a conditional expression must always
            be a boolean.</p>
          <p>The syntax of a conditional expression is normatively defined in <a href="#ce-ebnf"
              >EBNF Definition of the Conditional Expression</a>.</p>
        </dd>
        <dt id="function">Function</dt>
        <dd>
          <p>A function is the core component of a conditional expression. The return value of a
            function must always be boolean. A function can take zero or more arguments.</p>
          <p>A function <em>must not</em> take another function as an argument, with the exception
            of the <code>not()</code> function, which <em>always</em> takes another
            function as its argument.</p>
          <p>The literal reference to a function always uses a prefix. This prefix defines which <a href="#functionset">function
              set</a> the function belongs to.</p>
        </dd>
        <dt id="operators">Logical Operators</dt>
        <dd>
          <p>The operators <code>and</code> and <code>or</code> are used when
            referencing more than one function in a conditional expression. These operators have the
            following meaning:</p>
          <ul>
            <li><code>and</code>: the value of a conditional expression is true if, and only if,
                <em>all functions</em> in the expression evaluate to true.</li>
            <li><code>or</code>: the value of a conditional expression is true if, and only if, at
              least <em>one of the functions</em> in the expression evaluates to true.</li>
          </ul>
          <p>The <code>and</code> and <code>or</code> operators must not occur simultaneously in the
            same conditional expression. There is no limitation on the number of functions to be
            connected through logical operators.</p>
          
          <p>This feature also defines the function <code>not()</code>, with one, and only one,
            argument, which must be another function. The purpose of this function is to return the
            value false if the argument function evaluates to true, and vice versa. Note that, contrary 
            to all other functions, the <code>not()</code> function must not be
            prefixed.</p>
        </dd>
        <dt id="functionset">Function Set</dt>
        <dd>
          <p>A Function Set is a collection of 1-n functions. The set is defined by a canonical URI,
            where human-readable prose is available defining the name and nature of each function
            included in the set.</p>
          <p>When a function is used in a conditional expression, is uses a <a href="#prefix-decl"
              >name prefix</a> as a token for that URI. </p>
          
          <p>The Content Selection feature provides a set of <a href="#predef-functionsets"
              >predefined function sets</a>. <a href="#additional-functionsets">Additional function
              sets may be defined.</a></p>
        </dd>
      </dl>
    </div>
    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p id="feature-ns">The namespace of all members of the Content Selection feature element set
        is <code>http://www.daisy.org/z3986/2010/auth/features/select/#</code>.</p>
      
      <p>The <code>otherwise</code> element must not contain descendants in the
          <code>http://www.daisy.org/z3986/2010/auth/features/select/#</code> namespace.</p>
    </div>
    <div class="rd-section" id="prefix-decl">
      <h3>Declaration of function set prefix-URI mappings</h3>
      <p>The prefix of each function set that is used in a document instance must be declared in the
        document instance head using <code>meta</code> elements with the <code>prefix</code>
        property of the <a href="../../../../vocab/resourcedirectory/">Resource Directory
          Vocabulary</a>.</p>
      <p>The declared prefix must resolve to a URI which must contain a human-readable document
        where the processing behavior of included functions are defined. This URI serves as the canonical identifier of the
        function set.</p>
      <p>In the example below, a <code>target</code> prefix is bound to the URI
          <code>http://www.daisy.org/z3986/2010/auth/features/select/functionSets/#targetFunctionSet</code>:</p>
      <pre><![CDATA[
      <head xmlns:res="http://www.daisy.org/z3986/2010/vocab/resourcedirectory/#">
      	<meta about="http://www.daisy.org/z3986/2010/auth/features/select/functionSets/#targetFunctionSet" 
      		property="res:prefix" content="target" />
      </head>
      ]]></pre>
      
      <p>Note that function set prefixes, such as <code>target</code> in the example above, are
        static throughout the document scope.</p>
      
      <p>[Validity constraint] Several prefixes for the same function set URI must not be declared within the
      document scope.</p>
      
      <p>[Validity constraint] With the exception of the <code>not()</code> function, which is unique in that it 
        takes no prefix, all functions in Conditional Expressions must be literally referenced using prefixes, 
        and these prefixes must be bound to a URI using the mechanism defined above.</p>
      
      <p class="ednote">Note - the prefix declaration mechanism for function sets is subject to
        change, since changes to the prefix decl mechanism for CURIEs is currently being
        investigated.</p>
      
    </div>
    
    <div class="rd-section" id="ce-ebnf">
      <h3>EBNF Definition of the Conditional Expression</h3>
      <pre>
        Conditional Expression := function, (operator, function)*
        function := ('not','(' .*')') | (qname, ('()' | '(' .*')'))
        operator := 'and' | 'or'
        qname := prefix ':' localname
        prefix := ncname
        localname := ncname
        ncname := [A-Za-z][A-Za-z0-9_]*
      </pre>
    </div>
    
    <div class="rd-section" id="predef-functionsets">
      <h3>Predefined Function Sets</h3>
      <p><a href="../functionSets/">A set of predefined Function Sets are available</a>. These Function Sets do not
        differ behaviorally from <a href="additional-functionsets">externally defined function sets</a> in terms of 
        <a href="#pa-reqs">processing requirements</a>.</p>
    </div>
    
    <div class="rd-section" id="additional-functionsets">
      <h3>Defining Additional Function Sets</h3>
      <p class="ednote">TODO describe process</p>
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
            function set or an unrecognized parameter, continue processing the next sibling in document order (which is a
              <code>when</code> or <code>otherwise</code> element). <em>Processing Agents should
              issue a warning when encountering unrecognized or unsupported functions or parameters</em>. </li>
          <li>If none of the <code>when</code> tests evaluate to true, select the content of the
              <code>otherwise</code> child, and return.</li>
        </ol>
        <p class="ednote">TODO fix the above to reflect nested <code>when</code>'s</p>
        <p>Note that the mechanism for supply of runtime parameters to test the conditional expressions against is implementation dependant.</p>
      </div>
      <div>
        <h4>Processing Conditional Expressions</h4>
        <p>Processing Agents must process <code>conditional expressions</code> (the value of the
            <code>expr</code> attribute on the <code>when</code> element) in the following way:</p>
        <ul>
          <li class="ednote">TODO Per</li>
          <li class="ednote">TODO note that if undefined function prefix, static error</li>
        </ul>
      </div>
    </div>
  </div>
</html>
