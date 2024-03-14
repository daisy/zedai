package org.daisy.z3986.rng;

import java.io.File;
import java.util.List;

import nu.xom.Attribute;
import nu.xom.Element;
import nu.xom.Elements;

import org.daisy.util.file.Directory;
import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3986.Constants;
import org.daisy.z3986.DocXIncludeProcessor;
import org.daisy.z3986.LinkExpander;
import org.daisy.z3986.QNameProvider;
import org.daisy.z3986.DocXIncludeProcessor.Destination;
import org.daisy.z3986.QNameProvider.OutputGrammar;
import org.daisy.z3986.rng.model.AnyElement;
import org.daisy.z3986.rng.model.RDFDescriptionElement;
import org.daisy.z3986.rng.model.RNGBuilder;
import org.daisy.z3986.rng.model.RNGDocument;
import org.daisy.z3986.rng.model.RNGElement;
import org.daisy.z3986.rng.model.RNGGrammarElement;
import org.daisy.z3986.rng.model.AnyElement.WalkerListener;
import org.daisy.z3986.xom.XOMUtil;

/**
 * Tweak a Quasi-simplified schema to prepare it
 * for P. Sennels schemadoc generator v2.0:
 * <ul>
 * <li>Expand wiki markup to xhtml</li>
 * <li>Add snippets to z:shortsample</li>
 * <li>Add longdescs to z:longdesc</li>
 * </ul>
 * Arguments:
 * <ol start="0">
 * <li>path to input quasi-simplified schema</li>
 * <li>path to store result</li>
 * <li>path to project root dir</li>
 * </ol>
 * 
 */
public class SchemaDocPreProcessor {
	private final Directory projectDir;	
	private final DocXIncludeProcessor externaldoc;
	private final File tempDocbookSpec;
	private final File tempDocbookCmp;
	private final RNGDocument inputdoc;
	private final Element zShortSampleTemplate;	
	private final Element zLongDescTemplate;
	private final QNameProvider qnames;
		
	public SchemaDocPreProcessor(String[] args) throws Exception {
		projectDir = new Directory(args[2]);				
		tempDocbookSpec = new File(projectDir,Constants.ZEDAI_DOCBOOK_SPEC_TEMP_PATH);
		tempDocbookCmp = new File(projectDir,Constants.ZEDAI_DOCBOOK_CMP_TEMP_PATH);
		inputdoc = RNGBuilder.build(FilenameOrFileURI.toURI(args[0]).toString());		
		externaldoc = new DocXIncludeProcessor(projectDir);
		qnames = new QNameProvider(inputdoc,OutputGrammar.XHTML,Constants.XHTML_NS);
		zShortSampleTemplate = new Element("shortSample", Constants.Z_M12N_VOCAB_NS);
		Attribute space = new Attribute("xml:space", Constants.XML_NS, "preserve");
		zShortSampleTemplate.addAttribute(space);
		zLongDescTemplate = new Element("longDesc", Constants.Z_M12N_VOCAB_NS);
		inputdoc.getRootElement().addNamespaceDeclaration(Constants.XHTML_PFX, Constants.XHTML_NS);
		
		stripRedundantFields(inputdoc);
		
		expandWikiMarkup(inputdoc);
		
		addExternalDoc(inputdoc);
		
		fixLinks(inputdoc);
				
		XOMUtil.serialize(inputdoc,FilenameOrFileURI.toFile(args[1]));
	}

	/**
	 * Fix any added labeless links. Also check for links that does have a label
	 * but dont resolve to schema fragments 	
	 * @throws Exception 
	 */
	private void fixLinks(RNGDocument grammar) throws Exception {
		//new LinkLabelFinder(inputdoc, qnames, XOMUtil.build(tempDocbookSpec),true);
		new LinkExpander(inputdoc, qnames, XOMUtil.build(tempDocbookSpec), XOMUtil.build(tempDocbookCmp));
	}

	/**
	 * Expand wiki markup to xhtml
	 */
	private void expandWikiMarkup(RNGDocument grammar) throws Exception {
		RNGGrammarElement root = (RNGGrammarElement)grammar.getRootElement();
		root.walk(new WalkerListener() {
			
			public void onElement(Element element) throws Exception {
				if(isWikiMatter(element) && element.getChildElements().size() == 0 
						&& element.getChildCount() > 0) {
					
					Element ret = XOMUtil.parseWikiSyntax(element, qnames);
					element.getParent().replaceChild(element, ret);
				}
			}

			private boolean isWikiMatter(Element element) {
				String ns = element.getNamespaceURI();
				//String ln = element.getLocalName();
				if(ns == Constants.DCTERMS_NS ||
						   ns == Constants.RNGA_NS ||
						   ns == Constants.Z_M12N_VOCAB_NS ||
						   ns == Constants.ISO_SCH_NS) {
							return true;
						}
				return false;
			}
		});				
	}

	/**
	 * Add snippet and longdesc fields, xhtml format
	 */
	private void addExternalDoc(RNGDocument grammar) throws Exception {		
		List<RNGElement> list = grammar.getAllRDFAnnotatedPatterns();
		for(RNGElement elem : list) {
			String id = elem.getID();				
			List<Element> snippets = externaldoc.getSnippets(id, Destination.doc);
			for(Element snippet : snippets) {
				Element zShortSample = (Element)zShortSampleTemplate.copy();
				XOMUtil.appendChildren(zShortSample, snippet);
				elem.getRDFDescriptionElement().appendChild(zShortSample);
			}	
			
			List<Element> longdescs = externaldoc.getLongdescs(id, Destination.doc, OutputGrammar.XHTML);
			for(Element desc : longdescs) {
				Element zLongDesc = (Element)zLongDescTemplate.copy();
				XOMUtil.appendChildren(zLongDesc, desc);
				elem.getRDFDescriptionElement().appendChild(zLongDesc);
			}
			
		}		
	}

	/**
	 * Remove rng inline documentation fields that aren't used in the 
	 * schemadoc context
	 * @throws Exception 
	 */
	private void stripRedundantFields(RNGDocument grammar) throws Exception {
		List<RNGElement> list = grammar.getAllRDFAnnotatedPatterns();
		for(RNGElement elem : list) {
			RDFDescriptionElement rdf = elem.getRDFDescriptionElement();
			if(rdf.getContentDescription()!=null) { //z:content
				rdf.getContentDescription().getParent().removeChild(rdf.getContentDescription()); 
			}
			if(rdf.getContextDescription()!=null) { //z:context
				rdf.getContextDescription().getParent().removeChild(rdf.getContextDescription()); 
			}				
			if(rdf.getAttlistDescription()!=null) { //z:attlist
				rdf.getAttlistDescription().getParent().removeChild(rdf.getAttlistDescription());
			}
			Elements del = rdf.getChildElements(Constants.ISREQUIREDBY, Constants.DCTERMS_NS);
			for (int i = 0; i < del.size(); i++) {
				Element e = (Element) del.get(i);
				e.getParent().removeChild(e);
			}
			List<AnyElement> infos = rdf.getInfoElements();
			for(AnyElement info : infos) {
				if(info.getAttribute(Constants.ABSDEF_ONLY)!=null) {
					info.getParent().removeChild(info);
				}
			}
		}		
	}


	public static void main(String[] args) throws Exception {
		System.out.println("SchemaDocPreProcessor...");
		new SchemaDocPreProcessor(args);
		System.out.println("SchemaDocPreProcessor done.");
	}

	
}
