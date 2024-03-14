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
            conditional expression is syntactically a combination of one or more <a href="#function"
              >functions</a>, and zero or more <a href="#operators">operators</a>. The result of the
            evaluation of a conditional expression must always be a boolean true or false.</p>
          <p>The syntax of a conditional expression is normatively defined in <a href="#ce-ebnf"
              >EBNF Definition of the Conditional Expression</a>.</p>
        </dd>

        <dt id="function">Function</dt>
        <dd>
          <p>A function is the core component of a conditional expression. The return value of a
            function must always be boolean true or false. A function can take zero or more
            arguments.</p>
          <p>A function <em>may not</em> take another function as an argument. The only exception
            from this is the <code>not()</code>, which <em>always</em> will take another function as
            its argument.</p>
          <p>A function is always prefixed; the prefix defines which <a href="#functionset">function
              set</a> the function belongs to.</p>
        </dd>

        <dt id="operators">Logical Operators and Functions</dt>
        <dd>
          <p>This feature allows the operators <code>and</code> and <code>or</code>, with the
            following meaning:</p>
          <ul>
            <li><code>and</code>: the value of a conditional expression is true if, and only if,
                <em>all functions</em> in the expression evaluate to true.</li>
            <li><code>or</code>: the value of a conditional expression is true if, and only if, at
              least <em>one of the functions</em> in the expression evaluates to true.</li>
          </ul>
          <p>Note that, in a conditional expression, you may use either <code>and</code> or
              <code>or</code>, but not both, to combine functions. </p>
          <p>There is no limitation on the number of functions to be connected through logical
            operators.</p>
          <p>This feature also allows the function <code>not()</code>, with one, and only one,
            argument. The purpose of this function is to return the value false if the argument
            evaluates to true, and vice versa.</p>
          <p>Note that, contrary to all other functions, the <code>not()</code> function must not be
            prefixed.</p>
        </dd>

        <dt id="functionset">Function Set</dt>
        <dd>
          <p>A Function Set is a collection of 1-n functions. The set is defined by a canonical URI.
            When a function is used in a conditional expression, is uses a name prefix as a token
            for that URI. The association between prefixes and URIs is defined in the document head,
            and is thus static throughout the document scope.</p>
          <p>The content selection feature provides a set of <a href="#predef-functionsets"
              >predefined function sets</a>. <a href="#additional-functionsets">Additional function
              sets may be defined.</a></p>
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
      <p>The use of a specific function group <em>must</em> be declared in the <code>head</code> of
        the document:</p>
      <pre>
        &lt;meta name="[Content Selection Function Set Declaration]" content="[Canonical URI]" prefix="[prefix]" /&gt;
      </pre>
      <p>e.g.</p>
      <pre>
        &lt;head&gt;
          :
          &lt;meta name="Output Format Function Set" 
              content="http://www.daisy.org/z3986/2010/auth/features/select/0.0/z3986a-select.html#outputFormatFunctionSet" 
              prefix="offs" /&gt;
          :
        &lt;/head&gt; 
      </pre>
    </div>

    <div class="rd-section" id="ce-ebnf">
      <h3>EBNF Definition of the Conditional Expression</h3>
      <pre>
        Conditional Expression := function, (operator, function)*
            function := ('not','(' .*')') | (QName, ('()' | '(' .*')'))
            operator := 'and' | 'or'
      </pre>
    </div>

    <div class="rd-section" id="predef-functionsets">
      <h3>Predefined Function Sets</h3>
      
      <p class="ednote">TODO: Implement these function sets in XSLT</p>
      <div class="rd-section" id="outputFormatFunctionSet">
        <h4>The Ouput Format Function Set</h4>
        <p>There is currently only one function in this set, the <code>outputFormat(arg)</code>
          function. It takes one argument, a string, and it must be prefixed with the prefix
            <code>offs</code>. The argument, <code>arg</code>, must be on the form:</p>
        <pre>
          arg := 'BRAILLE' | 'LARGE_PRINT' | 'TALKING_BOOK' | 'EBOOK' | 'PDF' | string
            string := ? all visible characters ?
        </pre>
        <p>It is recommended to use arguments from the set of predefined values, but the possibility
          to use any string as an argument, allows for more specialized implementations of this
          function.</p>
        <p>A typical example could look like this:</p>
        <pre>
          <![CDATA[<sel:select>
              <sel:when expr="offs:outputFormat('BRAILLE')">
                  <annotation about="table01" property="republisherAnno">
                    The table on this page, not represented as a table in the braille version, presents information about ..... 
                  </annotation>
              </sel:when>
              <sel:when expr="offs:outputFormat('TALKING_BOOK')">
                  <annotation about="table01" property="republisherAnno">
                    The information presented in the table on this page, 
                    is in this talking book, presented in the following list of the
                    number of persons developing the Basivar-Sumeko Syndrom  per year
                  </annotation>
                  <ul>
                    <li>1950: 23</li>
                    <li>1970: 25</li>
                    <li>1990: 42</li>
                    <li>2010: 80 (estimated)</li>
                  </ul>
              </sel:when>
              <sel:otherwise>
                  <table xml:id="table01">
                    <caption>Number of persons developing the Basivar-Sumeko Syndrom  per year</caption>
                    <tr>
                      <th>Year</year>
                      <th>Number of persons</th>
                     </tr>
                     <tr><td>1950</td><td>23</td></tr>
                     <tr><td>1970</td><td>25</td></tr>
                     <tr><td>1990</td><td>42</td></tr>
                     <tr><td>2010</td><td>80 (estimated)</td></tr>
                  </table>
               </sel:otherwise>
          </sel:select>]]>
        </pre>
      </div>
      <div class="rd-section" id="targetConsumerGroupFunctionSet">
        <h4>The Target Consumer Group Function Set</h4>
        <p>There is currently only one function in this set, the
            <code>targetConsumerGroup(arg)</code> function. It takes one argument, a string, and it
          must be prefixed with the prefix <code>tcgfs</code>. The argument, <code>arg</code>, must
          be on the form:</p>
        <pre>
          arg := 'BLIND' | 'DYSLECTIC' | 'DEAF' | 'DEAFBLIND' | 'COGNITIVE' | string
            string := ? all visible characters ?
        </pre>
        <p>It is recommended to use arguments from the set of predefined values, but the possibility
          to use any string as an argument, allows for more specialized implementations of this
          function.</p>
        <p>A typical example could look like this:</p>
        <pre>
          <![CDATA[<sel:select>
              <sel:when expr="tcgfs:targetConsumerGroup('BLIND') or tcgfs:targetConsumerGroup('DEAFBLIND')">
                  <annotation about="img01" property="republisherAnno">
                    A photo of Barack Obama and Gollum. 
                  </annotation>
              </sel:when>
              <sel:otherwise>
                  <object xml:id="img01" src="images/Obama_Gollum.png" />
               </sel:otherwise>
          </sel:select>]]>
        </pre>
      </div>
      <div class="rd-section" id="parameterTestFunctionSet">
        <h4>The Parameter Test Function Set</h4>
        <p>There is currently only one function in this set, the <code>parameterTest(name,
        value)</code> function. It takes two arguments, both strings</p>
        <ul>
          <li>The <code>name</code> argument represents the name of some parameter to the
          transformation process.</li>
          <li>The <code>value</code> represents an arbitrary string.</li>
        </ul>
        
        <p>This function must be prefixed with the prefix <code>ptfs</code>.</p>
        <p>The purpose of this function is to test whether a string, the <code>value</code> argument, is
          equal to the value of the <code>name</code> parameter. </p>
        <p>A typical example could look like this:</p>
        <pre>
          <![CDATA[<sel:select>
              <sel:when expr="ptfs:parameterTest('publisher','nlb')">
                  <p>Copyright &#169; 2009 Norsk lyd- og blindeskriftbibliotek</p>
              </sel:when>
              <sel:when expr="ptfs:parameterTest('publisher','hks')">
                  <p>Copyright &#169; 2009 Huseby kompetansesenter</p>
              </sel:when>
              <sel:otherwise />
          </sel:select>]]>
        </pre>
      </div>
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
