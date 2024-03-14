/**
 * 
 */
package org.daisy.z3986;

import java.util.HashMap;
import java.util.Map;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Node;

import org.daisy.z3986.xom.XOMUtil;

public class QNameProvider {
	public static final String LABELESS_LINK = "GET_LABEL";
	private QNameProvider.OutputGrammar outputGrammar;
	private String outputDefaultNS;
	private Document input;
	private Attribute xmlSpacePreserveTemplate = new Attribute("xml:space", Constants.XML_NS, "preserve");
	
	private Map<QNameProvider.OutputGrammar, Map<QNameProvider.Type, Node>> nameMap 
		= new HashMap<QNameProvider.OutputGrammar, Map<QNameProvider.Type, Node>>() ;
			
	public QNameProvider(Document input, OutputGrammar outputGrammar, String outputDefaultNS) {
		this.input = input;		
		this.outputGrammar = outputGrammar;
		this.outputDefaultNS = outputDefaultNS;
				
		Map<QNameProvider.Type, Node> docbookMap = new HashMap<QNameProvider.Type, Node>();
		docbookMap.put(Type.ELEMENT_SECTION, new Element("section", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_SECTION_TITLE, new Element("title", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_SUBSECTION_TITLE, new Element("title", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_PARA, new Element("para", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_LINK, new Element("link", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_TABLE, new Element("table", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_TABLE_INFORMAL, new Element("informaltable", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_TABLE_ROW, new Element("tr", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_TABLE_CELL, new Element("td", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_TABLE_CELL_HEAD, new Element("th", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_CAPTION, new Element("caption", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_CODE, new Element("code", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_LIST_ITEMIZED, new Element("itemizedlist", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_LIST_ITEMIZED_ITEM, new Element("listitem", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_EXAMPLE_WRAPPER, new Element("example", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_EXAMPLE_TITLE, new Element("title", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_EXAMPLE_CAPTION, new Element("para", Constants.DOCBOOK_NS));
		docbookMap.put(Type.ELEMENT_EXAMPLE_LISTING, new Element("programlisting", Constants.DOCBOOK_NS));
		
		docbookMap.put(Type.ATTRIBUTE_ID, new Attribute("xml:id", Constants.XML_NS ,""));
		docbookMap.put(Type.ATTRIBUTE_ROLE, new Attribute("role",""));
		docbookMap.put(Type.ATTRIBUTE_LINK_URI, new Attribute("xlink:href", Constants.XLINK_NS, ""));
		docbookMap.put(Type.ATTRIBUTE_LINK_IDREF, new Attribute("linkend", "")); //DONT RETURN THIS FOR XHTML
		nameMap.put(OutputGrammar.DOCBOOK, docbookMap);
		
		Map<QNameProvider.Type, Node> xhtmlMap = new HashMap<QNameProvider.Type, Node>();
		xhtmlMap.put(Type.ELEMENT_SECTION, new Element("div", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_SECTION_TITLE, new Element("h4", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_SUBSECTION_TITLE, new Element("h5", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_PARA, new Element("p", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_LINK, new Element("a", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_TABLE, new Element("table", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_TABLE_INFORMAL, new Element("table", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_TABLE_ROW, new Element("tr", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_TABLE_CELL, new Element("td", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_TABLE_CELL_HEAD, new Element("th", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_CAPTION, new Element("caption", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_CODE, new Element("code", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_LIST_ITEMIZED, new Element("ul", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_LIST_ITEMIZED_ITEM, new Element("li", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_EXAMPLE_WRAPPER, new Element("div", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_EXAMPLE_TITLE, new Element("h6", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_EXAMPLE_CAPTION, new Element("p", Constants.XHTML_NS));
		xhtmlMap.put(Type.ELEMENT_EXAMPLE_LISTING, new Element("pre", Constants.XHTML_NS));
		
		xhtmlMap.put(Type.ATTRIBUTE_ID, new Attribute("id",""));
		xhtmlMap.put(Type.ATTRIBUTE_ROLE, new Attribute("class",""));
		xhtmlMap.put(Type.ATTRIBUTE_LINK_URI, new Attribute("href", ""));		
		nameMap.put(OutputGrammar.XHTML, xhtmlMap);
		
	}
	
	public String getCurrentDefaultNamespace() {		
		return outputDefaultNS;
	}
	public OutputGrammar getCurrentOutputGrammar() {
		return outputGrammar;
	}
	
	public Element getElement(QNameProvider.Type type) throws Exception {
		return getElement(type, null, null, null);
	}
	
	public Element getElement(QNameProvider.Type type, String id) throws Exception {
		return getElement(type, id, null, null);
	}
	
	public Element getElement(QNameProvider.Type type, String id, String role) throws Exception {
		return getElement(type, id, role, null);
	}
	
	public Element getElement(QNameProvider.Type type, String id, String role, String caption) throws Exception {
		return getElement(type, id, role, caption, false);
	}
		
	public Element getElement(QNameProvider.Type type, String id, String role, String caption, boolean addXmlSpacePreserve) throws Exception {	
		Element ret = (Element)nameMap.get(outputGrammar).get(type).copy();
		
		if(id!=null) {
			Attribute attr = (Attribute)nameMap.get(outputGrammar).get(Type.ATTRIBUTE_ID).copy();			
			attr.setValue(id);
			ret.addAttribute(attr);
		}
		
		if(role!=null) {
			Attribute attr = (Attribute)nameMap.get(outputGrammar).get(Type.ATTRIBUTE_ROLE).copy();			
			attr.setValue(role);
			ret.addAttribute(attr);
		}
		
		if(caption!=null) {
			Element elem = (Element)nameMap.get(outputGrammar).get(Type.ELEMENT_CAPTION).copy();
			XOMUtil.appendChildren(elem, XOMUtil.parseWikiSyntax(caption, this));
			ret.appendChild(elem);
		}
		
		if(addXmlSpacePreserve) {
			ret.addAttribute((Attribute)xmlSpacePreserveTemplate.copy());
		}
		
		return ret;
	}

	public Attribute getAttribute(Type type) {
		return getAttribute(type, null);
	}
	
	/**
	 * Get an attribute of given type, or null if it does not exist.
	 */
	public Attribute getAttribute(Type type, String value) {		
		Attribute a = (Attribute)nameMap.get(outputGrammar).get(type);				
		if(a==null) return null;
		Attribute ret = (Attribute)a.copy();
		if(value!=null) {
			ret.setValue(value);
		}		
		return ret;
	}

	public Element getLink(String link) throws Exception {
		return getLink(link, null);
	}
	
	public Element getLink(String link, String label) throws Exception {		
		if(label!=null) {
			label = label.trim();
			if(label.length()==0) label=null;
		}
		
		//first the create the default type
		Element linkElem = (Element)nameMap.get(outputGrammar).get(Type.ELEMENT_LINK).copy();	
		Attribute linkAttr = (Attribute)nameMap.get(outputGrammar).get(Type.ATTRIBUTE_LINK_URI).copy();
		linkAttr.setValue(link);
		
		//if its an internal idref and output is docbook, modify
		boolean xref = false;
		if(link.startsWith("#") && outputGrammar == OutputGrammar.DOCBOOK) {
			if(label==null) {
				linkElem = new Element("xref", Constants.DOCBOOK_NS);
				xref = true;
			}
			linkAttr = (Attribute) nameMap.get(outputGrammar).get(Type.ATTRIBUTE_LINK_IDREF).copy();
			linkAttr.setValue(link.substring(1));
		}		
		linkElem.addAttribute(linkAttr);
		
		//deal with label
		if(label!=null) {
			XOMUtil.appendChildren(linkElem, XOMUtil.parseWikiSyntax(label, this));			
		}else if(!xref) {
			//we have an element without a label that is not a docbook xref
//			linkElem.addAttribute(new Attribute(LABELESS_LINK, "TRUE"));
//			System.err.println("QNameProvider: added labeless link: " + link);
//			labelessLinks = true;
		}
		return linkElem;
	}
	
//	boolean labelessLinks = false;
//	
//	boolean getAddedLabelessLinks() {
//		return labelessLinks;
//	}
	
	public enum OutputGrammar {
		DOCBOOK,
		XHTML;
	}
	
	public enum Type {
		ELEMENT_TABLE,
		ELEMENT_TABLE_ROW,
		ELEMENT_TABLE_CELL,
		ELEMENT_TABLE_CELL_HEAD,
		ELEMENT_PARA,
		ELEMENT_LINK,		
		ATTRIBUTE_LINK_URI, 
		ATTRIBUTE_LINK_IDREF,
		ATTRIBUTE_ID, 
		ELEMENT_SECTION, 
		ELEMENT_SECTION_TITLE, 
		ELEMENT_SUBSECTION_TITLE,
		ATTRIBUTE_ROLE, 
		ELEMENT_CAPTION, 
		ELEMENT_LIST_ITEMIZED,
		ELEMENT_LIST_ITEMIZED_ITEM, 
		ELEMENT_CODE, 
		ELEMENT_EXAMPLE_WRAPPER, 
		ELEMENT_EXAMPLE_CAPTION,
		ELEMENT_EXAMPLE_TITLE, 
		ELEMENT_EXAMPLE_LISTING, 
		ELEMENT_TABLE_INFORMAL;
	}

	public Document getCurrentHost() {		
		return input;
	}
	
}