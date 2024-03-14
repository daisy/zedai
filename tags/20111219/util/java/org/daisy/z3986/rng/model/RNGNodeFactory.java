package org.daisy.z3986.rng.model;

import org.daisy.z3986.Constants;

import nu.xom.Document;
import nu.xom.Element;
import nu.xom.NodeFactory;

public class RNGNodeFactory extends NodeFactory {
		
	@Override
	public Element startMakingElement(String name, String namespace) {
		
		String localName = name;
		if(name.contains(":")) {			
			localName = name.substring(name.indexOf(":")+1).intern();
		}
		
		if(namespace == Constants.RNG_NS) {
			if (localName == Constants.GRAMMAR) {
				return new RNGGrammarElement (name, namespace);		
			} 
			else if (localName == Constants.ELEMENT) {
				return new RNGElementElement (name, namespace);		
			}
			else if (localName == Constants.ATTRIBUTE) {
				return new RNGAttributeElement (name, namespace);		
			}
			else if (localName == Constants.DEFINE) {
				return new RNGDefineElement (name, namespace);		
			}
			else if (localName == Constants.REF) {
				return new RNGRefElement (name, namespace);		
			}
			else if (localName == Constants.VALUE) {
				return new RNGValueElement (name, namespace);		
			}
			else if (localName == Constants.INCLUDE) {
				return new RNGIncludeElement (name, namespace);		
			}
			return new RNGElement(name, namespace);
		}
		else if(namespace == Constants.DOCBOOK_NS) {
			if (localName == Constants.ANNOTATION) {
				return new DocbookAnnotationElement (name, namespace);		
			} else if (localName == Constants.INFO) {
				return new DocbookInfoElement (name, namespace);		
			}
			return new DocbookElement(name, namespace);
		}
//		else if(namespace == Constants.RDF_NS) {			
//			if (localName == Constants.DESCRIPTION_INITIALCASE) {
//				return new RDFDescriptionElement(name, namespace);		
//			} 
//		}
		return new AnyElement(name, namespace);		
	}
	
	@Override
	public Document startMakingDocument() {
		return new RNGDocument();		
	}
	
	
}
