package org.daisy.z3986;

import java.io.File;
import java.io.PrintStream;
import java.net.URI;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Node;
import nu.xom.Nodes;
import nu.xom.ProcessingInstruction;
import nu.xom.xinclude.XIncluder;

import org.daisy.util.file.Directory;
import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3986.DocXIncludeProcessor.Destination;
import org.daisy.z3986.QNameProvider.OutputGrammar;
import org.daisy.z3986.QNameProvider.Type;
import org.daisy.z3986.ant.AntHelper;
import org.daisy.z3986.rng.model.AnyElement;
import org.daisy.z3986.rng.model.DocbookAnnotationElement;
import org.daisy.z3986.rng.model.DocbookElement;
import org.daisy.z3986.rng.model.DocbookInfoElement;
import org.daisy.z3986.rng.model.RNGAttributeElement;
import org.daisy.z3986.rng.model.RNGDefineElement;
import org.daisy.z3986.rng.model.RNGDocument;
import org.daisy.z3986.rng.model.RNGDocuments;
import org.daisy.z3986.rng.model.RNGElement;
import org.daisy.z3986.rng.model.RNGElementElement;
import org.daisy.z3986.xom.XOMUtil;

/**
 * Expand abstract definitions in various document types; primarily for docbook 
 * (the Core Modules document associated with the spec) and xhtml (resource directories).
 * 
 * The key is the <?absdef src="" ?> PI embedded in the input. 
 * 
 * Note that the spec and cm must be built before schemadocgen and rdgen 
 * (need the temp docbook spec and cm paths to resolve link labels)
 * 
 */

//TODO make sure role="doc-only" are skipped

public class AbstractDefExpander {	
	private static final String WWW_SCHEMA_BASE_DIR = "http://www.daisy.org/z3986/2012/schema/";
	private static final String ALTERABILITY = "alterability";
	private boolean verbose = true;	
	private StringBuilder sb; 
	private Directory projectDir;
	private Directory schemaPreprocessedDir;
	private Directory schemaSrcDir;
	private Directory tempDir;
	private RNGDocuments allGrammars;
	private DocXIncludeProcessor xdoc;
	private Document result;
	private QNameProvider qnames;
	private boolean isZedAICMP;
	/**
	 * Arguments:
	 * <ol start="0">
	 * <li>Full path to project root dir</li>
	 * <li>Full path to input document to expand</li>
	 * <li>Full path to output file</li>
	 * <li>Whether the input document is the CMP (boolean)</li>
	 * </ol>
	 */
	public AbstractDefExpander(String[] args) throws Exception {
		
		setupContext(args[0]);
								
		result = setupSource(args[1]);
		
		isZedAICMP = Boolean.parseBoolean(args[3]);
		
		OutputGrammar outputGrammar = 
			(result.getRootElement().getNamespaceURI() == Constants.DOCBOOK_NS) 
				? OutputGrammar.DOCBOOK : OutputGrammar.XHTML ;			
	
		String outputDefaultNS = result.getRootElement().getNamespaceURI();
		
		qnames = new QNameProvider(result, outputGrammar, outputDefaultNS);
		
		clean();
		
		Nodes absdefs = result.getRootElement().query("//processing-instruction('absdef')");
		
		if(outputGrammar == OutputGrammar.DOCBOOK) {
			//likely expanding CM, run a check pass
			checkCoverage(absdefs);
		}
				
		for (int i = 0; i < absdefs.size(); i++) {
			ProcessingInstruction pi = (ProcessingInstruction) absdefs.get(i);
			URI path = resolveSchema(pi.getValue());				
			expandAbsDef(allGrammars.getRNGDocumentFromLocalName(new File(path).getName()), pi, allGrammars, absdefs);
		}
		
		
		//invoke the link handler. If the input doc is the CMP, supply that twice in the
		//inparam list
		
		new LinkExpander(result, qnames, 
				XOMUtil.build(new File(projectDir,Constants.ZEDAI_DOCBOOK_SPEC_TEMP_PATH)),
				isZedAICMP ? result : XOMUtil.build(new File(projectDir,Constants.ZEDAI_DOCBOOK_CMP_TEMP_PATH)));
		
		if(qnames.getCurrentOutputGrammar() == OutputGrammar.XHTML) {
			stripXrefLabels(result);
		}
		
		XOMUtil.serialize(result,FilenameOrFileURI.toFile(args[2]));
		
	}
		
	
	/**
	 * 
	 * @param rng The grammar to fetch information from
	 * @param absdef The PI to replace
	 * @param absdefs All absdef PI's in the document
	 * @throws Exception
	 */
	private void expandAbsDef(RNGDocument rng, ProcessingInstruction absdef, RNGDocuments context, Nodes absdefs) throws Exception {
		
		stdout("expanding from ", rng.getFile().getName());
		
		DocbookInfoElement moduleInfo = rng.getDocbookInfoElement();
		
		if(moduleInfo==null) {
			throw new NullPointerException(rng.getFile().getPath());
		}
		
		//create the wrapper section, give it the id of the module
		Element section = qnames.getElement(QNameProvider.Type.ELEMENT_SECTION, rng.getID(), "module");
		
		//if docbook, add xreflabel
		addXrefLabel(section, moduleInfo);
		
		//get the module title and add to section		
		String moduleTitle = addTitle(moduleInfo, section, Type.ELEMENT_SECTION_TITLE);
		
		//get any module-level introductory paras
		addDescriptionParas(section, moduleInfo);
				
		//if module is required in all profiles, say so. Depends on rng:grammar/db:info/db:annotation[@condition='required']
		buildOverviewModuleRequired(rng, section); 
		
		//get all defines with db:annotation child
		List<RNGDefineElement> declaredDefines = rng.getRNGDefines(true);
		
		//if this is a datatypes module, render a special (table-only) section for this
		boolean isDatatypesModule = false;
		if(rng.getFile().getName().contains("datatypes")) {
			isDatatypesModule = true;
			buildOverviewTableDatatypesModule(rng, section, declaredDefines);			
		} 
		
		//if any elements declared (with db:annotation), create an element overview table
		List<RNGElementElement> declaredElements = rng.getRNGElements(true);
		String elementTableID = buildOverviewTableElements(rng, section, declaredElements);
				
		//if any attributes declared (with db:annotation), create an attribute overview table
		List<RNGAttributeElement> declaredAttributes = rng.getRNGAttributes(true);		
		String attributeTableID = buildOverviewTableAttributes(rng, section, declaredAttributes);
				
		//if any defines declared (with RDF), create a define overview table				
		if(!isDatatypesModule) buildOverviewTableDefines(rng, section, declaredDefines);
				
		//add module-level longdesc, if any
		addLongdesc(section, rng.getID(), moduleTitle);
						
		//subsections for each locally declared element
		for (RNGElement element : declaredElements) {
			Element subsection = buildElementOrAttributeDetailsSection
				(element, rng, DefineType.element, elementTableID);
			section.appendChild(subsection);
		}
				
		//subsections for each locally declared attribute
		for (RNGElement attribute : declaredAttributes) {
			Element subsection = buildElementOrAttributeDetailsSection
				(attribute, rng, DefineType.attribute, attributeTableID);
			section.appendChild(subsection);
		}
						
		//add module level examples, if any
		addSnippets(section, rng.getID(), moduleTitle);
		
		buildImplementationSection(section, rng.getID(), moduleTitle, rng, context, absdefs);				
		
		//replace the PI with the created section
		absdef.getParent().replaceChild(absdef, section);
		
	}

