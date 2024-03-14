package org.daisy.z3998;

import java.util.HashMap;
import java.util.Map;

import nu.xom.XPathContext;

public class Constants {

	public static final String ZEDAI_DOCBOOK_SPEC_TEMP_PATH = "/temp/spec-temp/z3998-2012.xml";
	public static final String ZEDAI_DOCBOOK_CMP_TEMP_PATH = "/temp/cmp-temp.xml";
	public static final String ZEDAI_DEFAULT_NAMESPACE = "http://www.daisy.org/ns/z3998/authoring/";
	public static final String ZEDNEXT_WWW_BASE = "http://www.daisy.org/z3998/2012/";
	public static final String ZEDAI_WWW_SPEC_FILENAME = "z3998-2012.html";
	public static final String ZEDAI_WWW_SPEC_PATH = ZEDNEXT_WWW_BASE + ZEDAI_WWW_SPEC_FILENAME;
	public static final String ZEDAI_WWW_CMP_PATH = ZEDNEXT_WWW_BASE + "auth/cm/z3998-2012-CM.html";
	public static final String ZEDAI_PFX = "auth";
	public static final String ZEDAI_TURTLE_NS = "http://www.daisy.org/ns/rdf/property#";
	public static final String ZEDAI_TURTLE_PFX = "zt";
	
	public static final String RNG_NS = "http://relaxng.org/ns/structure/1.0";
	public static final String RNG_PFX = "rng";
	public static final String RDF_NS = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
	public static final String RDF_PFX = "rdf";
	public static final String RDFS_NS = "http://www.w3.org/2000/01/rdf-schema#";
	public static final String RDFS_PFX = "rdfs";
	public static final String XHTML_NS = "http://www.w3.org/1999/xhtml";
	public static final String XHTML_PFX = "xhtml";
	public static final String XML_NS = "http://www.w3.org/XML/1998/namespace";
	public static final String XML_PFX = "xml";
	public static final String RNGA_NS = "http://relaxng.org/ns/compatibility/annotations/1.0";
	public static final String RNGA_PFX = "a";
	public static final String Z3998_RNG_NS = "http://www.daisy.org/ns/rng/annotations";
	public static final String Z3998_RNG_PFX = "zrng";
	public static final String XSD_NS = "http://www.w3.org/2001/XMLSchema";
	public static final String XSD_PFX = "xs";
	public static final String DOCBOOK_NS = "http://docbook.org/ns/docbook";
	public static final String DOCBOOK_PFX = "db";
	public static final String XLINK_NS = "http://www.w3.org/1999/xlink";
	public static final String XLINK_PFX = "xlink";

	public static final String MATHML_NS = "http://www.w3.org/1998/Math/MathML";
	public static final String MATHML_PFX = "m";
	public static final String XFORMS_NS = "http://www.w3.org/2002/xforms/";
	public static final String XFORMS_PFX = "xforms";
	public static final String ITS_NS = "http://www.w3.org/2005/11/its";
	public static final String ITS_PFX = "its";
	public static final String SSML_NS = "http://www.w3.org/2001/10/synthesis";
	public static final String SSML_PFX = "ssml";
	public static final String SELECT_NS = "http://www.daisy.org/ns/z3998/authoring/features/select/";
	public static final String SELECT_PFX = "sel";
	public static final String REND_NS = "http://www.daisy.org/ns/z3998/authoring/features/rend/";
	public static final String REND_PFX = "rend";
	public static final String DESCRIPTION_NS = "http://www.daisy.org/ns/z3998/authoring/features/description/";
	public static final String DESCRIPTION_PFX = "d";
	public static final String DCTERMS_NS = "http://purl.org/dc/terms/";
	public static final String DCTERMS_PFX = "dcterms";
	public static final String Z_M12N_VOCAB_NS = "http://www.daisy.org/ns/z3998/annotations/#";
	public static final String Z_M12N_VOCAB_PFX = "z";
	public static final String ISO_SCH_NS = "http://purl.oclc.org/dsdl/schematron";
	public static final String ISO_SCH_PFX = "sch";
	public static final String XINCLUDE_NS = "http://www.w3.org/2001/XInclude";
	public static final String XINCLUDE_PFX = "xi";

	public static final String MACHINE_NAME_ITS_RUBY = "its-ruby";
	public static final String MACHINE_NAME_MATHML = "mathml";
	public static final String MACHINE_NAME_SELECT = "select";
	public static final String MACHINE_NAME_REND = "rend";
	public static final String MACHINE_NAME_SVG_CDR = "svg-cdr";
	public static final String MACHINE_NAME_FORMS = "forms";
	public static final String MACHINE_NAME_SSML = "ssml";
	public static final String MACHINE_NAME_DESCRIPTION = "description";
	
