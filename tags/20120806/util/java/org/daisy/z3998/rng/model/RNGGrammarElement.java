package org.daisy.z3998.rng.model;

import java.util.ArrayList;
import java.util.List;

import nu.xom.Element;

import org.daisy.z3998.Constants;


/**
 * The <code>rng:grammar</code> element
 */
public class RNGGrammarElement extends RNGElement {

	public RNGGrammarElement(String name, String uri) {
		super(name, uri);
	}

	public List<RNGIncludeElement> getRNGIncludes() throws Exception {
		final List<RNGIncludeElement> ret = new ArrayList<RNGIncludeElement>();
		this.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS 
						&& element.getLocalName() == Constants.INCLUDE) {
					ret.add((RNGIncludeElement)element);
				}				
			}
		});
		return ret;
	}
	
}