	/**
	 * Remove xreflabel attributes 
	 */
	private void stripXrefLabels(Document doc) {
		Nodes xreflabels = doc.getRootElement().query("//*[@" + Constants.XREFLABEL + "]");
		for (int i = 0; i < xreflabels.size(); i++) {
			Element elem = (Element) xreflabels.get(i);
			for (int j = 0; j < elem.getAttributeCount(); j++) {
				Attribute attr = elem.getAttribute(j);
				if(attr.getLocalName() == Constants.XREFLABEL) {
					elem.removeAttribute(attr);
				}
			}			
		}		
	}

	/**
	 * If we have a grammar thats not represented by an absdef, warn
	 */
	private void checkCoverage(Nodes absdefs) {
		
		List<String> absdefNames = new ArrayList<String>();
		for (int i = 0; i < absdefs.size(); i++) {
			ProcessingInstruction pi = (ProcessingInstruction) absdefs.get(i);
			URI path = resolveSchema(pi.getValue());
			absdefNames.add(new File(path).getName());
		}	
		
		for(RNGDocument grammar : allGrammars) {
			if(!absdefNames.contains(grammar.getFile().getName())) {
					stdout("Warning: spec CMP seems not to contain an absdef for ", grammar.getFile().getName());
			}
		}
	}

	/**
	 * Remove temporary placeholder sections in the docbook source
	 */
	private void clean() {
		Nodes temps = result.getRootElement().query("//*[@xml:id='TEMP_PLACEHOLDER']");
		for (int i = 0; i < temps.size(); i++) {
			Node temp = temps.get(i);
			temp.getParent().removeChild(temp);			
		}
	}

	private void buildOverviewTableDefines(RNGDocument rng, Element section, List<RNGDefineElement> declaredDefines) throws Exception {
		
		if(declaredDefines.size()<1) return;
		
		String tableID = rng.getID()+"-define-overview";						
		DocbookElement moduleTitle = rng.getDocbookInfoElement().getModuleTitle();
		
		String[] headers = new String[] {"Name", "Definition", "Content"};
		Table table = new Table(headers, tableID, "overview", moduleTitle.getValue() + " - Patterns");
						
		for (RNGDefineElement define : declaredDefines) {	
			try{
				DocbookAnnotationElement anno = (DocbookAnnotationElement)define.getDocbookDescriptionElement();
				String shortName = anno.getTitleXrefLabel();
				String desc = anno.getDescriptionMain().getValue();
				String defineID = define.getID();	
				//System.err.println("============== DEFINE ID: " + defineID);
				Element dataRow = qnames.getElement(Type.ELEMENT_TABLE_ROW, defineID);
				addXrefLabel(dataRow, anno);
				
				Element th = qnames.getElement(Type.ELEMENT_TABLE_CELL_HEAD);						
				XOMUtil.appendChildren(th, XOMUtil.parseWikiSyntax("{"+ shortName +"}", qnames));
				
				dataRow.appendChild(th);
				
				Element descTd = qnames.getElement(Type.ELEMENT_TABLE_CELL);
				XOMUtil.appendChildren(descTd, XOMUtil.parseWikiSyntax(desc, qnames));
				dataRow.appendChild(descTd);
				
				DocbookElement contentDesc = anno.getDefinitionContent();
				if(contentDesc!=null) {
					String content = contentDesc.getValue();
					Element contentTd = qnames.getElement(Type.ELEMENT_TABLE_CELL);
					XOMUtil.appendChildren(contentTd, XOMUtil.parseWikiSyntax(content, qnames));
					dataRow.appendChild(contentTd);
				} else {
					descTd.addAttribute(new Attribute("colspan", "2"));
				}
				
				table.addDataRow(dataRow);
				
			}catch (Exception e) {
				errout("Exception on define ", define.toXML());				
				throw e;
			}
			
		}				
		section.appendChild(table.table);
	}
	
