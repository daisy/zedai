package org.daisy.z3998.rng.model;

import java.util.ArrayList;
import java.util.List;

import nu.xom.Attribute;
import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.Nodes;

import org.daisy.z3998.Constants;

public class DocbookInfoElement extends DocbookElement {

	public DocbookInfoElement(String name, String uri) {
		super(name, uri);
	}

	/**
	 * Get the docbook:annotation element child of this info element,
	 * or null if no such child exists.
	 */
	public DocbookAnnotationElement getDocbookAnnotationChild() {
		Elements elems = this.getChildElements(Constants.ANNOTATION, Constants.DOCBOOK_NS);
		if(elems.size()==1) return (DocbookAnnotationElement)elems.get(0);
		if(elems.size()==0) return null;
		throw new IllegalStateException(Integer.toString(elems.size()));
	}

	/**
	 * Get the title element of this module (rng:grammar/db:info/db:title) 
	 * @return
	 */
	public DocbookElement getModuleTitle() {
		Elements elems = this.getChildElements(Constants.TITLE, Constants.DOCBOOK_NS);
		if(elems.size()==1) return (DocbookElement)elems.get(0);
		if(elems.size()==0) return null;
		throw new IllegalStateException(Integer.toString(elems.size()));		
	}

	/**
	 * Get the value of the xreflabel attribute on the title element of this module 
	 * (rng:grammar/db:info/db:title/@xreflabel) 
	 * or null if no such element or attribute exists.
	 * @return
	 */
	public String getModuleTitleXrefLabel() {
		DocbookElement title = getModuleTitle();
		if(title!=null) {
			return title.getAttributeValue(Constants.XREFLABEL);
		}
		return null;
	}

	/**
	 * Get the main description para of this module
	 * (rng:grammar/db:info/db:annotation/db:para[contains(@role,'desc-main')])
	 * @return
	 */
	public DocbookElement getModuleDescriptionMain() {
		DocbookAnnotationElement anno = this.getDocbookAnnotationChild();
		if(anno!=null) {
			Nodes matches = anno.query("db:para[contains(@role,'desc-main')]", Constants.namespaces);
			if(matches.size()==1) {
				return (DocbookElement) matches.get(0);
			}
			throw new IllegalStateException(Integer.toString(matches.size()));
		}	
		return null;
	}

	/**
	 * Get the sub description paras of this module
	 * (rng:grammar/db:info/db:annotation/db:para[contains(@role,'desc-sub')])
	 * @return a list that may be empty, never null
	 */
	public List<DocbookElement> getModuleDescriptionSub() {
		List<DocbookElement> list = new ArrayList<DocbookElement>();
		DocbookAnnotationElement anno = this.getDocbookAnnotationChild();
		if(anno!=null) {
			Nodes matches = anno.query("db:para[contains(@role,'desc-sub')]", Constants.namespaces);
			for (int i = 0; i < matches.size(); i++) {
				list.add((DocbookElement)matches.get(i));
			}
		}	
		return list;
	}

	/**
	 * Get a list of grammars that this module claims to depend on.
	 * @return a list that may be empty, never null
	 */
	public List<RNGDocument> getInternalDependencies(RNGDocuments context) {
//		<simplelist role="def-dependencies">
//        <member xlink:href="z3998-global-classes.rng"/>
//        <member xlink:href="z3998-datatypes.rng"/>
//        </simplelist>
     
		List<RNGDocument> internalDependencies = new ArrayList<RNGDocument>();
		DocbookAnnotationElement anno = this.getDocbookAnnotationChild();
		if(anno!=null) {
			Nodes nodes = anno.query("db:simplelist[@role='def-dependencies']", Constants.namespaces);
			if(nodes!=null && nodes.size() == 1) {
				Elements members = ((Element)nodes.get(0)).getChildElements(Constants.MEMBER, Constants.DOCBOOK_NS);
				for (int i = 0; i < members.size(); i++) {
					Element member = members.get(i);
					String val = null;
					try{
						val = member.getAttributeValue(Constants.HREF, Constants.XLINK_NS);
						internalDependencies.add(context.getRNGDocumentFromLocalName(val));
					}catch (Exception e) {
						throw new IllegalStateException(((RNGDocument)this.getParent()
								.getDocument()).getFile().getName() + ": " + val , e.getCause());
					}
				}
			}
		}
		return internalDependencies;
	}
	
	/**
	 * Get a list of grammars that claims to depend on this module.
	 * @return a list that may be empty, never null
	 */
	public List<RNGDocument> getExternalDependencies(RNGDocuments context) {
//		<simplelist role="def-dependants">
//        <member xlink:href="z3998-global-classes.rng"/>
//        <member xlink:href="z3998-datatypes.rng"/>
//        </simplelist>
     
		List<RNGDocument> externalDependencies = new ArrayList<RNGDocument>();
		DocbookAnnotationElement anno = this.getDocbookAnnotationChild();
		if(anno!=null) {
			Nodes nodes = anno.query("db:simplelist[@role='def-dependants']", Constants.namespaces);
			if(nodes!=null && nodes.size() == 1) {
				Elements members = ((Element)nodes.get(0)).getChildElements(Constants.MEMBER, Constants.DOCBOOK_NS);
				for (int i = 0; i < members.size(); i++) {
					Element member = members.get(i);
					String val = null;
					try{
						val = member.getAttributeValue(Constants.HREF, Constants.XLINK_NS);
						externalDependencies.add(context.getRNGDocumentFromLocalName(val));
					}catch (Exception e) {
						throw new IllegalStateException(((RNGDocument)this.getParent()
								.getDocument()).getFile().getName() + ": " + val , e.getCause());
					}
				}
			}
		}
		return externalDependencies;
	}

	/**
	 * Return whether this module is required in all zedai profiles
	 * (/db:info/db:annotation[@condition="required"])
	 */
	public boolean isRequiredModule() {
		DocbookAnnotationElement anno = this.getDocbookAnnotationChild();
		if(anno!=null) {
			Attribute cond = anno.getAttribute(Constants.CONDITION);
			if(cond!=null && cond.getValue().equals("required")) {
				return true;
			}			
		}
		return false;
	}
	

	
}
