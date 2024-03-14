package org.daisy.z3986.rng.model;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;

import org.daisy.util.file.Directory;

public class RNGDocuments extends HashSet<RNGDocument>{
		
	/**
	 * Create an instance of this class that will reference
	 * an arbitrary set of rng grammars.
	 * @throws Exception 
	 */
	public RNGDocuments(Collection<File> sources) throws Exception {
		super();
		for(File f : sources) {
			this.add(f);
		}
	}
	
	public RNGDocuments() {
		super();
	}
	
	public void add(File f) throws Exception {
		this.add(RNGBuilder.build(f.toURI().toString()));
	}
	
	public RNGDocument getRNGDocumentFromLocalName(String localName) {
		for(RNGDocument rng : this) {
			if(rng.getFile().getName().equals(localName)) {
				return rng;
			}
		}
		throw new IllegalStateException(localName);
	}
	
	/**
	 * Get all RNGDocument instances that carry at least
	 * one define with the given name.
	 * @return a List, never null.
	 * @throws Exception 
	 */
	public List<RNGDocument> getRNGDocumentsWithDefines(String name) throws Exception {
		List<RNGDocument> ret = new ArrayList<RNGDocument>();
		for(RNGDocument rng : this) {
			if(rng.getRNGDefines(name).size()>0) {
				ret.add(rng);
			}
		}
		return ret;
	}
	
	/**
	 * Get all RngGrammar instances that carry at least
	 * one ref with the given name.
	 * @return a List, never null.
	 * @throws Exception 
	 */
	public List<RNGDocument> getRNGDocumentsWithRefs(String name) throws Exception {
		List<RNGDocument> ret = new ArrayList<RNGDocument>();
		for(RNGDocument rng : this) {
			if(rng.getRNGRefs(name).size()>0) {
				ret.add(rng);
			}
		}
		return ret;
	}
	
	public static void main (String[] args) throws Exception {
		RNGDocuments rngs = new RNGDocuments(new Directory("/Users/mgylling/Documents/workspace/zednext-trunk/temp/all-src-rng-preprocessed").getFiles(true, ".+\\.rng"));
		List<RNGDocument> list = rngs.getRNGDocumentsWithDefines("z3986.time");
		for(RNGDocument doc : list) {
			System.err.println(doc.getID());	
		}
		
		RNGDocument time = list.get(0);
		RDFDescriptionElement rdfDesc = time.getRDFDescriptionElement();
		System.err.println(rdfDesc.toXML());
		
		
		
		System.err.println("MODULE INFO");
		RDFDescriptionElement moduleRDF = time.getRDFDescriptionElement();
		System.err.println("TITLE: " + moduleRDF.getDcTitle().getValue());
		System.err.println("SHORTITLE: " + moduleRDF.getShortTitle());
		System.err.println("DESC: " + moduleRDF.getDcDescription().getValue());
		List<RNGDocument> deps = moduleRDF.getInternalDependencies(rngs);
		System.err.println("INTERNAL DEPENDENCIES");
		for(RNGDocument dep : deps) {
			System.err.println(dep.getFile().getName());
		}
		deps = moduleRDF.getExternalDependencies(rngs);
		System.err.println("EXTERNAL DEPENDENCIES");
		for(RNGDocument dep : deps) {
			System.err.println(dep.getFile().getName());
		}		
		System.err.println("IS REQUIRED MODULE: " + moduleRDF.isRequiredModule());
		
		List<RNGElementElement> elems = time.getRNGElements();
		System.err.println("TIME ELEMENTCOUNT: " + elems.size());
		for(RNGElementElement elem : elems) {
			List<AnyElement> elems2 = elem.getRDFDescriptionElement().getInfoElements();
			for(AnyElement elem2 : elems2) {
				System.err.println(elem2.getValue());
			}
		}
		
	}
	
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		for(RNGDocument doc : this) {
			sb.append(doc.getFile().getName()).append(", ");
		}
		return sb.toString();
	}
	
	private static final long serialVersionUID = 5964413850237315841L;
	
}