	private void buildOverviewTableDatatypesModule(RNGDocument rng, Element section, List<RNGDefineElement> declaredDefines) throws Exception {
		
		String tableID = rng.getID()+"-data-overview";						
		DocbookElement moduleTitle = rng.getDocbookInfoElement().getModuleTitle();
		
		String[] headers = new String[] {"Name", "Definition"};
		Table table = new Table(headers, tableID, "overview", moduleTitle.getValue());
						
		for (RNGDefineElement define : declaredDefines) {			
			DocbookAnnotationElement defineAnno = (DocbookAnnotationElement)define.getDocbookDescriptionElement();
			String shortName = defineAnno.getTitleXrefLabel();
			String desc = defineAnno.getDescriptionMain().getValue();
				
			Element dataRow = qnames.getElement(Type.ELEMENT_TABLE_ROW,define.getRNGName());
			addXrefLabel(dataRow, defineAnno);
			
			Element th = qnames.getElement(Type.ELEMENT_TABLE_CELL_HEAD);						
			XOMUtil.appendChildren(th, XOMUtil.parseWikiSyntax("{"+ shortName +"}", qnames));
			
			dataRow.appendChild(th);
			
			Element td = qnames.getElement(Type.ELEMENT_TABLE_CELL);
			XOMUtil.appendChildren(td, XOMUtil.parseWikiSyntax(desc, qnames));
			dataRow.appendChild(td);
						
			table.addDataRow(dataRow);
			
		}				
		section.appendChild(table.table);
	}

	private void buildImplementationSection(Element section, String id, String moduleTitle, RNGDocument rng, RNGDocuments context, Nodes absdefs) throws Exception {
		
		Element implSection = qnames.getElement(Type.ELEMENT_SECTION, id+"-impl","impl");
		Element implSectionTitle = qnames.getElement(Type.ELEMENT_SUBSECTION_TITLE);
		String title = moduleTitle + " - Implementations";		
		XOMUtil.appendChildren(implSectionTitle, XOMUtil.parseWikiSyntax(title, qnames));
		implSection.appendChild(implSectionTitle);
		
		Table table = new Table(new String[]{"Schema", "Language"},null,null,null,true);
		String[] values = new String[2];
		
		StringBuilder implURI = new StringBuilder();
		implURI.append(WWW_SCHEMA_BASE_DIR);
		if(rng.getFile().getParentFile().getName().equals("mod")) {
			implURI.append("mod/");
		}
		implURI.append(rng.getFile().getName());
		
		StringBuilder link = new StringBuilder();
		link.append("[[").append(implURI).append(" ");
		link.append(rng.getFile().getName()).append("]]");
		values[0] = link.toString();		
		values[1] = "[[#refRelaxNG]]";
		
		table.addDataRow(values, false, null);

		implSection.appendChild(table.table);
		
		//list any other modules that are required when activating this. 
		buildOverviewInternalDependencies(rng, implSection, context);
		
		//list any other modules that depend on this. 
		buildOverviewExternalDependencies(rng, implSection, context, absdefs);
				
		section.appendChild(implSection);
				
	}

	private String buildOverviewTableElements(RNGDocument rng, Element section, List<RNGElementElement> declaredElements) throws Exception {
		
		String tableID = rng.getID()+"-elem-overview";		
		
		if(declaredElements.size()>0) {
			DocbookElement moduleTitle = rng.getDocbookInfoElement().getModuleTitle();
			String[] headers = new String[] {"Name", "Default attribute model", "Default content model","Default usage context"};
			Table table = new Table(headers, tableID, "overview", moduleTitle.getValue() + ": Element overview");
			
			for (RNGElementElement element : declaredElements) {
				//System.out.println("expanding element " + element.toXML());
				DocbookAnnotationElement anno = (DocbookAnnotationElement)element.getDocbookDescriptionElement();
				//exclude the first cell, which is sent in as an element
				String[] values = new String[4];
				values[0] = "DUMMY";
				values[1] = anno.getDefinitionAttlist().getValue();
				values[2] = getContentDescription(anno);
				values[3] = anno.getDefinitionContext().getValue();
				
				try{
					table.addDataRow(values, true, element);
				}catch (Exception e) {
					System.err.println("error when creating table from " + element.toXML());
					throw e;
				}
			}			
			section.appendChild(table.table);
		}
		return tableID;
	}
	