	public static Map<String, String> nsMap = new HashMap<String, String>(); // uri,
																				// pfx
	static {
		nsMap.put(RNG_NS, RNG_PFX);
		nsMap.put(RDF_NS, RDF_PFX);
		nsMap.put(XHTML_NS, XHTML_PFX);
		nsMap.put(XML_NS, XML_PFX);
		nsMap.put(RNGA_NS, RNGA_PFX);
		nsMap.put(Z3998_RNG_NS, Z3998_RNG_PFX);
		nsMap.put(MATHML_NS, MATHML_PFX);
		nsMap.put(XFORMS_NS, XFORMS_PFX);
		nsMap.put(ITS_NS, ITS_PFX);
		nsMap.put(SSML_NS, SSML_PFX);
		nsMap.put(SELECT_NS, SELECT_PFX);
		nsMap.put(REND_NS, REND_PFX);
		nsMap.put(DESCRIPTION_NS, DESCRIPTION_PFX);
		nsMap.put(XSD_NS, XSD_PFX);
		nsMap.put(XLINK_NS, XLINK_PFX);
		nsMap.put(DOCBOOK_NS, DOCBOOK_PFX);
		nsMap.put(XINCLUDE_NS, XINCLUDE_PFX);
	}

	public static XPathContext namespaces = new XPathContext();
	static {
		namespaces.addNamespace(RNG_PFX, RNG_NS);
		namespaces.addNamespace(RNGA_PFX, RNGA_NS);
		namespaces.addNamespace(RDF_PFX, RDF_NS);
		namespaces.addNamespace(RDFS_PFX, RDFS_NS);
		namespaces.addNamespace(XHTML_PFX, XHTML_NS);
		namespaces.addNamespace(Z3998_RNG_PFX, Z3998_RNG_NS);
		namespaces.addNamespace(DCTERMS_PFX, DCTERMS_NS);
		namespaces.addNamespace(Z_M12N_VOCAB_PFX, Z_M12N_VOCAB_NS);
		namespaces.addNamespace(ISO_SCH_PFX, ISO_SCH_NS);
		namespaces.addNamespace(DOCBOOK_PFX, DOCBOOK_NS);
		namespaces.addNamespace(ZEDAI_PFX, ZEDAI_DEFAULT_NAMESPACE);
		namespaces.addNamespace(ZEDAI_TURTLE_PFX, ZEDAI_TURTLE_NS);
		namespaces.addNamespace(XSD_PFX, XSD_NS);
		
	}

	public static final String OPTIONAL = "optional";
	public static final String DATA = "data";
	public static final String INCLUDE = "include";
	public static final String ATTRIBUTE = "attribute";
	public static final String ELEMENT = "element";
	public static final String REF = "ref";
	public static final String DEFINE = "define";
	public static final String NAME = "name";
	public static final String NSNAME = "nsName";
	public static final String COMBINE = "combine";
	public static final String START = "start";
	public static final String RDF = "RDF";
	public static final String GROUP = "group";
	public static final String DOCUMENTATION = "documentation";
	public static final String EXTERNALREF = "externalRef";
	public static final String ZRNG_FEATURE = "zrng:feature";
	public static final String NS = "ns";
	public static final String VALUE = "value";
	public static final String EMPTY = "empty";
	public static final String DIV = "div";
	public static final String GRAMMAR = "grammar";
	public static final String NOTALLOWED = "notAllowed";
	public static final String TOKEN = "token";
	public static final String TYPE = "type";
	public static final String DATATYPELIBRARY = "datatypeLibrary";
	public static final String ID = "id";
	public static final String DESCRIPTION_INITIALCASE = "Description";
	public static final String DESCRIPTION_LOWERCASE = "description";
	public static final String TITLE = "title";
	public static final String FIXED = "fixed";
	public static final String CONTENT = "content";
	public static final String SHORT = "short";
	public static final String INFO = "info";
	public static final String CONTEXT = "context";
	public static final String ATTLIST = "attlist";
	public static final String RESOURCE = "resource";
	public static final String REQUIRES = "requires";
	public static final String XREFLABEL = "xreflabel";
	public static final String HTML = "html";
	public static final String ASSERT = "assert";
	public static final String ISREQUIREDBY = "isRequiredBy";
	public static final String SPACE = "space";
	public static final String CAPTION = "caption";
	public static final String ABSDEF_ONLY = "absdef-only";
	public static final String ANCHOR = "a";
	public static final String HREF = "href";
	public static final Object RDF_BAG_URI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag";
	public static final Object RDF_PROPERTY_URI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property";
	public static final String CHOICE = "choice";
	public static final String LINKEND = "linkend";
	public static final String LINK = "link";
	public static final String XREF = "xref";
	public static final String ALTERABILITY = "alterability";
	public static final String SPECIALIZATION = "specialization";
	public static final String ANNOTATION = "annotation";
	public static final String SIMPLELIST = "simplelist";
	public static final String MEMBER = "member";
	public static final String CONDITION = "condition";
	public static final String ROLE = "role";
	public static final String DEF_ATTLIST = "def-attlist";
	public static final String DEF_CONTENT = "def-content";
	public static final String DEF_CONTEXT = "def-context";
	public static final String REQUIRED = "required";
	public static final String DOC_ONLY = "doc-only";
	

}
