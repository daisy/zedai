package org.daisy.z3998.rng.model;

import java.io.File;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.daisy.z3998.Constants;
import org.daisy.z3998.rng.model.AnyElement.WalkerListener;

import nu.xom.Document;
import nu.xom.Element;

public class RNGDocument extends Document {

	public RNGDocument() {
		super(new Element("root", "http://www.xom.nu/fakeRoot"));
	}

	public File getFile() {
		return new File(URI.create(this.getRootElement().getBaseURI()));
	}
	
	public String getID() {
		return ((RNGGrammarElement)this.getRootElement()).getID();
	}
	
	/**
	 * Get all rng:element descendants in this document.
	 */
	public List<RNGElementElement> getRNGElements() throws Exception {				
		return getRNGElements(false);
	}
	
	/**
	 * Get those rng:element descendants in this document that has a docbook annotation element as a firstChild.
	 */
	public List<RNGElementElement> getRNGElements(boolean onlyWithDocbookAnnotation) throws Exception {				
		List<RNGElementElement> elements = ((RNGGrammarElement)this.getRootElement()).getRNGElements();
		if(onlyWithDocbookAnnotation) {
			List<RNGElementElement> elements2 = new ArrayList<RNGElementElement>();
			for(RNGElementElement element : elements) {
				DocbookElement db = element.getDocbookDescriptionElement();
				if(db!=null && (db instanceof DocbookAnnotationElement)) {
					elements2.add(element);
				}
			}
			return elements2;
		}
		return elements;
	}
	
	/**
	 * Get all rng:element descendants in this document.
	 */
	public List<RNGAttributeElement> getRNGAttributes() throws Exception {				
		return getRNGAttributes(false);
	}
	
	/**
	 * Get those rng:attribute descendants in this document that has a docbook annotation element as a firstChild.
	 */
	public List<RNGAttributeElement> getRNGAttributes(boolean onlyWithDocbookAnnotation) throws Exception {				
		List<RNGAttributeElement> elements = ((RNGGrammarElement)this.getRootElement()).getRNGAttributes();
		if(onlyWithDocbookAnnotation) {
			List<RNGAttributeElement> elements2 = new ArrayList<RNGAttributeElement>();
			for(RNGAttributeElement element : elements) {
				DocbookElement db = element.getDocbookDescriptionElement();
				if(db!=null && db instanceof DocbookAnnotationElement) {
					elements2.add(element);
				}
			}
			return elements2;
		}
		return elements;
	}
	
	/**
	 * Get all rng:define descendants in this document.
	 */
	public List<RNGDefineElement> getRNGDefines() throws Exception {				
		return getRNGDefines(false);
	}
	
	/**
	 * Get those rng:define descendants in this document that has a docbook annotation element as a firstChild.
	 */
	public List<RNGDefineElement> getRNGDefines(boolean onlyWithDocbookAnnotation) throws Exception {				
		List<RNGDefineElement> elements = ((RNGGrammarElement)this.getRootElement()).getRNGDefines();
		if(onlyWithDocbookAnnotation) {
			List<RNGDefineElement> elements2 = new ArrayList<RNGDefineElement>();
			for(RNGDefineElement element : elements) {
				DocbookElement db = element.getDocbookDescriptionElement();
				if(db!=null && db instanceof DocbookAnnotationElement) {
					elements2.add(element);
				}
			}
			return elements2;
		}
		return elements;
	}
	
	/**
	 * Get all rng:value descendants in this document.
	 */
	public List<RNGValueElement> getRNGValues() throws Exception {
		return ((RNGGrammarElement)this.getRootElement()).getRNGValues();
	}

	/**
	 * Get all rng:ref descendants in this document.
	 */
	public List<RNGRefElement> getRNGRefs() throws Exception {
		return ((RNGGrammarElement)this.getRootElement()).getRNGRefs();
	}
	
	/**
	 * Get all rng:include descendants in this document.
	 */
	public List<RNGIncludeElement> getRNGIncludes() throws Exception {
		return ((RNGGrammarElement)this.getRootElement()).getRNGIncludes();
	}
	
	/**
	 * Get all rng:define in this document with the given name. Never returns null.
	 */
	public List<RNGDefineElement> getRNGDefines(String name) throws Exception {		
		List<RNGDefineElement> list = getRNGDefines();
		List<RNGDefineElement> ret = new ArrayList<RNGDefineElement>();
		for(RNGDefineElement define : list) {
			if(define.getRNGName().equals(name)) {
				ret.add(define);
			}
		}
		return ret;
	}
	
	/**
	 * Get all rng:ref in this document with the given name. Never returns null.
	 */
	public List<RNGRefElement> getRNGRefs(String name) throws Exception {		
		List<RNGRefElement> list = getRNGRefs();
		List<RNGRefElement> ret = new ArrayList<RNGRefElement>();
		for(RNGRefElement ref : list) {
			if(ref.getRNGName().equals(name)) {
				ret.add(ref);
			}
		}
		return ret;
	}

//	public RDFDescriptionElement getRDFDescriptionElement() {	
//		return ((RNGGrammarElement)this.getRootElement()).getRDFDescriptionElement();
//	}

	/**
	 * Get the docbook info element that is the first child of the grammar element in this document, 
	 * or null if no such element exists.
	 */
	public DocbookInfoElement getDocbookInfoElement() {	
		return (DocbookInfoElement)((RNGGrammarElement)this.getRootElement()).getDocbookDescriptionElement();
	}
	
	/**
	 * Get all rng namespace element children of this RNGDocument that has a docbook annotation element as a firstchild.
	 * The root element is excluded.
	 * @return A list that may be empty, never null.
	 * @throws Exception 
	 */
	
	public List<RNGElement> getAllDocbookAnnotatedPatterns() throws Exception {
		final List<RNGElement> annotated = new ArrayList<RNGElement>();
		RNGGrammarElement root = (RNGGrammarElement) this.getRootElement();
		root.walk(new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS) {
					RNGElement rngElement = (RNGElement) element;
					if (rngElement.getDocbookDescriptionElement() != null) {
						annotated.add(rngElement);
					}					
				}				
			}			
		});		
		return annotated;		
	}
	
//	public List<RNGElement> getAllRDFAnnotatedPatterns() throws Exception {
//		final List<RNGElement> annotated = new ArrayList<RNGElement>();
//		RNGGrammarElement root = (RNGGrammarElement) this.getRootElement();
//		root.walk(new WalkerListener() {
//			public void onElement(Element element) throws Exception {
//				if(element.getNamespaceURI() == Constants.RNG_NS) {
//					RNGElement rngElement = (RNGElement) element;
//					if (rngElement.getRDFDescriptionElement() != null) {
//						annotated.add(rngElement);
//					}					
//				}				
//			}			
//		});		
//		return annotated;		
//	}

	/**
	 * Whether this RNG document includes given RNG document using the rng:include element.
	 * @throws Exception 
	 */
	public boolean includes(RNGDocument test) throws Exception {
	    List<RNGIncludeElement> includes = getRNGIncludes();
	    URI testURI = test.getFile().toURI();
	    for(RNGIncludeElement included : includes) {
	    	URI includedURI = this.getFile().toURI().resolve(included.getAttributeValue("href"));
	    	if(includedURI.equals(testURI)) {
	    		return true;
	    	}
	    }
		return false;
	}
}