	private String buildOverviewTableAttributes(RNGDocument rng, Element section, List<RNGAttributeElement> declaredAttributes) throws Exception {
		
		String tableID = rng.getID()+"-attr-overview";
		
		if(declaredAttributes.size() > 0) {		
			DocbookElement moduleTitle = rng.getDocbookInfoElement().getModuleTitle();		
			String[] headers = new String[] {"Name", "Default values", "Default usage context"};
			Table table = new Table(headers, tableID, "overview", moduleTitle.getValue() + ": Attribute overview");
			
			for (RNGAttributeElement element : declaredAttributes) {
				try{
					DocbookAnnotationElement anno = (DocbookAnnotationElement)element.getDocbookDescriptionElement();
					//exclude the first cell, which is sent in as an element
					String[] values = new String[3];
					values[0] = "DUMMY";
					//values[1] = preModNS(element.getNS(false));			
					values[1] = anno.getDefinitionContent().getValue();
					values[2] = anno.getDefinitionContext().getValue();								
					table.addDataRow(values, true, element);
				}catch (Exception e) {
					System.err.println("error when creating table from " + element.toXML());
					throw e;
				}
			}			
			section.appendChild(table.table);
		}	
		return tableID;
	}
		
	private void buildOverviewExternalDependencies(RNGDocument rng, Element section, RNGDocuments context, Nodes absdefs) throws Exception {
		
		List<RNGDocument> extdeps = rng.getDocbookInfoElement().getExternalDependencies(context);
		
		if(isZedAICMP) {
			//remove any external dependencies that aren't part of the core modules (feature)
			//the extdep must be represented as an absdef PI
			Set<RNGDocument> remove = new HashSet<RNGDocument>();
			for(RNGDocument doc : extdeps) {
				if(!isZedAICoreModule(doc, absdefs)) {
					remove.add(doc);					
				}
			}
			for(RNGDocument doc : remove) {
				extdeps.remove(doc);
			}
		}
		
		if(extdeps.size()>0) {
			Element para = qnames.getElement(QNameProvider.Type.ELEMENT_PARA);
			para.appendChild("The ");  
			expandModuleList(para, extdeps);
			if(extdeps.size()==1) {
				para.appendChild(" module depends on this module being activated.");
			}else{
				para.appendChild(" modules depends on this module being activated.");
			}			
			section.appendChild(para);
		}
	}
	/**
	 * Determine whether doc is referenced from an absdef PI
	 */
	private boolean isZedAICoreModule(RNGDocument doc, Nodes absdefs) {
		String test = doc.getFile().getName();
		for (int i = 0; i < absdefs.size(); i++) {
			ProcessingInstruction pi = (ProcessingInstruction)absdefs.get(i);
			URI uri = resolveSchema(pi.getValue()); 
			if(uri.toString().endsWith(test)) {				
				return true;
			}
		}
		return false;
	}


	private void buildOverviewInternalDependencies(RNGDocument rng,
			Element section, RNGDocuments context) throws Exception {
		
		List<RNGDocument> intdeps = rng.getDocbookInfoElement().getInternalDependencies(context);
		if(intdeps.size()>0) {
			Element para = qnames.getElement(QNameProvider.Type.ELEMENT_PARA);
			para.appendChild("Activation of this module depends on the ");  
			expandModuleList(para, intdeps);
			if(intdeps.size()==1) {
				para.appendChild(" module also being activated.");
			}else{
				para.appendChild(" modules also being activated.");
			}
			section.appendChild(para);
		}
	}

	private void buildOverviewModuleRequired(RNGDocument rng, Element section)
			throws Exception {
		boolean req = rng.getDocbookInfoElement().isRequiredModule();
		if(req) {
			Element para = qnames.getElement(QNameProvider.Type.ELEMENT_PARA, null, "emphasis");
			para.appendChild("This module must be included in all compliant Z39.86-2012 Profiles.");
			section.appendChild(para);
		}
	}
	
	private void addDescriptionParas(Element section, DocbookElement db) throws Exception {
		
		List<DocbookElement> list = new ArrayList<DocbookElement>();
		
		if(db instanceof DocbookInfoElement) {
			DocbookInfoElement info = (DocbookInfoElement)db;
			list.addAll(info.getModuleDescriptionSub());
			list.add(0, info.getModuleDescriptionMain());
		}else if(db instanceof DocbookAnnotationElement) {
			DocbookAnnotationElement anno = (DocbookAnnotationElement)db;
			list.addAll(anno.getDescriptionSub());
			list.add(0, anno.getDescriptionMain());
			list.add(anno.getDefinitionSpecialization());
		}	
						
		for(DocbookElement desc : list) {
			if(desc==null) continue;
			Element descParsed = XOMUtil.parseWikiSyntax(desc, qnames);	
			String role = desc.getAttributeValue(Constants.ROLE);
			if(role.contains(Constants.DOC_ONLY)) continue;
			Element para = qnames.getElement(QNameProvider.Type.ELEMENT_PARA, null, role);
			XOMUtil.appendChildren(para, descParsed);		
			section.appendChild(para);
		}
	}
	
