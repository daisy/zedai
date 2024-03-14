Installation

1. Download oNVDL [1] and extract the contents to the directory where this file (ReadMe.txt) resides.

The DAISY Leisure Profile
=========================

The DAISY Leisure Profile is based on the XHTML 2.0 modules:
(MG: There are several of these that we should/could remove, but since there are interdependencies
between XHTML2 modules, is not as easy as just skipping an include (the schema wont phyiscally parse). 
Modules need to be "virtually" removed through content model overrides)

* The "Attribute Collections Module" (xhtml-attribs-2.rng)(INCLUDED)

* The "Document Module" (xhtml-document-2.rng) (INCLUDED)

* The "Structural Module" (xhtml-structural-2.rng) (INCLUDED)

* The "Text Module" (xhtml-text-2.rng) (INCLUDED)

* The "Hypertext Module" (xhtml-hypertext-2.rng) (INCLUDED)

* The "List Module" (xhtml-list-2.rng) (INCLUDED)

* The "Handler Module" (xhtml-handler-2.rng) (NOT INCLUDED)

* The "Image Module" (xhtml-image-2.rng) (INCLUDED)

* The "Metainformation Module" (xhtml-meta-2.rng) (INCLUDED)

* The "Object Module" (xhtml-object-2.rng) (INCLUDED)

* The "Access Module" (xhtml-access-2.rng) (INCLUDED)

* The "Style Sheet Module" (xhtml-style-2.rng) (INCLUDED)

* The "Tables Module" (xhtml-table-2.rng) (INCLUDED)

* The "Datatypes Module" (xhtml-datatypes-2.rng) (INCLUDED)

* The "Param Module" (xhtml-param-2.rng) (INCLUDED)

* The "Caption Module" (xhtml-caption-2.rng) (INCLUDED)

* The "XML Events module" (xml-events-1.rng) (INCLUDED)

* The "Ruby module" (full-ruby-1.rng) (INCLUDED)

* The "XForms module" (xforms-nons-11.rng) (NOT INCLUDED)

* The "XML Schema instance module" (XMLSchema-instance.rng) (INCLUDED)

Status by 20081022:
    The RelaxNG schema for the xhtml2 structural module is modified (by replacement in the driver ) so that
    - only one h element is allowed in a section element.
    - the h element must be the first child of the section element, except for one optional pagenum element (Only in RNG for now) .
    - The pagenum may be child of the section and p elements.
    - The pagenum may have an OPTIONAL xml:id attribute. id was mandatory in DTBook. Probably need some discussion.
    - If @page="normal", the content must be a positive integer.
    - if @page="front", the content must be a roman numeral.
    - if @page="special", any content is allowed, even an empty string.

    See also issue #1 to #4 on http://code.google.com/p/zednext/issues/list

