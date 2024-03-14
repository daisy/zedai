<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">
  <!-- see /util/rd/build-rd.xsl -->
  <!-- an intro element must be provided, destination is a div -->
  
  <div class="intro">
    <p>
      The <code>Content Selection</code> feature provides a mechanism with which publishers can
      define alternate renditions of content fragments, and a mechanism for defining conditional
      expressions that allows runtime selection of these renditions.
    </p>
    
    <p>
      One core use-case for this feature is to <strong>vary the information set of output
      documents</strong>, based on criteria such as <em>output content type</em>, or <em>target
      consumer group</em>. As examples, 
    </p>
    
    <ul>
      <li>
        specific variations of portions of the document can be associated exclusively with the
        Braille or e-text content types;
      </li>
      <li>
        "simplified" versions of complex passages can be provided to meet the needs of persons
        with cognitive disabilities.
      </li>
    </ul>
    
    <p>
      In the Z39.86 Authoring and Interchange context, this feature may also be used to provide
      <em><a href="../../">feature</a> fallbacks</em>. While a publisher would normally
      be in a situation where the feature support in used Processing Agents is known, this is not
      always the case, especially in a content interchange scenario. Not knowing
      whether a processing chain has full support for a certain feature, a publisher may choose to
      use the <code>Content Selection</code> feature to provide a fallback for that 
      feature.
    </p>
    
    <p>
      The <code>Content Selection</code> feature employs a conditional switch mechanism,
      represented by 1-n <code>when</code> elements appearing as children to the parent
        <code>select</code> element. There is an always-present default choice within the switch,
      represented by the <code>otherwise</code> element.
    </p>
    
  </div>
  
  <div class="normative-bottom">
    
    <div class="rd-section">
      <h3>Definition of terms</h3>
      <dl>
        <dt id="contentfragment">Content fragment</dt>
        <dd>
          <p>
            For the purposes of this feature, a content segment is an <code>XML</code> fragment, appearing 
            within a <code>when</code> or <code>otherwise</code> element. When a processing agent
            <a href="#pa-reqs-supported">evaluates</a> a parent <code>select</code> element, 
            the result is that <em>one</em> of the descendant
            content segments is selected for inclusion in the resulting document. (See further in <a 
              href="#pa-reqs">Processing Agent Behavior Requirements</a> below.)
          </p>
          <p>
            Note that the <code>when</code> and <code>otherwise</code> elements are allowed to be empty, 
            i.e. provide content fragments that when selected contribute nothing to the resulting document.
          </p>
        </dd>
        
        <dt id="conditionalexpression">Conditional expression</dt>
        <dd>
          <p>
            An expression used at runtime to test whether a content fragment should be selected or
            not. The expression appears as the value of the <a href="z3986.expr.attrib"><code
              >expr</code></a> attribute on the <a href="z3986.when.block"><code>when</code></a> 
            element.
          </p> 
          
          <p>
            A conditional expression is syntactically a combination of one or more <a href="#function"
              >functions</a>, and zero or more <a href="#operators">operators</a>. The result of the 
            evaluation of a conditional expression must always be a boolean.
          </p>
          
          <p>
            The syntax of a conditional expression is normatively defined in <a href="#ce-ebnf"
              >EBNF Definition of the Conditional Expression</a>.
          </p>
        </dd>
        
        <dt id="function">Function</dt>
        <dd>
          <p>
            A function is the core component of a conditional expression. The return value of a
            function must always be boolean. A function can take zero or more arguments.
          </p>
          
          <p>
            A function <em>must not</em> take another function as an argument, with the exception
            of the <code>not()</code> function, which <em>always</em> takes another
            function as its argument.
          </p>
          
          <p>
            The literal reference to a function always uses a prefix. This prefix defines which 
            <a href="#functionset">function set</a> the function belongs to. 
            <span class="ednote"><!-- TODO -->Note - the prefix declaration mechanism for function sets is subject to
              change, since a simplification of the prefix declaration mechanism for CURIEs is currently being
              investigated within RDFa 1.1 See <a href="http://code.google.com/p/zednext/issues/detail?id=107"
                >Issue 107</a>.</span>
          </p>
        </dd>
        
        <dt id="operators">Logical Operators</dt>
        <dd>
          <p>
            The operators <code>and</code> and <code>or</code> are used when
            referencing more than one function in a conditional expression. These operators have the
            following meaning:
          </p>
          
          <dl>
            <dt id="operator_and"><code>and</code>:</dt> 
            <dd>
              <p>
                the return value of a conditional expression is true if, and only if,
                <em>all functions</em> in the expression evaluate to true.
              </p>
            </dd>  
            <dt id="operator_or"><code>or</code>:</dt> 
            <dd>
              <p>
                the return value of a conditional expression is true if, and only if, at
                least <em>one of the functions</em> in the expression evaluates to true.
              </p>
            </dd>
          </dl>
          
          <p>
            The <code>and</code> and <code>or</code> operators must not occur simultaneously in the
            same conditional expression. There is no limitation on the number of functions to be
            connected through logical operators.
          </p>
          
          <p>
            This feature also defines the function <code>not()</code>, with one, and only one,
            argument, which must be another function. The purpose of this function is to return the
            value false if the argument function evaluates to true, and vice versa. Note that, contrary 
            to all other functions, the <code>not()</code> function must not be
            prefixed.
          </p>
          
        </dd>
        
        <dt id="functionset">Function Set</dt>
        <dd>
          <p>
            A Function Set is a collection of 1-n functions. The set is defined by a canonical URI,
            where human-readable prose is available defining the name and nature of each function
            included in the set.
          </p>
          
          <p>
            When a function is used in a conditional expression, is uses a <a href="#prefix-decl"
              >name prefix</a> as a token for that URI.
            
            <span class="ednote"><!-- TODO -->Note - the prefix declaration mechanism for functions is subject to
              change, since a simplification of the prefix declaration mechanism for CURIEs is currently being
              investigated within RDFa 1.1 See <a href="http://code.google.com/p/zednext/issues/detail?id=107"
                >Issue 107</a>.</span>
          </p>
          
          <p>
            The Content Selection feature provides a set of <a href="#predef-functionsets"
              >predefined function sets</a>. <a href="#additional-functionsets">Additional function
                sets may be defined.</a>
          </p>
          
        </dd>
      </dl>
    </div>
    
    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p id="feature-ns">The namespace of all members of the Content Selection feature element set
        is <code>http://www.daisy.org/ns/z3986/authoring/features/select/</code>.</p>
      
      <p>The <code>otherwise</code> element must not contain descendants in the
          <code>http://www.daisy.org/ns/z3986/authoring/features/select/</code> namespace.</p>
    </div>
    
    <div class="rd-section" id="prefix-decl">
      <h3>Declaration of function set prefix-URI mappings</h3>
      
      <p class="ednote"><!-- TODO -->Note - the prefix declaration mechanism for function sets is subject to
        change, since a simplification of the prefix declaration mechanism for CURIEs is currently being
        investigated within RDFa 1.1 See <a href="http://code.google.com/p/zednext/issues/detail?id=107"
          >Issue 107</a>.</p>
      
      <p>
        The prefix of each function set that is used in a document instance must be declared in the
        document instance head using <code>meta</code> elements with the <code>prefix</code>
        property of the <a href="../../../../vocab/resourcedirectory/">Resource Directory
          Vocabulary</a>.
      </p>
      
      <p>
        The declared prefix must resolve to a URI which must contain a human-readable document
        where the processing behavior of included functions are defined. This URI serves as the canonical identifier of the
        function set.
      </p>
      
      <p>
        In the example below, a <code>target</code> prefix is bound to the URI
        <code>http://www.daisy.org/z3986/2010/auth/features/select/functionSets/#targetFunctionSet</code>:</p>
      <pre xml:space="preserve"><![CDATA[
<head xmlns:res="http://www.daisy.org/z3986/2010/vocab/resourcedirectory/#">
  <meta about="http://www.daisy.org/z3986/2010/auth/features/select/functionSets/#targetFunctionSet" 
    property="res:prefix" content="target" />
</head>
      ]]></pre>
      
      <p>
        Function set prefixes, such as <code>target</code> in the example above, are
        static throughout the document scope; they must not be redeclared locally.
      </p>
      
      <p>
        Several prefixes for the same function set URI must not be declared within the
        document scope.
      </p>
      
      <p>
        With the exception of the <code>not()</code> function, which is unique in that it 
        takes no prefix, all functions in Conditional Expressions must be literally referenced using prefixes, 
        and these prefixes must be bound to a URI using the mechanism defined above.
      </p>
      
    </div>
    
    <div class="rd-section" id="ce-ebnf">
      <h3>EBNF Definition of the Conditional Expression</h3>
      <pre xml:space="preserve">
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
      <p>
        <a href="../functionSets/">A set of predefined Function Sets are available</a>. These Function 
        Sets do not differ behaviorally from <a href="#additional-functionsets">externally defined 
        function sets</a> in terms of <a href="#pa-reqs">processing requirements</a>.
      </p>
    </div>
    
    <div class="rd-section" id="additional-functionsets">
      <h3>Defining Additional Function Sets</h3>
      <p class="ednote">TODO describe process</p>
    </div>
  
  </div> 
  
  <div class="rd-section" id="pa-reqs">

    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a Processing Agent <em>supports</em> this feature, it must comply to the
        following:</p>
      <dl>
        <dt>Processing of the <code>select</code> element</dt>
        <dd>
          <p>
            <em>While traversing the document tree, each encountered <code>select</code> element
              is replaced by the content of exactly one of its <code>when</code> or <code>otherwise</code> 
              element descendants.</em>
         </p>
         <p>
         	The process of selecting a <code>when</code> or <code>otherwise</code> 
            element descendant is as follows:
         </p>
          
          <ol>
                        
            <li>
              <p>For each encountered <code>select</code> element in the given XML (sub)tree, evaluate the 
                conditional expressions of each <code>when</code> child, starting with the first 
                <code>when</code> child in document order:</p>
              <ul>
                <li>
                  If the given conditional expression uses a function from an unrecognized or unsupported
                  function set, or if it contains an unrecognized parameter, continue processing the next 
                  sibling in document order (which is a <code>when</code> or <code>otherwise</code> element). 
                  <em>
                    Processing Agents must issue a warning when encountering unrecognized or unsupported 
                    functions or parameters.
                  </em>
                </li>
              
                <li>
                  If the evaluation of the conditional expression on the current <code>when</code>
                  element results in <code>true</code>, select the content of the current <code>when</code> 
                  element. If the selected content contains <code>select</code> element descendants, apply 
                  these steps on the selected content recursively, then return.             
                </li>
              
                <li>
                  If the evaluation of the conditional expression on the current <code>when</code>
                  element results in <code>false</code>, continue processing the next sibling in document
                  order (which is a <code>when</code> or <code>otherwise</code> element).
                </li>
              </ul>
            </li>
                 
            <li>
              If none of the <code>when</code> element conditional expressions evaluate to true, select the content 
              of the <code>otherwise</code> child, and return.
            </li>
          </ol>
           
        </dd>
        
        <dt>Processing of conditional expressions</dt>
        <dd>
          <p class="ednote">TODO Per</p>
        </dd>
      </dl>  
    </div>
    
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      <p>
        If a Processing Agent <em>recognizes but does not support</em> this feature, it must
        employ one of the following behaviors:
      </p>
      <dl>
        <dt id="pa-reqs-recognized-abort">Abort</dt>
        <dd>
          <p>Upon encountering a document instance with this feature enabled, the Processing Agent issues
            a notification, and then aborts the processing.</p>
        </dd>                    
        <dt id="pa-reqs-recognized-fallback">Fallback</dt>
        <dd>
          <p>
            While traversing the document tree, the Processing Agent selects the content of the <code>otherwise</code>
            child element of each encountered <code>select</code> element. The resulting document is identical to a 
            processing pass in <a href="#pa-reqs-supported">Feature supported</a> mode where zero <code>when</code> element 
            conditional expressions evaluate to true.
          </p>          
        </dd>
      </dl>  
      <p>
        The <code>Abort</code> behavior is the default; the <code>Fallback</code> behavior
        must only be employed when the Processing Agent is explicitly instructed to do so by the client.<br/>
        Processing Agents that employ the <code>Fallback</code> behavior should issue a 
        notification.
      </p>
    </div>
    
  </div>
  
  <div id='public-components'>
    <ul>
      <li><code>select</code> TODO make these links to Per's schemadoc once his file/ID structure is predictable</li>
    </ul>  
  </div>
  
  <div class="rd-section" id="absdef">
    <?absdef src="/mod/z3986-feature-select.rng" ?>
  </div>
</html>