	private void addSnippets (Element section, String id, String title) throws Exception {
		List<Element> elements = xdoc.getSnippets(id, Destination.absdef);
		if(elements.size()>0) {
			Element examplesSection = qnames.getElement(Type.ELEMENT_SECTION, id + "-examples");
			Element examplesSectionTitle = qnames.getElement(Type.ELEMENT_SUBSECTION_TITLE);
			XOMUtil.appendChildren(examplesSectionTitle, XOMUtil.parseWikiSyntax(title + ": Examples", qnames));
			examplesSection.appendChild(examplesSectionTitle);
			
			int c = 0;
			for(Element snippet : elements) {
				Element example = qnames.getElement(Type.ELEMENT_EXAMPLE_WRAPPER,id+"-example-" + ++c,"example");
				//the elements we get are xi:resolved, and only contain one text node.
				//the elements may contain @snippet-caption, which serves as a caption
				//the elements may contain @snippet-title, which serves as a title
				
				//add the title, preferring the one in the snippet from the inparam one
				Element exampleTitle = qnames.getElement(Type.ELEMENT_EXAMPLE_TITLE);
				List<Node> titleChildren;
				String snippetTitle = snippet.getAttributeValue("snippet-title");				
				if(snippetTitle!=null && snippetTitle.trim().length()>0) {
					titleChildren = XOMUtil.parseWikiSyntax(snippetTitle, qnames);
				}else {
					titleChildren = XOMUtil.parseWikiSyntax(title + ": Example", qnames);
				}
				XOMUtil.appendChildren(exampleTitle, titleChildren);
				example.appendChild(exampleTitle);
				
				//add the caption, if any
				String snippetCaption = snippet.getAttributeValue("snippet-caption");
				if(snippetCaption != null && snippetCaption.trim().length()>0) {
					Element exampleCaption = qnames.getElement(Type.ELEMENT_EXAMPLE_CAPTION,null, "caption");
					List<Node> captionChildren = XOMUtil.parseWikiSyntax(snippetCaption, qnames);
					XOMUtil.appendChildren(exampleCaption, captionChildren);
					example.appendChild(exampleCaption);
				}
				
				//add the actual snippet
				Element exampleListing = qnames.getElement(Type.ELEMENT_EXAMPLE_LISTING, null, null, null, true);
				exampleListing.appendChild(snippet.getValue());
				example.appendChild(exampleListing);
								
				examplesSection.appendChild(example);
			}
			section.appendChild(examplesSection);
		}
		
	}

	private void addLongdesc (Element section, String id, String title) throws Exception {
		List<Element> elements = xdoc.getLongdescs(id, Destination.absdef, OutputGrammar.DOCBOOK);
		if(elements.size()>0) {
			//we just add the longdesc stuff to the parent section
			XOMUtil.appendChildren(section, elements.get(0));			
		}		
	}

	
	private String addTitle(DocbookElement input, Element section, Type titleType) throws Exception {
		Element sectionTitle = qnames.getElement(titleType);
		DocbookElement givenTitle = null;
		if(input instanceof DocbookInfoElement) {
			givenTitle = ((DocbookInfoElement)input).getModuleTitle();
		}else if(input instanceof DocbookAnnotationElement) {
			givenTitle = ((DocbookAnnotationElement)input).getTitle();
		}					
		XOMUtil.appendChildren(sectionTitle, XOMUtil.parseWikiSyntax(givenTitle, qnames));						
		section.appendChild(sectionTitle);
		return givenTitle.getValue();
	}

	
	/**
	 * Add an xreflabel attribute to parent, using a value from db
	 */
	private void addXrefLabel(Element parent, DocbookElement db) {
		if(db==null) {
			throw new NullPointerException();
		}
		String shortTitle = null;
		
		if(db instanceof DocbookInfoElement) {
			shortTitle = ((DocbookInfoElement)db).getModuleTitleXrefLabel();
		}else if (db instanceof DocbookAnnotationElement){
			shortTitle = ((DocbookAnnotationElement)db).getTitleXrefLabel();
		}
		
		if(shortTitle==null) throw new NullPointerException(
				"xreflabel null on " + db.toXML()
				+ " in " + ((RNGDocument)db.getDocument()).getFile().getName());
		
		//strip the optional parenthesis; 'name (context)'
		if(shortTitle.contains(" (")) {
			shortTitle = shortTitle.substring(0, shortTitle.indexOf(' '));
		}
		
		Attribute xreflabel = new Attribute(Constants.XREFLABEL, XOMUtil.stripWikiSyntax(shortTitle));
		
		parent.addAttribute(xreflabel);
		
	}
	
