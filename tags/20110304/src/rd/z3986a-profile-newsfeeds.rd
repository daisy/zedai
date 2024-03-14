<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">

 <!-- see /util/rd/build-rd.xsl -->

 <!-- an intro element must be provided, destination is a div -->
 <div class="intro">
  
  <p>The Z39.86-2011 Newsfeed Aggregator Profile is intended to serve as an XML republishing format
   for syndicated web content, primarily <em>news</em>.</p>
  
  <p>The profile intends to capture input sources served in formats such as <a
    href="http://www.iptc.org/">NewsML</a>, <a href="http://tools.ietf.org/html/rfc4287">Atom</a>,
    <a href="http://www.iptc.org/">NITF</a> and <a href="http://www.rssboard.org/rss-specification"
    >RSS</a> in a single format, using markup that is economic to produce but still rich enough to
   allow transformation to various accessible formats (such as Braille, DAISY and large print).</p>
  
  <p>The profile is designed to address the following usage contexts:</p>
  <ul>
   <li>The supply of an article, a collection of articles, or an entire publication in a light-weight XML grammar.</li>
   <li>The aggregation of articles from various publications, possibly using disparate formats, in a light-weight XML grammar.</li>
  </ul>
  
  <p>The profile allows the expression of document-wide as well as article-level metadata. A set of <a href="z3986a-newsfeeds.html#h_defaultrdfaprofile">terms</a> has been defined
   to allow the metadata to describe both properties of the source material as well as the intended output.</p>
  
  <p>Although the profile is primarily intended to be used in automated aggregation and republishing
   contexts, it does not exclude use in manual authoring environments.</p>
 </div>


<!--
 <div class="normative-bottom">
  <h3 id="metadata">Metadata properties</h3>
  <p>The following is an explanation of the specific metadata properties used by this profile, as
   defined normatively in the <a href="../../../../vocab/periodicals/">Z39.86 Periodicals
    Vocabulary</a>.</p>
  <dl>
   <dt>Edition</dt>
   <dd>Appears in the document head; holds information about the edition of the publication being
    delivered by the particular Feeds profile instance document; is only relevant in instances where
    the particular Feeds profile instance document is being used to deliver an entire
    publication.</dd>
   <dt>positionSection</dt>
   <dd>Appears in the Article head; holds ordinal information about the parent section and or sub
    section(s) within a pubblication, that an article appears in. for example, a value of 1.2 means
    that an article appears in a section that is the first section in the publication, and a sub
    section that is the second subsection within the section;is only relevant in instances where the
    particular Feeds profile instance document is being used to deliver a single article, or a
    collection of articles for one or more publications.</dd>
   <dt>positionSequence</dt>
   <dd>Appears in the Article head; holds ordinal information about the article within its parent
    section/sub section. for example, a value of 2 means that the article is the second article in
    its parent section/sub section; is only relevant in instances where the Feeds Profile instance
    document is being used to deliver a single article, or a collection of articles for one or more
    publications.</dd>
   <dt>kicker</dt>
   <dd>appears in the Article head; holds a piece of text that draws attention towards the article;
    is relevant in all contexts.</dd>
   <dt>positionPage</dt>
   <dd>appears in the Article head; holds information about the page that the article appears on in
    the publication; is only relevant in instances where the Feeds Profile document instance is
    being used to deliver a single article, or a collection of articles for one or more
    publications.</dd>
   <dt>Revision</dt>
   <dd>appears in the Article head; holds revision information about the article; is relevant in
    instances where the Feeds Profile instance document is being used to deliver a single article,
    or a collection of articles for one or more publications.</dd>
   <dt>destEdition</dt>
   <dd>Appears in the article head; holds information about an edition of a publication that the
    article is meant to appear in; is only relevant in instances where the Feeds Profile instance
    document is being used to deliver a single article, or a collection of articles for one or more
    publications; can appear more than once inside the Article head; each occurrence of destEdition
    holds information about a particular edition of a publication that the article is meant to
    appear in.</dd>
   <dt>destPublication</dt>
   <dd>appears in the Article head; holds information about a publication that the article is meant
    to appear in; is only relevant in contexts where the Feeds profile instance document is being
    used to deliver a single article, or a collection of articles for one or more publications; can
    appear more than once inside the Article head; each occurrence of destPublication holds
    information about a particular publication that the article is meant to appear in.</dd>
   <dt>sourceEdition</dt>
   <dd>Appears in the article head; holds information about an edition of a publication that the
    article is originally a part of; is only relevant in instances where the Feeds Profile instance
    document is being used to deliver a single article, or a collection of articles for one or more
    publications; can appear more than once inside the Article head; each occurrence of
    sourceEdition holds information about a particular edition of a publication that the article is
    originally a part of.</dd>
   <dt>sourcePublication</dt>
   <dd>appears in the Article head; holds information about a publication that the article is
    originally a part of; is only relevant in contexts where the Feeds profile instance document is
    being used to deliver a single article, or a collection of articles for one or more
    publications; can appear more than once inside the Article head; each occurrence of
    sourcePublication holds information about a particular publication that the article is
    originally a part of. </dd>
  </dl>
 </div>
-->

</html>
