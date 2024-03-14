<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">

  <!-- see /util/rd/build-rd.xsl -->
  <!-- see _readme in this dir -->

  <div class="intro">
    <p>The <code>Print Forms</code> feature provides a mechanism with which publishers can define
      form elements to represent a subset of the various form objects present in print
      publications.</p>
    <p>The form objects are best identified via the two primary use-cases for this feature:</p>
    <ol>
      <li><strong>Consumable textbooks (consumables):</strong> Consumables are a form of school
        textbook in which a student is expected to answer and submit questions on the printed page.
        Traditionally, consumables have provided a significant barrier to accessibility in the
        classroom.</li>
      <li><strong>Print Forms:</strong> Print forms are any type of form intended for collecting
        information for submission. Common examples of print forms include employment applications,
        survey questionnaires, and order forms.</li>
    </ol>
    <p>In addition to defining form elements, this feature provides the functionality of defining
      methods of submission for the collection of entered information. In the context of <code>Print
        Forms</code>, submission is broken into two parts: method and instance. The method defines
      the &quot;type&quot; of submission for the document, with options ranging from saving the form
      input as a file to transmitting over the network to an author-specified server. Comprised by
      the <code>&lt;instance&gt;</code> element, the instance information defines the structure of
      the sent information. This structure is an XML format of the author's choice. For example, a
      section of a document with form elements for entering a name and date:</p>
    <pre xml:space="preserve">
      &lt;xforms:input&gt;
      &lt;xforms:label&gt;First Name:&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      &lt;xforms:input&gt;
      &lt;xforms:label&gt;Last Name:&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      &lt;xforms:input&gt;
      &lt;xforms:label&gt;Today's Date (YYMMDD):&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;</pre>
    <p>could possibly have an instance structure defined as follows:</p>
    <pre xml:space="preserve">
      &lt;user date=""&gt;
      &lt;firstName/&gt;
      &lt;lastName/&gt;
      &lt;/user&gt;</pre>
    <p>where the &quot;Today's date&quot; information is placed as an attribute for the
        <code>&lt;user&gt;</code> element, and the &quot;First Name&quot; and &quot;Last Name&quot;
      information is placed in the <code>&lt;firstName&gt;</code> and <code>&lt;lastName&gt;</code>
      elements, repsectively.</p>
    <p>Including submission-related items is entirely an author-level decision, as many factors of
      the authoring environment are involved. In general, to determine if submission-related items
      should be included in a document, both of the following should be true:</p>
    <ul>
      <li>The purpose of the document is to retreive information (such as an application form or a
        consumable textbook).</li>
      <li>The author has a set location for retreiving the information (such as a web server) or
        intends for the information to be saved locally to the user's computer.</li>
    </ul>
    <p>As an example, a primary grade textbook which contains form elements only for the purpose of
      personal inquiry on the reader's behalf would not fit the first criterion above, thus
      submission-related elements should not be included. However, an employment application form is
      expected to retrieve information and, in this case, an author would have a set location for
      retrieving the information (such as the same web server used for acquiring the application's
      web form analogue).</p>
  </div>

  <div class="normative-top">
    <div class="rd-section">
      <h3>General document model requirements</h3>
      <p>The markup model of this feature is based on a subset of <a
          href="http://www.w3.org/TR/xforms11/">XForms 1.1</a>, and inherits all semantics and
        behaviors of that specification unless otherwise specified.</p>
    </div>
  </div>

  <!-- no need for this: this feature doesnt specialize any fallback behaviors
  <div id="pa-reqs">    
    
    <div class="rd-section">
      <h4 id="pa-reqs-supported">Feature supported</h4>
      <p>If a processing agent <em>supports</em> this feature, it must comply to the
        following:</p>
      <p class="alert">TODO</p>
    </div>
    
    <div class="rd-section">
      <h4 id="pa-reqs-recognized">Feature recognized</h4>
      <p>If a processing agent <em>recognizes but does not support</em> this feature, it must
        employ one of the following behaviors:</p>
      <p class="alert">TODO</p>
      <xi:include href="pa-reqs-recognized.xinc"/>
    </div>
        
  </div> -->

  <div id="public-components">
    <ul>
      <li>The <code>input</code>, <code>range</code>, <code>secret</code>, <code>select</code>,
          <code>select1</code> and <code>textarea</code> elements from the <a
          href="http://www.w3.org/TR/xforms11/#N74868">XForms 1.1 Core Form Controls Module</a></li>
      <li>The <code>group</code> and <code>repeat</code> elements from <a
          href="http://www.w3.org/TR/xforms11/#ui">XForms 1.1 Container Form Controls</a></li>
      <li>The <a href="http://www.w3.org/TR/xforms11/#structure-model">XForms 1.1 <code>model</code>
          element</a></li>
    </ul>
  </div>

  <div class="examples">
    <p>Each of the following examples depicts a real-world application of the <code>Print
        Forms</code> feature along with a short reasoning of their formulation.</p>
    <p>The following conventions are used in the examples:</p>
    <ul>
      <li>All examples are based on the <a href="../../../profiles/genericdocument/">Generic Document
          Profile</a>.</li>
      <li>The namespace prefix <code>xforms:</code> is used for Print Forms feature elements.</li>
      <li>The namespace prefix <code>my:</code> is used for instance elements.</li>
      <li>XML comments (<code>&lt;!-- --&gt;</code>) are used in the code examples to identify
        points of interest and further explain items referenced in the Discussion.</li>
    </ul>
    <h3>Example 1</h3>
    <img src="resources/example01.jpg"
      alt="Print textbook example 1 for use with the Print Forms feature"/>
    <p>This example is of a page from a primary grade consumable. The student is expected to answer
      each of the questions on the print page and submit it to his/her instructor. Since submission
      is a key part of this example, the optional <code>&lt;model&gt;</code> element and its
      children are included.</p>
    <p>The first two questions are encoded as an <code>&lt;input&gt;</code> element, which
      represents a free text input, analagous to a HTML text field. The last question is encoded as
      a <code>&lt;select1&gt;</code> element, which represents a &quot;select one of many
      choices&quot; input, analagous to a HTML pull-down list field.</p>
    <p>Each of the different types of inputs contain an optional <code>ref</code> attribute, which
      links the user-submitted information to a point in the optional <code>&lt;instance&gt;</code>
      section.</p>
    <pre xml:space="preserve">