	private Element buildElementOrAttributeDetailsSection(RNGElement element, RNGDocument owner, DefineType type, String tableID) throws Exception {
		
		String id = element.getID();
		
		DocbookAnnotationElement anno = (DocbookAnnotationElement)element.getDocbookDescriptionElement();
		 
		Element detailsSection = qnames.getElement(Type.ELEMENT_SECTION, id, "details");
		
		addXrefLabel(detailsSection, anno);
		
		String title = addTitle(anno, detailsSection, Type.ELEMENT_SUBSECTION_TITLE);

		//add any descriptions and infos from the schema
		addDescriptionParas(detailsSection, anno);
				
		//add longdesc, if any (src/doc/longdescs)
		addLongdesc(detailsSection, id, title);
		
		//build the details table
		Table detailsTable = new Table(id + "details-table","details",anno.getTitle().getValue());
		
		//details: localname
		detailsTable.addDataRow(new String[]{"Local name", "{"+element.getAttributeValue(Constants.NAME)+"}"}, true, null);
		
		//details: namespace URI		
		detailsTable.addDataRow(new String[]{"Namespace",getNsString(element)}, true, null);
		
		
		//details: usage context 		
		//get the usage context alterability attribute 		
		String alterability = anno.getDefinitionContextAlterabilityRestriction();
		
		//add the context description (always present)
		String th = ("fixed".equals(alterability)) ? "Usage context" : "Default usage context";		
		detailsTable.addDataRow(new String[]{th,anno.getDefinitionContext().getValue()}, true, null);
		
		//add context alterability restriction info (if any)		
		if(alterability!=null) {
			detailsTable.addDataRow(new String[]{"Usage context alterability",buildAlterabilityString(alterability,anno.getDefinitionContext(),element)}, true, null, null, ALTERABILITY);
		}
		
		// details: attribute model 
		if(anno.getDefinitionAttlist()!=null) { //if null we are describing details for an attribute
					
			//get the attlist alterability attribute 		
			alterability = anno.getDefinitionAttlistAlterabilityRestriction();
			
			//add the attr model description 
			th = ("fixed".equals(alterability)) ? "Attribute model" : "Default attribute model";		
			detailsTable.addDataRow(new String[]{th,anno.getDefinitionAttlist().getValue()}, true, null);
			
			//add attr model alterability restriction info (if any)		
			if(alterability!=null) {
				detailsTable.addDataRow(new String[]{"Attribute model alterability",buildAlterabilityString(alterability,anno.getDefinitionAttlist(),element)}, true, null, null, ALTERABILITY);
			}
		}
		
		//details: content model	
		//get the content model alterability attribute 		
		alterability = anno.getDefinitionContentAlterabilityRestriction();
		
		//add the content model description (always present both for elements and attributes)
		
		if(element.getLocalName()==Constants.ELEMENT) {
			th = ("fixed".equals(alterability)) ? "Content model" : "Default content model";
		}else {
			th = ("fixed".equals(alterability)) ? "Value(s)" : "Default value(s)";
		}
		//detailsTable.addDataRow(new String[]{th,anno.getDefinitionContent().getValue()}, true, null);
		detailsTable.addDataRow(new String[]{th,getContentDescription(anno)}, true, null);
		
		//add content model alterability restriction info (if any)		
		if(alterability!=null) {
			if(element.getLocalName()==Constants.ELEMENT) {
				th = "Content model alterability";
			}else{
				th = "Value alterability";
			}
			detailsTable.addDataRow(new String[]{th,buildAlterabilityString(alterability,anno.getDefinitionContent(),element)}, true, null, null, ALTERABILITY);
		}

		
		//details: omittable (depends on db:annotation condition="required")		
		detailsTable.addDataRow(new String[]{"Optionality",buildDetailsOmittable(type, anno)}, true, null);
		
		//append the details table to the parent section
		detailsSection.appendChild(detailsTable.table);
		
		//any sch assertions
		List<AnyElement> asserts = element.getSchematronAssertions();
		if(asserts.size()>0) {
			buildDetailsAssertions(type, id, detailsSection, tableID, asserts);
		}
						
		//add module level examples, if any
		addSnippets(detailsSection, id, title);
    
		return detailsSection;
	}

	/**
	 * Build a prose string based on the value of the condition attr on
	 * db:para role ='def-content|def-context|def-attlist'
	 * @param value The value of the condition attribute
	 * @param carrier The element that carries the condition attribute
	 * @param declared The element or attribute being declared (parent of db:annotation) 
	 */
	private String buildAlterabilityString(String value, Element carrier, Element declared) {
		StringBuilder sb = new StringBuilder();
		
		// the value is either 'fixed', in which case the model is completely fixed,
		// or any other value, in which case it is partially fixed
		String carrierRole = carrier.getAttributeValue(Constants.ROLE);
		
		if(value.equals(Constants.FIXED)) {			
			if(carrierRole.contains(Constants.DEF_ATTLIST)) {
				sb.append("This attribute model is");
			}else if(carrierRole.contains(Constants.DEF_CONTEXT)) {
				sb.append("This usage context is");
			}else if(carrierRole.contains(Constants.DEF_CONTENT)) {
				
				if(declared.getLocalName()==Constants.ELEMENT) {
					sb.append("This content model is");
				}else{
					sb.append("The defined value(s) or datatype(s) are");
				}
			}else {
				throw new IllegalStateException(carrier.toXML());
			}		
			sb.append(" fixed, and must not be altered when activating this module.");
		}else {
			sb.append(value);
		}
		return sb.toString();
	}

	private String getContentDescription(DocbookAnnotationElement anno) {
		String content = anno.getDefinitionContent().getValue();
		if(content==null || content.trim().length()==0) {
			content = "{empty}";
		}
		return content;
	}

