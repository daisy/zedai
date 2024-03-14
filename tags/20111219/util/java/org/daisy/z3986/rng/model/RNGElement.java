package org.daisy.z3986.rng.model;

import java.util.ArrayList;
import java.util.List;

import nu.xom.Element;
import nu.xom.Elements;

import org.daisy.z3986.Constants;
import org.daisy.z3986.xom.XOMUtil;


/**
 * Any element in the RelaxNG namespace.
 */
public class RNGElement extends AnyElement {

	public RNGElement(String name, String uri) {
		super(name, uri);
	}

	/**
	 * Get the value of the name attribute on this element,
	 * or null if none exists.
	 */
	public String getRNGName() {
		return this.getAttributeValue(Constants.NAME);
	}
	
	/**
	 * Get the DocBook element that is the first
	 * element child of this element, or null if no such element exists.
	 * <p>If this element is the root (grammar) element, the returned element
	 * will be and instance of DocbookInfoElement, else and instance of
	 * DocbookAnnotationElement.</p>
	 */
	public DocbookElement getDocbookDescriptionElement() {
		Elements children = this.getChildElements();			
		if(children.size()>0 && children.get(0).getNamespaceURI() == Constants.DOCBOOK_NS) {
			return (DocbookElement)children.get(0);									
		}
		return null;	
	}
	
//	/**
//	 * Get the rdf:Description element that is the first
//	 * element child of a first rdf:RDF child this element, 
//	 * or null if no such element exists.
//	 */
//	public RDFDescriptionElement getRDFDescriptionElement() {		
//		Elements children = this.getChildElements();			
//		if(children.size()>0) {
//			if(children.get(0).getNamespaceURI() == Constants.RDF_NS) { //rdf:RDF
//				return (RDFDescriptionElement) 
//					children.get(0).getFirstChildElement(
//							Constants.DESCRIPTION_INITIALCASE, Constants.RDF_NS);
//			}						
//		}
//		return null;
//	}
	
	/**
	 * Get all rng:element descendants of this element.
	 */
	public List<RNGElementElement> getRNGElements() throws Exception {
		
		final List<RNGElementElement> ret = new ArrayList<RNGElementElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.ELEMENT) {
					ret.add((RNGElementElement)element);
				}				
			}
		});
		return ret;
	}
	
	/**
	 * Get all rng:attribute descendants of this element.
	 */
	public List<RNGAttributeElement> getRNGAttributes() throws Exception {
		
		final List<RNGAttributeElement> ret = new ArrayList<RNGAttributeElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.ATTRIBUTE) {
					ret.add((RNGAttributeElement)element);
				}				
			}
		});
		return ret;
	}
	
	/**
	 * Get all rng:define descendants of this element.
	 */
	public List<RNGDefineElement> getRNGDefines() throws Exception {
		
		final List<RNGDefineElement> ret = new ArrayList<RNGDefineElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.DEFINE) {
					ret.add((RNGDefineElement)element);
				}				
			}
		});
		return ret;
	}
	
	/**
	 * Get all rng:value descendants of this element.
	 * @throws Exception 
	 */
	public List<RNGValueElement> getRNGValues() throws Exception {
		final List<RNGValueElement> ret = new ArrayList<RNGValueElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.VALUE) {
					ret.add((RNGValueElement)element);
				}				
			}
		});
		return ret;
	}
	
	/**
	 * Get all rng:ref descendants of this element.
	 */
	public List<RNGRefElement> getRNGRefs() throws Exception {
		
		final List<RNGRefElement> ret = new ArrayList<RNGRefElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.REF) {
					ret.add((RNGRefElement)element);
				}				
			}
		});
		return ret;
	}
	
	/**
	 * Get the rng:define that is an ancestor of this element, 
	 * or null if none exists.
	 */
	public RNGDefineElement getAncestorDefine() {
		return (RNGDefineElement)XOMUtil.getAncestor(this, Constants.DEFINE, Constants.RNG_NS);
	}
	
	/**
	 * Get the value of ns attribute on this element or ancestors,
	 * or null if it is not set.
	 */
	public String getNS() {
		return getNS(true);
	}
	
	/**
	 * Get the value of ns attribute on this element and optionally ancestors,
	 * or null if it is not set.
	 */
	public String getNS(boolean searchAncestors) {
		String ns = this.getAttributeValue(Constants.NS);
		if(ns==null && searchAncestors) {
			Element nsdeclarator = XOMUtil.getAncestorWithAttribute(this, Constants.NS);
			if(nsdeclarator!=null) {
				ns = nsdeclarator.getAttributeValue(Constants.NS);
			}				
		}
		return ns;
	}
}