&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;html xmlns="http://www.daisy.org/ns/z3998/authoring/" 
  xmlns:xforms="http://www.w3.org/2002/xforms/" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:my="http://www.daisy.org/ns/z3998/authoring/xforms/instance/"
  xml:lang="en-US"&gt;
  &lt;head&gt;
    &lt;meta property="dcterms:title"&gt;Print Forms Feature Example 1&lt;/meta&gt;
    &lt;xforms:model&gt;
      &lt;xforms:instance&gt;
        &lt;!--The contents of &lt;instance&gt; indicate the form that the response submission
          should have.  Its structure is defined entirely by the document author.--&gt;
        &lt;my:worksheet&gt;
          &lt;my:questions&gt;
            &lt;my:q1 /&gt;
            &lt;my:q2 /&gt;
            &lt;my:q3 /&gt;
          &lt;/my:questions&gt;
        &lt;/my:worksheet&gt;
      &lt;/xforms:instance&gt;
      &lt;!--The &lt;submission&gt; element provides the information regarding the act of 
        submitting the form.  In this example, when submitted, the form contents 
        will be saved as "page008.xml" on the reader's home computer, populated 
        with the submission questions in structure defined in &lt;instance&gt; (above).--&gt;
      &lt;xforms:submission action="page008.xml" method="put" ref="/my:worksheet" /&gt;
    &lt;/xforms:model&gt;
  &lt;/head&gt;
  &lt;body&gt;
    &lt;h&gt;Multiplication Problems&lt;/h&gt;
    &lt;p&gt;For each of these story problems, write an equation and your solution.&lt;/p&gt;
    &lt;ol&gt;
      &lt;li&gt;
        &lt;!--The &lt;input&gt; element is required to have the &lt;label&gt; element as a child.
          &lt;label&gt; represents the text content of the question.  On the &lt;input&gt; element
          is the optional "ref" attribute, which specifies where in the submission 
          structure the input value should be placed-in this case, to the &lt;q1&gt; 
          element.--&gt;
        &lt;xforms:input ref="my:worksheet/my:questions/my:q1"&gt;
          &lt;xforms:label&gt;There are 2 people who want to eat 3 apples. How 
            many apples are needed?&lt;/xforms:label&gt;
        &lt;/xforms:input&gt;
      &lt;/li&gt;
      &lt;li&gt;
        &lt;xforms:input ref="my:worksheet/my:questions/my:q2"&gt;
          &lt;xforms:label&gt;I have 2 pies. Each pie can be cut into 10 pieces. 
            How many pieces are there?&lt;/xforms:label&gt;
        &lt;/xforms:input&gt;
      &lt;/li&gt;
    &lt;/ol&gt;
    &lt;section&gt;
      &lt;h&gt;Review Question&lt;/h&gt;
      &lt;ol&gt;
        &lt;li&gt;Select the equation that answers the question.
          &lt;!--The &lt;select1&gt; element is structured similar to &lt;input&gt;, in that it 
            has the optional "ref" attribute applied, as well as has the &lt;label&gt;
            element as a child.  In addition, the &lt;select1&gt; also contains an 
            &lt;item&gt; element, comprised of the &lt;label&gt; and &lt;value&gt; elements, which 
            represent each possible choice.  The contents of the &lt;value&gt; elements 
            are the data that is placed into the submission (e.g. A choice of 
            "B. 3 × 6 = ?" would result in &lt;q4&gt;B&lt;/q4&gt; being submitted).--&gt;
          &lt;xforms:select1 ref="my:worksheet/my:questions/my:q4"&gt;
            &lt;xforms:label&gt;Soda comes in packs of 6 cans. How many cans are there if I 
              have 3 packs?&lt;/xforms:label&gt;
            &lt;xforms:item&gt;
              &lt;xforms:label&gt;A. 18 × 3 = ?&lt;/xforms:label&gt;
              &lt;xforms:value&gt;A&lt;/xforms:value&gt;
            &lt;/xforms:item&gt;
            &lt;xforms:item&gt;
              &lt;xforms:label&gt;B. 3 × 6 = ?&lt;/xforms:label&gt;
              &lt;xforms:value&gt;B&lt;/xforms:value&gt;
            &lt;/xforms:item&gt;
            &lt;xforms:item&gt;
              &lt;xforms:label&gt;C. 3 × 3 = ?&lt;/xforms:label&gt;
              &lt;xforms:value&gt;C&lt;/xforms:value&gt;
            &lt;/xforms:item&gt;
            &lt;xforms:item&gt;
              &lt;xforms:label&gt;D. 6 × 3 = ?&lt;/xforms:label&gt;
              &lt;xforms:value&gt;D&lt;/xforms:value&gt;
            &lt;/xforms:item&gt;
          &lt;/xforms:select1&gt;
        &lt;/li&gt;
      &lt;/ol&gt;
    &lt;/section&gt;
  &lt;/body&gt;