	private String getNsString(RNGElement element) {
		String ns = element.getNS(true);
		if(element instanceof RNGAttributeElement) {
			ns = element.getNS(false);
			if(ns==null && element.getRNGName().startsWith("xml:")) {				
				ns = Constants.XML_NS;				
			}
		}else if (element instanceof RNGElementElement && ns == null) {
			ns = Constants.ZEDAI_DEFAULT_NAMESPACE;
		}
		return (ns==null) ? "None" : "{"+ns+"}";		
	}
			
	private String buildDetailsOmittable(DefineType type
			, DocbookAnnotationElement anno) throws Exception {
		
		boolean isOmittable = anno.isOmittable();
		StringBuilder sb = new StringBuilder();
		sb.append("This ");
		sb.append(type.name());
		if(!isOmittable) {
			sb.append(" must not ");
		} else {
			sb.append(" may ");
		}
		sb.append("be omitted when activating this module.");
		return sb.toString();
	}

	private void buildDetailsAssertions(DefineType type,
			String id, Element detailsSection, String idref, List<AnyElement> asserts) throws Exception {
				
		if(asserts.size()>0){
			Element assertsPara = qnames.getElement(Type.ELEMENT_PARA);
			assertsPara.appendChild("The following model restrictions apply to this ");
			assertsPara.appendChild(type.name());
			assertsPara.appendChild(":");
			detailsSection.appendChild(assertsPara);
			
			Element assertsList = qnames.getElement(Type.ELEMENT_LIST_ITEMIZED, id + "-assertions", "assertions");
			for(AnyElement assertItem : asserts) {
				Element listitem = qnames.getElement(Type.ELEMENT_LIST_ITEMIZED_ITEM);
				Element listitemPara = qnames.getElement(Type.ELEMENT_PARA);
				XOMUtil.appendChildren(listitemPara, XOMUtil.parseWikiSyntax(assertItem, qnames));
				listitem.appendChild(listitemPara);
				assertsList.appendChild(listitem);
			}
										
			detailsSection.appendChild(assertsList);
			
		}//if(asserts.size()>0)
	}

	private enum DefineType {
		other, element, attribute, data;
	}
	
	private void expandModuleList(Element parent, List<RNGDocument> list) throws Exception {		
		for (int i = 0; i < list.size(); i++) {
			RNGDocument dep = list.get(i);		
			// temp fix to handle ssml id on grammar having no label
			String depID = dep.getID();
			if (depID.contains("feature-ssml")) {
			     Element link = new Element("a", "http://www.w3.org/1999/xhtml");
			     Attribute href = new Attribute("href", "#");
			     link.addAttribute(href);
			     link.appendChild("SSML Feature");
			     parent.appendChild(link);
			}
			else {
    			Element link = qnames.getLink("#"+depID);
	       		parent.appendChild(link);
	       	}
			if(i == list.size()-2) {
				parent.appendChild(" and ");							
			}else if (i != list.size()-1){
				parent.appendChild(", ");
			}
		}		
	}

	private URI resolveSchema(String value) {
		value = value.replace("src=", "").replace("\"", "").replace("\'", "").trim();
		if(value.startsWith("/")) value = value.substring(1);
		return schemaPreprocessedDir.toURI().resolve(value);		
	}

	private void setupContext(String projDir) throws Exception {
		projectDir = new Directory(projDir);
		schemaSrcDir = new Directory(projectDir, "src/schema");
		tempDir = new Directory(projectDir, "temp");
		if(!projectDir.exists() || !schemaSrcDir.exists() || !tempDir.exists()) {
			throw new InvalidParameterException(projDir);
		}		
		schemaPreprocessedDir = new Directory(tempDir, "all-src-rng-preprocessed");		
		allGrammars = new RNGDocuments(schemaPreprocessedDir.getFiles(true, ".+\\.rng$"));
		xdoc = new DocXIncludeProcessor(projectDir);	
		AntHelper.update(schemaPreprocessedDir, schemaSrcDir, new File(projectDir,"build-ai.xml"));
	}


	private Document setupSource(String systemID) throws Exception {
		Document d = XOMUtil.build(FilenameOrFileURI.toURI(systemID).toString());
		XIncluder.resolveInPlace(d);		
		return d;
	}


	public static void main(String[] args) throws Exception {
		System.out.println(("AbsDefExpander..."));
		new AbstractDefExpander(args);
		System.out.println(("AbsDefExpander done."));
	}
	
	private void stdout(Object... strings) {
		out(System.out, false, strings);			
	}
	
	private void errout(Object... strings) {
		out(System.err, true, strings);			
	}
	
	private void out(PrintStream out, boolean overrideVerbose, Object... strings) {
		if(sb==null) sb = new StringBuilder();
		if(overrideVerbose || verbose) {
			for(Object s : strings) {
				sb.append(s);
			}
			out.println(sb.toString());
			sb.delete(0, sb.length());
		}	
		
	}
	
	private class Table {
		private Element table = null;
		private Element headerRow = null;
		
		Table(String[] headers, String id, String role, String caption) throws Exception {
			this(headers, id, role, caption, false);
		}
		
