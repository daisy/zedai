//package org.daisy.z3986.rng.model;
//
//import java.util.ArrayList;
//import java.util.List;
//
//import nu.xom.Attribute;
//import nu.xom.Element;
//import nu.xom.Elements;
//import nu.xom.Nodes;
//
//import org.daisy.z3986.Constants;
//
//public class RDFDescriptionElement extends AnyElement {
//
//	public RDFDescriptionElement(String name, String uri) {
//		super(name, uri);
//	}
//	
//	/**
//	 * Determine whether this RDF Descriptions elements describes the entire document.
//	 */
//	public boolean isModuleLevel() {
//		return ((Element)this.getParent().getParent()).getLocalName() == Constants.GRAMMAR;
//	}
//	
//	/**
//	 * Get the dcterms:title element.
//	 */
//	public AnyElement getDcTitle() {
//		return (AnyElement) this.getFirstChildElement(Constants.TITLE, Constants.DCTERMS_NS);
//	}
//
//	/**
//	 * Get the dcterms:description element.
//	 */
//	public AnyElement getDcDescription() {
//		return (AnyElement) this.getFirstChildElement(Constants.DESCRIPTION_LOWERCASE, Constants.DCTERMS_NS);
//	}
//	
//	/**
//	 * Get the value of the z:short attribute on the dcterms:title element
//	 */
//	public String getShortTitle() {
//		return getDcTitle().getAttributeValue(Constants.SHORT, Constants.Z_M12N_VOCAB_NS);		
//	}
//		
//	/**
//	 * Get the z:context element, or null if it does not exist. Invocation is illegal on the module-level RDF.
//	 */
//	public AnyElement getContextDescription() {	
//		if(isModuleLevel()) throw new IllegalStateException();
//		Elements elems = this.getChildElements(Constants.CONTEXT, Constants.Z_M12N_VOCAB_NS);
//		if(elems.size()==0) return null;
//		return (AnyElement)elems.get(0);		
//	}
//	
//	
//	/**
//	 * Get the value of @z:alterability on the z:context element, or null of no such attribute exists. 
//	 * Value is 'fixed' (total alterability restriction) or any other string (partial alterability restriction).
//	 * Invocation is illegal on the module-level RDF.
//	 */
//	public String getContextAlterability() {
//		if(isModuleLevel()) throw new IllegalStateException();
//		return getAlterabilityAttributeValue(getContextDescription());
//	}
//	
//	/**
//	 * Get the z:content element, or null if it does not exist. Invocation is illegal on the module-level RDF.
//	 */
//	public AnyElement getContentDescription() {		
//		if(isModuleLevel()) throw new IllegalStateException();
//		Elements elems = this.getChildElements(Constants.CONTENT, Constants.Z_M12N_VOCAB_NS);
//		if(elems.size()>1) throw new IllegalStateException();
//		if(elems.size()<1) return null;
//		return (AnyElement)elems.get(0);
//	}
//
//	/**
//	 * Get the value of @z:alterability on z:content element, or null of no such attribute exists. 
//	 * Value is 'fixed' (total alterability restriction) or any other string (partial alterability restriction).
//	 * Invocation is illegal on the module-level RDF.
//	 */
//	public String getContentAlterability() {
//		if(isModuleLevel()) throw new IllegalStateException();
//		return getAlterabilityAttributeValue(getContentDescription());
//	}
//
//	/**
//	 * Get the z:attlist element, or null if it does not exist. Invocation is illegal on the module-level RDF.
//	 */
//	public AnyElement getAttlistDescription() {	
//		if(isModuleLevel()) throw new IllegalStateException();
//		Elements elems = this.getChildElements(Constants.ATTLIST, Constants.Z_M12N_VOCAB_NS);
//		if(elems.size()==0) {
//			return null;
//		}
//		return (AnyElement) elems.get(0);		
//	}
//	
//	/**
//	 * Get the value of @z:alterability on z:attlist element, or null of no such attribute exists. 
//	 * Value is 'fixed' (total alterability restriction) or any other string (partial alterability restriction).
//	 * Invocation is illegal on the module-level RDF.
//	 */
//	public String getAttlistAlterability() {
//		if(isModuleLevel()) throw new IllegalStateException();
//		return getAlterabilityAttributeValue(getAttlistDescription());
//	}
//	
//	/**
//	 * Get the z:specialization element, or null of no such element exists. 
//	 * Invocation is illegal on the module-level RDF.
//	 */
//	public AnyElement getSpecialization() {
//		if(isModuleLevel()) throw new IllegalStateException();
//		Elements elems = this.getChildElements(Constants.SPECIALIZATION, Constants.Z_M12N_VOCAB_NS);
//		if(elems.size()==0) {
//			return null;
//		}
//		return (AnyElement) elems.get(0);
//	}
//	
//	private String getAlterabilityAttributeValue(Element parent) {
//		if(parent!=null) {
//			Attribute alterability = parent.getAttribute(Constants.ALTERABILITY, Constants.Z_M12N_VOCAB_NS);
//			if(alterability!=null) {
//				return alterability.getValue();
//			}
//		}
//		return null;
//	}
//
//	/**
//	 * Whether this component is omittable on module activation.
//	 * Invocation is illegal on the module-level RDF
//	 */
//	public boolean isOmittable() {		
//		if(isModuleLevel()) throw new IllegalStateException();
//		Boolean omittable;
//		Nodes nodes = this.query("./dcterms:isRequiredBy[@rdf:resource='.']", Constants.namespaces);
//		if(nodes.size()==1) {
//			omittable = Boolean.FALSE;
//		}else if(nodes.size()==0) {
//			omittable = Boolean.TRUE;
//		}else {
//			throw new IllegalStateException();
//		}		
//		return omittable.booleanValue();
//	}
//	
//	/**
//	 * Whether this module is required in Profiles.
//	 * Invocation is illegal on anything but the module-level RDF
//	 */
//	public boolean isRequiredModule() {			
//		if(!isModuleLevel()) throw new IllegalStateException();
//		Boolean omittable;	
//		Nodes nodes = this.query(".//dcterms:requiredBy[@rdf:resource='http://www.daisy.org/z3986/2012/auth/']", Constants.namespaces);
//		if(nodes.size()==1) {
//			omittable = Boolean.TRUE;
//		}else if(nodes.size()==0) {
//			omittable = Boolean.FALSE;
//		}else {
//			throw new IllegalStateException();
//		}		
//		return omittable.booleanValue();
//	}
//	
//	/**
//	 * Get a list of grammars that this module claims are dependant on this module.
//	 * The returned value means nothing if not called on the module-level RDF.
//	 * This method never returns null; Invocation is illegal on anything but the module-level RDF
//	 */
//	public List<RNGDocument> getExternalDependencies(RNGDocuments context) {	
//		if(!isModuleLevel()) throw new IllegalStateException();
//		List<RNGDocument> externalDependencies = new ArrayList<RNGDocument>(3);
//		Nodes deps = this.query(".//dcterms:requiredBy[not(@rdf:resource='http://www.daisy.org/z3986/2012/auth/')]", Constants.namespaces);				
//		for (int i = 0; i < deps.size(); i++) {
//			Element dep = (Element)deps.get(i);
//			externalDependencies.add(context.getRNGDocumentFromLocalName(
//					dep.getAttributeValue(
//					Constants.RESOURCE, Constants.RDF_NS)));
//		}
//		return externalDependencies;
//	}
//	
//	/**
//	 * Get a list of grammars that this module claims are dependant on this module.
//	 * The returned value means nothing if not called on the module-level RDF.
//	 * This method never returns null; Invocation is illegal on anything but the module-level RDF
//	 */
//	public List<RNGDocument> getInternalDependencies(RNGDocuments context) {
//		if(!isModuleLevel()) throw new IllegalStateException("not module level");
//		List<RNGDocument> internalDependencies = new ArrayList<RNGDocument>();
//		Elements deps = this.getChildElements(Constants.REQUIRES, Constants.DCTERMS_NS);				
//		for (int i = 0; i < deps.size(); i++) {
//			Element dep = (Element)deps.get(i);
//			String val = null;
//			try{
//				val = dep.getAttributeValue(Constants.RESOURCE, Constants.RDF_NS);
//				internalDependencies.add(context.getRNGDocumentFromLocalName(val));
//			}catch (Exception e) {
//				throw new IllegalStateException(((RNGDocument)this.getParent().getDocument()).getFile().getName() + ": " + val , e.getCause());
//			}
//		}
//		return internalDependencies;
//	}
//	
//	/**
//	 * Get the z:info elements, an empty list none such exists.
//	 */
//	public List<AnyElement> getInfoElements() {		
//		List<AnyElement> infos = new ArrayList<AnyElement>(3);
//		Elements nodes = this.getChildElements(Constants.INFO, Constants.Z_M12N_VOCAB_NS);
//		for (int i = 0; i < nodes.size(); i++) {
//			infos.add((AnyElement) nodes.get(i));
//		}			
//		return infos;
//	}
//}
