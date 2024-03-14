package org.daisy.z3998.rng.model;

import java.util.ArrayList;
import java.util.List;

import nu.xom.Elements;
import nu.xom.Nodes;

import org.daisy.z3998.Constants;

public class DocbookAnnotationElement extends DocbookElement {

	public DocbookAnnotationElement(String name, String uri) {
		super(name, uri);
	}

	/**
	 * Get the title element of this annotation (rng:annotation/db:title) 
	 * @return
	 */
	public DocbookElement getTitle() {
		Elements elems = this.getChildElements(Constants.TITLE, Constants.DOCBOOK_NS);
		if(elems.size()==1) return (DocbookElement)elems.get(0);
		if(elems.size()==0) return null;
		throw new IllegalStateException(Integer.toString(elems.size()));
	}

	public String getTitleXrefLabel() {
		DocbookElement title = getTitle();
		if(title!=null) {
			return title.getAttributeValue(Constants.XREFLABEL);
		}
		return null;
	}

	public DocbookElement getDescriptionMain() {
		Nodes matches = this.query("db:para[contains(@role,'desc-main')]", Constants.namespaces);
		if(matches.size()==1) {
			return (DocbookElement) matches.get(0);
		}
		throw new IllegalStateException(Integer.toString(matches.size()));
	}

	
	/**
	 * Get the sub description paras of this annotation
	 * (db:annotation/db:para[contains(@role,'desc-sub')])
	 * @return a list that may be empty, never null
	 */
	public List<DocbookElement> getDescriptionSub() {
		List<DocbookElement> list = new ArrayList<DocbookElement>();				
		Nodes matches = this.query("db:para[contains(@role,'desc-sub')]", Constants.namespaces);
		for (int i = 0; i < matches.size(); i++) {
			list.add((DocbookElement)matches.get(i));
		}		
		return list;
	}
	
	public DocbookElement getDefinitionContext() {
		Nodes matches = this.query("db:synopsis[@role='def-context']", Constants.namespaces);
		if(matches.size()==1) {
			return (DocbookElement) matches.get(0);
		}
		return null;
	}

	public DocbookElement getDefinitionContent() {
		Nodes matches = this.query("db:synopsis[@role='def-content']", Constants.namespaces);
		if(matches.size()==1) {
			return (DocbookElement) matches.get(0);
		}
		return null;
	}
	
	public DocbookElement getDefinitionAttlist() {
		Nodes matches = this.query("db:synopsis[@role='def-attlist']", Constants.namespaces);
		if(matches.size()==1) {
			return (DocbookElement) matches.get(0);
		}
		return null;
	}

	/**
	 * Get the context alterability restriction, or null if none is set
	 * db:synopsis[@role='def-context']/@condition
	 */
	public String getDefinitionContextAlterabilityRestriction() {
		if(this.getDefinitionContext()!=null){
			return this.getDefinitionContext().getAttributeValue(Constants.CONDITION);
		}
		return null;
	}

	/**
	 * Get the content alterability restriction, or null if none is set
	 * db:synopsis[@role='def-content']/@condition
	 */
	public String getDefinitionContentAlterabilityRestriction() {
		if(this.getDefinitionContent()!=null){
			return this.getDefinitionContent().getAttributeValue(Constants.CONDITION);
		}
		return null;
	}

	/**
	 * Get the attlist alterability restriction, or null if none is set
	 * db:synopsis[@role='def-attlist']/@condition
	 */
	public String getDefinitionAttlistAlterabilityRestriction() {
		if(this.getDefinitionAttlist()!=null){
			return this.getDefinitionAttlist().getAttributeValue(Constants.CONDITION);
		}
		return null;
	}

	/**
	 * Get the para describing specialization, or null if not present.
	 * (/para[@role="def-specialization"])
	 */
	public DocbookElement getDefinitionSpecialization() {
		Nodes matches = this.query("db:para[@role='def-specialization']", Constants.namespaces);
		if(matches.size()==1) {
			return (DocbookElement) matches.get(0);
		}
		return null;
	}

	public boolean isOmittable() {	
		String condition = this.getAttributeValue(Constants.CONDITION);
		return condition == null || (!condition.equals(Constants.REQUIRED));
	}

	

}