		Table(String id, String role, String caption) throws Exception {
			this(id, role, caption, false);
		}
		
		Table(String[] headers, String id, String role, String caption, boolean informalTable) throws Exception {
			this(id, role, caption, informalTable);
			
			headerRow = qnames.getElement(Type.ELEMENT_TABLE_ROW);
			table.appendChild(headerRow);
			
			for (int i = 0; i < headers.length; i++) {
				Element th = qnames.getElement(Type.ELEMENT_TABLE_CELL_HEAD);
				XOMUtil.appendChildren(th, XOMUtil.parseWikiSyntax(headers[i], qnames));
				headerRow.appendChild(th);
			}
			
		}
		
		Table(String id, String role, String caption, boolean informalTable) throws Exception {
			if(!informalTable) {
				table = qnames.getElement(Type.ELEMENT_TABLE,id, role, caption);
			} else {
				table = qnames.getElement(Type.ELEMENT_TABLE_INFORMAL,id);
			}			
		}
		
		private void addDataRow(Element dataRow) {
			table.appendChild(dataRow);
		}
		
		private Element addDataRow(String[] values, boolean firstAsHead, RNGElement firstAsNameLink) throws Exception {
			return addDataRow(values, firstAsHead, firstAsNameLink, null, null);
		}
		
		private Element addDataRow(String[] values, boolean firstAsHead, RNGElement firstAsNameLink, String id, String role) throws Exception {
			Element dataRow = qnames.getElement(Type.ELEMENT_TABLE_ROW,id);
			if(role!=null) { //db:tr does not have @role, add class manually
				Attribute cl = new Attribute("class", role);
				dataRow.addAttribute(cl);
			}
			table.appendChild(dataRow);
			
			for (int i = 0; i < values.length; i++) {
				Element cell = qnames.getElement(Type.ELEMENT_TABLE_CELL);
				
				if(i==0 && firstAsHead) {
					cell = qnames.getElement(Type.ELEMENT_TABLE_CELL_HEAD);
				}
				
				if(i==0 && firstAsNameLink != null) {
					Element code = qnames.getElement(QNameProvider.Type.ELEMENT_CODE);		
					code.appendChild(qnames.getLink("#" + firstAsNameLink.getID(), firstAsNameLink.getRNGName()));
					cell.appendChild(code);
				}else{
					XOMUtil.appendChildren(cell, XOMUtil.parseWikiSyntax(values[i], qnames));
				}				
				dataRow.appendChild(cell);
			}
			return dataRow;
		}
		
		
	}
}

//private void buildDetailsContentModelFixedPara(DefineType type, AnyElement rdfDescription,
//Element detailsSection) throws Exception {
//Element content = rdfDescription.getChildElements(Constants.CONTENT, Constants.Z_M12N_VOCAB_NS).get(0);
//Attribute fixed = content.getAttribute(Constants.FIXED, Constants.Z_M12N_VOCAB_NS);
//if(fixed!=null && fixed.getValue().equals("true")) {
//Element fixedPara = qnames.getElement(Type.ELEMENT_PARA);
//fixedPara.appendChild("The ");
//if(type == DefineType.element) {
//	fixedPara.appendChild(" content model of this element is");	
//}else if(type == DefineType.attribute) {
//	fixedPara.appendChild(" allowed values of this attribute are");
//}else {
//	throw new InvalidParameterException(type.name());
//}
//fixedPara.appendChild(" fixed, and must not be altered on activation of this module.");
//detailsSection.appendChild(fixedPara);
//}
//}

//private void buildDetailsOmittable(DefineType type, RDFDescriptionElement rdfDescription,
//Element detailsSection) throws Exception {
//
//boolean isOmittable = rdfDescription.isOmittable();
//Element omittablePara = qnames.getElement(Type.ELEMENT_PARA);
//omittablePara.appendChild("This ");
//omittablePara.appendChild(type.name());
//if(!isOmittable) {
//omittablePara.appendChild(" must not ");
//} else {
//omittablePara.appendChild(" may ");
//}
//omittablePara.appendChild("be omitted when activating this module.");
//detailsSection.appendChild(omittablePara);
//}
//private void buildDetailsTableRef(RNGDocument owner, DefineType type,
//Element detailsSection, String tableID) throws Exception {
//Element tableRef = qnames.getElement(Type.ELEMENT_PARA);				
//tableRef.appendChild("Refer to ");
//tableRef.appendChild(qnames.getLink("#"+tableID, null));
//tableRef.appendChild(" for formal definitions of the identity and initial context and ");
//if(type == DefineType.element) {
//tableRef.appendChild("content model");	
//}else if(type == DefineType.attribute) {
//tableRef.appendChild("value");
//} else {
//throw new InvalidParameterException(type.name());
//}
//tableRef.appendChild(" defaults of this ");
//tableRef.appendChild(type.name());
//tableRef.appendChild(".");				
//detailsSection.appendChild(tableRef);
//}
//private String preModNS(String ns) {
//if(ns==null || ns.trim().length()==0) {
//	return "None";
//}		
//else if(ns.equals(Constants.ZEDAI_DEFAULT_NAMESPACE)) {
//	return "[[#coreNamespace Default]]";
//}		
//return ns;
//}