&lt;/html&gt;</pre>
    <h3>Example 2</h3>
    <img src="resources/example02.jpg"
      alt="Print textbook example 2 for use with the Print Forms feature"/>
    <p>This example is of a section of a page from a primary grade consumable. As with the previous
      example, the student is expected to answer the question on the print page and submit it to
      his/her instructor. Since submission is a key part of this example, the optional
        <code>&lt;model&gt;</code> element and its children are included.</p>
    <p>Of particular note in this example is that the question is actually comprised of two
      sub-questions (as evidenced by the phrase &quot;show your work&quot;). For the purposes of the
      example, it is assumed that both sub-questions are required to be answered, with no room for
      partial credit. Given this assumption, the <code>&lt;bind&gt;</code> element is used, which
      provides additional rules on submission (in this case, forcing both questions to be
      answered).</p>
    <pre xml:space="preserve">
&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;html xmlns="http://www.daisy.org/ns/z3998/authoring/" 
  xmlns:xforms="http://www.w3.org/2002/xforms/" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:my="http://www.daisy.org/ns/z3998/authoring/xforms/instance/"
  xml:lang="en-US"&gt;
  &lt;head&gt;
    &lt;meta property="dcterms:title"&gt;Print Forms Feature Example 2&lt;/meta&gt;
    &lt;xforms:model&gt;
      &lt;xforms:instance&gt;
        &lt;my:worksheet&gt;
          &lt;my:questions&gt;
            &lt;my:q1&gt;
              &lt;my:part/&gt;
            &lt;/my:q1&gt;
          &lt;/my:questions&gt;
        &lt;/my:worksheet&gt;
      &lt;/xforms:instance&gt;
      &lt;!--The optional &lt;bind&gt; element allows one to place restrictions on 
        the information to be submitted. In this case, &lt;bind&gt; is requiring
        that there be two (and only two) &lt;my:part&gt; elements on submission.
        Note that each of the form features below reference &lt;my:part&gt; as 
        their sbumission, thus creating two &lt;my:part&gt; elements on 
        submission.--&gt;
      &lt;xforms:bind nodeset="my:worksheet/my:questions/my:q1/my:part" 
        constraint="count(.) = 2"/&gt;
      &lt;!--In this example, instead of saving to file as in Example 1, the 
        form information is submitted to a web server via the "post" method.
        Note: this is very similar to HTML forms.--&gt;
      &lt;xforms:submission action="http://www.example.com/submit/page5.php" 
        method="post" ref="/my:worksheet" /&gt;
    &lt;/xforms:model&gt;
  &lt;/head&gt;
  &lt;body&gt;
    &lt;h&gt;Show Your Work Problem&lt;/h&gt;
    &lt;p&gt;Solve the question and show your work.&lt;/p&gt;
    &lt;ol&gt;
      &lt;li&gt;
        &lt;!--The &lt;group&gt; element allows an author to logically group
          together different form elements.--&gt;
        &lt;xforms:group&gt;
          &lt;!--The &lt;textarea&gt; element, like most other form elements requires
            the child element &lt;label&gt;, which represents the text of the 
            question.  &lt;textarea&gt; is very similar to the &lt;input&gt; element, 
            in that it is primarily a multi-line input.--&gt;
          &lt;xforms:textarea ref="my:worksheet/my:questions/my:q1/my:part"&gt;
            &lt;xforms:label&gt;There are 5 people who want to eat 2 bananas. 
              How many bananas are needed?&lt;/xforms:label&gt;
          &lt;/xforms:textarea&gt;
          &lt;xforms:input ref="my:worksheet/my:questions/my:q1/my:part"&gt;
            &lt;xforms:label&gt;If there are 17 bananas, how many would be 
              left over?&lt;/xforms:label&gt;
          &lt;/xforms:input&gt;
        &lt;/xforms:group&gt;
      &lt;/li&gt;
    &lt;/ol&gt;
  &lt;/body&gt;
  &lt;/html&gt;</pre>
    
    <h3>Example 3</h3>
    <img src="resources/example03.jpg"
      alt="Print textbook example 3 for use with the Print Forms feature"/>
    <p>This example is of a section of a page from a primary grade textbook. Unlike the previous
      examples, the questions posed in the text do not require submission and instead are presented
      for mental reference. Since answer submission is not necessary in this example, the optional
        <code>&lt;model&gt;</code> element is not included, leaving only the actual form controls.
      In addition to not including <code>&lt;model&gt;</code>, the <code>ref</code> attribute, which
      links form elements to the submission structure, is also not included on the individual
        <code>&lt;input&gt;</code> elements.</p>
    <p>The first section of this example is similar to the previous examples, with two
        <code>&lt;input&gt;</code> elements. The second section, however, involves some
      re-formatting of the content. In print, the paragraph is composed of a series of labeled
      markers which appear inline. Each of these labeled markers correspond to input lines present
      following the paragraph. In the <code>Print Forms</code> feature, this separation isn't
      necessary (and may also be confusing in certain circumstances). As such, the form inputs are
      inserted directly in place of the label markers.</p>
    <pre xml:space="preserve">
