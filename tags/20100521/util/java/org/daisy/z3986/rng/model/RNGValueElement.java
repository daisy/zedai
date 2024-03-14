package org.daisy.z3986.rng.model;

import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.z3986.Constants;

/**
 * The <code>rng:define</code> element.
 */
public class RNGValueElement extends RNGElement {

	public RNGValueElement(String name, String uri) {
		super(name, uri);
	}
	
	/**
	 * Get an rngdocumentation namespace sibling of this element, or null
	 * if it does not exist.
	 */
	public AnyElement getDocumentationNextSibling() {		
		int pos = this.getParent().indexOf(this);
		if(this.getParent().getChildCount()>pos) {			
			Nodes nodes = this.query("following-sibling::*[1]");
			if(nodes.size()>0) {
				Element elem = (Element)nodes.get(0);
				if(elem.getLocalName().equals(Constants.DOCUMENTATION)
						&& elem.getNamespaceURI().equals(Constants.RNGA_NS)) {
					return (AnyElement)elem;
				}
			}
		}			
		return null;
	}
}
