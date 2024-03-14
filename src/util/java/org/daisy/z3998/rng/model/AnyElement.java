package org.daisy.z3998.rng.model;

import java.util.ArrayList;
import java.util.List;

import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.Nodes;

import org.daisy.z3998.Constants;

/**
 * An element in a RelaxNG grammar, in any namespace, including the RelaxNG namespace
 */
public class AnyElement extends Element {

	public AnyElement(String name, String uri) {
		super(name, uri);
	}

	/**
	 * Walk the element descendants of this element.
	 */
	public void walk(WalkerListener listener) throws Exception {			
		Elements elements = this.getChildElements();
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			listener.onElement(element);
			walk(element, listener);
		}
	}
	
	private void walk(Element in, WalkerListener listener) throws Exception {			
		Elements elements = in.getChildElements();
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			listener.onElement(element);
			walk(element, listener);
		}
	}
	
	public interface WalkerListener {		
		void onElement(Element element) throws Exception;
	}
	
	/**
	 * Get the value of an xml:id or id attribute (searched in that order)
	 * for this element, or null if no such attribute exists.
	 */
	public String getID() {
		String id = this.getAttributeValue(Constants.ID, Constants.XML_NS);
		if(id==null) {
			id = this.getAttributeValue(Constants.ID);
		}
		return id;
	}
	
	/**
	 * Get any Schematron assert elements being descendants of this element.
	 * This method never returns null.
	 */
	public List<AnyElement> getSchematronAssertions() {		
		List<AnyElement> assertions = new ArrayList<AnyElement>();
		Nodes asserts = this.query(".//sch:assert", Constants.namespaces);		
		for (int i = 0; i < asserts.size(); i++) {				
			assertions.add((AnyElement)asserts.get(i));
		}		
		return assertions;
	}
		
}