&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;html xmlns="http://www.daisy.org/ns/z3998/authoring/" 
  xmlns:xforms="http://www.w3.org/2002/xforms/" 
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:my="http://www.daisy.org/ns/z3998/authoring/xforms/instance/"
  xml:lang="en-US"&gt;
  &lt;head&gt;
    &lt;meta property="dcterms:title"&gt;Print Forms Feature Example 3&lt;/meta&gt;
    &lt;!--The &lt;model&gt; element is not included, as there is no need for submission.--&gt;
  &lt;/head&gt;
  &lt;body&gt;
    &lt;h&gt;Dancing&lt;/h&gt;
    &lt;p&gt;Dancing is fun. There are a lot of different words associated with dancing. The vocabulary 
      list has a number of words already. Add two more dancing-related words.&lt;/p&gt;
    &lt;ul&gt;
      &lt;li&gt;exercise&lt;/li&gt;
      &lt;li&gt;breathing&lt;/li&gt;
      &lt;li&gt;energy&lt;/li&gt;
      &lt;li&gt;effort&lt;/li&gt;
      &lt;li&gt;
        &lt;xforms:input&gt;
          &lt;xforms:label&gt;Vocabulary list item 1&lt;/xforms:label&gt;
        &lt;/xforms:input&gt;
      &lt;/li&gt;
      &lt;li&gt;
        &lt;xforms:input&gt;
          &lt;xforms:label&gt;Vocabulary list item 2&lt;/xforms:label&gt;
        &lt;/xforms:input&gt;
      &lt;/li&gt;
    &lt;/ul&gt;
    &lt;p&gt;Use the vocabulary words (including those you added) to fill in the blanks in the following 
      paragraph.&lt;/p&gt;
    &lt;!--In this paragraph, the &lt;input&gt; elements are placed inline, acting as both the input marker
      and the actual input line shown in the text.  In order to improve clarity, the label has 
      been changed from "(1)" to "Blank 1".  Additionally, as submission is not necessary, the 
      optional ref attribute has been omitted.--&gt;
    &lt;p&gt;I've recently found that dancing is great 
      &lt;xforms:input&gt;
        &lt;xforms:label&gt;Blank 1&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      ! When I dance, I start 
      &lt;xforms:input&gt;
        &lt;xforms:label&gt;Blank 2&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      heavily and feel an increase in 
      &lt;xforms:input&gt;
        &lt;xforms:label&gt;Blank 3&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      . It's a lot of 
      &lt;xforms:input&gt;
        &lt;xforms:label&gt;Blank 4&lt;/xforms:label&gt;
      &lt;/xforms:input&gt;
      , but it's great fun and good for my health.&lt;/p&gt;
  &lt;/body&gt;
&lt;/html&gt;</pre>
  </div>
</html>
