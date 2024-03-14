package org.daisy.z3998.rng.model;

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
	 * Get all RngDocument instances that carry at least
	 * the top-level db:info annotation.
	 * @return a List, never null.
	 * @throws Exception 
	 */
	public List<RNGDocument> getRNGDocumentsWithInfoAnnotations() {
		List<RNGDocument> ret = new ArrayList<RNGDocument>();
		for(RNGDocument rng : this) {
			if(rng.getDocbookInfoElement()!=null) {
				ret.add(rng);
			}
		}
		return ret;		
	}
	
	/**
	 * Get all RngDocument instances that carry at least
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
		List<RNGDocument> list = rngs.getRNGDocumentsWithDefines("z3998.h");
		for(RNGDocument doc : list) {
			System.err.println(doc.getID());	
		}
		
		RNGDocument time = list.get(0);
		DocbookInfoElement info = time.getDocbookInfoElement();
		//System.err.println(info.toXML());
						
		System.err.println("MODULE INFO");
		DocbookInfoElement moduleInfo = time.getDocbookInfoElement();
		System.err.println("TITLE: " + moduleInfo.getModuleTitle().getValue());
		System.err.println("SHORTITLE: " + moduleInfo.getModuleTitleXrefLabel());
		System.err.println("DESC-MAIN: " + moduleInfo.getModuleDescriptionMain().getValue());
		
		List<DocbookElement> descSubs = moduleInfo.getModuleDescriptionSub();
		for(DocbookElement elem : descSubs) {
			System.err.println("DESC-SUB: " + elem.toXML());	
		}
		
		List<RNGDocument> deps = moduleInfo.getInternalDependencies(rngs);
		System.err.println("INTERNAL DEPENDENCIES");
		for(RNGDocument dep : deps) {
			System.err.println(dep.getFile().getName());
		}
		
		deps = moduleInfo.getExternalDependencies(rngs);
		System.err.println("EXTERNAL DEPENDENCIES");
		for(RNGDocument dep : deps) {
			System.err.println(dep.getFile().getName());
		}		
		System.err.println("IS REQUIRED MODULE: " + moduleInfo.isRequiredModule());
		
		List<RNGElementElement> elems = time.getRNGElements();
		System.err.println("TIME ELEMENTCOUNT: " + elems.size());
		
		for(RNGElementElement elem : elems) {
			DocbookAnnotationElement desc = (DocbookAnnotationElement)elem.getDocbookDescriptionElement();
			if(desc!=null) {
				System.err.println("ELEMENT ANNOTATION:");
				System.err.println("  TITLE:" + desc.getTitle().toXML());
				System.err.println("  TITLE XREFLABEL:" + desc.getTitleXrefLabel());
				System.err.println("  DESC-MAIN:" + desc.getDescriptionMain().toXML());
				List<DocbookElement> descSubs2 = desc.getDescriptionSub();
				for(DocbookElement elem2 : descSubs2) {
					System.err.println("  DESC-SUB: " + elem2.toXML());	
				}
				System.err.println("  DEF-CONTEXT:" + desc.getDefinitionContext().toXML());
				System.err.println("  DEF-CONTEXT-ALTERABILITY-RESTRICTIONS:" + desc.getDefinitionContextAlterabilityRestriction());
				System.err.println("  DEF-CONTENT:" + desc.getDefinitionContent().toXML());
				System.err.println("  DEF-CONTENT-ALTERABILITY-RESTRICTIONS:" + desc.getDefinitionContentAlterabilityRestriction());
				System.err.println("  DEF-ATTLIST:" + desc.getDefinitionAttlist().toXML());
				System.err.println("  DEF-ATTLIST-ALTERABILITY-RESTRICTIONS:" + desc.getDefinitionAttlistAlterabilityRestriction());
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
