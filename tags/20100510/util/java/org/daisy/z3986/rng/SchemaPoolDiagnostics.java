package org.daisy.z3986.rng;

import java.io.File;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import nu.xom.Attribute;
import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.util.file.Directory;
import org.daisy.z3986.Constants;
import org.daisy.z3986.ant.AntHelper;
import org.daisy.z3986.rng.model.AnyElement;
import org.daisy.z3986.rng.model.RDFDescriptionElement;
import org.daisy.z3986.rng.model.RNGDocument;
import org.daisy.z3986.rng.model.RNGDocuments;
import org.daisy.z3986.rng.model.RNGElement;
import org.daisy.z3986.rng.model.RNGRefElement;
import org.daisy.z3986.rng.model.RNGValueElement;

/**
 * Run diagnostics on the schema pool.
 * Note - this needs to be run on the preprocessed schemas (see Ant)
 */
public class SchemaPoolDiagnostics {
		
	private final Directory projectDir;
	private final Directory driversDir;
	private final Directory tempDir;
	private final Directory tempRngPreprocessedDir;
	private final File antBuildFile;
	//private final File aiSpecSource;
	private RNGDocuments drivers;			//drivers
	private RNGDocuments coremodules;		//core modules
	private RNGDocuments features;			//feature rng's that we control (can edit)
	private RNGDocuments ignores; 			//any rng's that we dont control (cant edit)
	private RNGDocuments all;				//every rng in the src/schema folder
	private int problemCounter = 0;
	
	/**
	 * Check various properties of the schema pool
	 * <p>Arguments:</p>
	 * <ol start="0">
	 * <li>path to zednext project top dir</li>
	 * <li>['true'|'false'] whether to run the diagnostics code (default true)</li>
	 * <li>['true'|'false'] whether to run the info-print code (default false)</li>
	 * </ol>
	 */
	public SchemaPoolDiagnostics(String[] args) throws Exception {
		
		projectDir = new Directory(args[0]);
		driversDir = new Directory(projectDir, "src/schema");
		tempDir = new Directory(projectDir, "temp");
		tempRngPreprocessedDir = new Directory(tempDir, "all-src-rng-preprocessed");
		antBuildFile = new File(projectDir,"build-ai.xml");
				
		AntHelper.update(tempRngPreprocessedDir, driversDir, antBuildFile);
		
		boolean runDiagnostics = (args.length > 1) ? Boolean.parseBoolean(args[1]) : true;
		boolean runPrintInfo = (args.length > 2) ? Boolean.parseBoolean(args[2]) : false;
		
		buildCollections();
		
		if(runDiagnostics) {									
			checkDrivers();		
			checkGrammars(coremodules);		
			checkGrammars(features);		
			if(problemCounter == 0) {
				stdout("\nDiagnostics summary: No potential problems recorded");
			}else {
				errout("\nDiagnostics summary:", problemCounter, " potential problems recorded");
			}
		}
		
		if(runPrintInfo) {
			printBaseRDFInfo(coremodules, false);
		}
		
	}
	
	/**
	 * Print fundamental RDF info of modules and optionally patterns, for quick overview of consistency
	 * @throws Exception 
	 */
	private void printBaseRDFInfo(RNGDocuments docs, boolean titlesOnly) throws Exception {
		stdout("\n===============================================\nRDF meta overview ", 
		"\n===============================================\n");
		
		for(RNGDocument doc : docs) {
			stdout(doc.getRDFDescriptionElement().getDcTitle().getValue());
			if(!titlesOnly) {
				stdout("   desc:: ", doc.getRDFDescriptionElement().getDcDescription().getValue());
				for(AnyElement info :doc.getRDFDescriptionElement().getInfoElements()) {
					stdout("   info:: ", info.getValue());
				}
			}
			for(RNGElement pattern : doc.getAllRDFAnnotatedPatterns()) {
				RDFDescriptionElement rdf = pattern.getRDFDescriptionElement();
				stdout("   ", rdf.getDcTitle().getValue(), " [", rdf.getShortTitle() , "]");
				if(!titlesOnly) {
					stdout("      desc:: ", rdf.getDcDescription().getValue());
					for(AnyElement info :rdf.getInfoElements()) {
						stdout("      info:: ", info.getValue());
					}
				}	
			}	
			stdout("\n");
		}		
	}

	private void checkGrammars(RNGDocuments grammars) throws Exception {
		for(RNGDocument rng : grammars) {
			stdout("\n===============================================\nRunning Diagnostics on ", rng.getFile().getName(), 
					"\n===============================================\n");
				listOmittable(rng);
				checkHasModuleLevelRDF(rng);
				checkModuleLevelRDF(rng, grammars);
				checkHasDefineLevelRDF(rng);
				checkHasValueDocumentation(rng);	
				checkRdfResourceValues(rng);
				checkShortTitle(rng);
		}	
	}
	
	/**
	 * List the omttiable/non-omittable state of each RDF-ized construct in the module  
	 * (depends on <dcterms:isRequiredBy rdf:resource="."/>)
	 * flag set.
	 * @param rng
	 * @throws Exception 
	 */
	private void listOmittable(RNGDocument rng) throws Exception {
		
		StringBuilder sbOmittable = new StringBuilder("Omittable patterns:\n");
		StringBuilder sbNonOmittable = new StringBuilder("Non-omittable patterns:\n");
		
		List<RNGElement> list = rng.getAllRDFAnnotatedPatterns();
		List<Element> omittable = new ArrayList<Element>();
		List<Element> nonomittable = new ArrayList<Element>();
		
		for(RNGElement elem : list) {
			Element print = (Element)elem.copy();
			print.removeChildren();
			if(elem.getRDFDescriptionElement().isOmittable()) {				
				omittable.add(print);								
			}else {
				nonomittable.add(print);
			}
		}
		
		if(omittable.isEmpty()) {
			sbOmittable.append("   None.\n");
		}else {			
			for(Element omit : omittable) {
				sbOmittable.append("   ").append(omit.toXML().replace("xmlns=\"http://relaxng.org/ns/structure/1.0\"", "")).append("\n");	
			}			
		}
		
		if(nonomittable.isEmpty()) {
			sbNonOmittable.append("   None.\n");
		}else {			
			for(Element nonomit : nonomittable) {
				sbNonOmittable.append("   ").append(nonomit.toXML().replace("xmlns=\"http://relaxng.org/ns/structure/1.0\"", "")).append("\n");	
			}			
		}
		
		stdout(sbOmittable.toString());
		stdout(sbNonOmittable.toString());
	}

	private void checkDrivers() throws Exception {		
		//list modules not included in driver
		for(RNGDocument driver: drivers) {
			stdout("\n===============================================\nRunning Diagnostics on driver ", driver.getFile().getName(), 
			"\n===============================================\n");
			
			checkDriverDirectModuleIncludes(driver);
		}
		
	}

	private void checkDriverDirectModuleIncludes(RNGDocument driver) throws Exception {
		stdout("Direct Module includes:");
		List<RNGDocument> notIncluded = new ArrayList<RNGDocument>();
		for(RNGDocument include : coremodules) {
			if(!driver.includes(include)) {
				notIncluded.add(include);
			}
		}
		if(!notIncluded.isEmpty()) {
			StringBuilder sb = new StringBuilder();
			sb.append("    ").append(driver.getFile().getName()).append(" does not directly include core modules\n");
			for(RNGDocument missing : notIncluded) {
				sb.append("      ").append(missing.getFile().getName()).append(",\n");
			}
			stdout(sb.toString());
		}
		
		notIncluded.clear();
		
		for(RNGDocument include : features) {
			if(!driver.includes(include)) {
				notIncluded.add(include);
			}
		}
		if(!notIncluded.isEmpty()) {
			StringBuilder sb = new StringBuilder();
			sb.append("    ").append(driver.getFile().getName()).append(" does not directly include feature modules\n");
			for(RNGDocument missing : notIncluded) {
				sb.append("      ").append(missing.getFile().getName()).append(",\n");
			}
			stdout(sb.toString());
		}
	}

	
	private void checkRdfResourceValues(RNGDocument rng) throws Exception{
		Nodes rdfrs = rng.getDocument().query("//*[@rdf:resource]", Constants.namespaces);
		for (int i = 0; i < rdfrs.size(); i++) {
			Element elem = (Element) rdfrs.get(i);			
			String value = elem.getAttributeValue(Constants.RESOURCE, Constants.RDF_NS);
			if(value.trim().length() < 1) {
				problemCounter++;
				stdout("[prob] An @rdf:resource value is zero length after trim\n");
			}
		}
		
	}

	/**
	 * Check that internal dependencies stated in module-level RDF are correct
	 * (the external ones are added by the preprocess XSLT)
	 * @param rng
	 * @throws Exception
	 */
	private void checkDependencies(RNGDocument rng) throws Exception {
		 
		StringBuilder sb = new StringBuilder();
		sb.append("Stated dependencies:\n");
		
		boolean prob = false;
		
		RDFDescriptionElement rdfDescription = rng.getRDFDescriptionElement();
		if(rdfDescription==null) return;
		//check for missing dependency declarations
		List<RNGRefElement> refs = rng.getRNGRefs();
		List<String> checked = new ArrayList<String>();
		
		for(RNGRefElement ref : refs) {
			if(checked.contains(ref.getRNGName())) continue;
			checked.add(ref.getRNGName());
			if(rng.getRNGDefines(ref.getRNGName()).size() == 0) {
				//the ref is not to a local define
				//get other grammars that contain this define
				List<RNGDocument> grammarsWithDefine = all.getRNGDocumentsWithDefines(ref.getRNGName());
				//if at least one of these arent listed locally, report
				List<RNGDocument> stated = rdfDescription.getInternalDependencies(all);
				boolean match = false;
				for(RNGDocument grammar : grammarsWithDefine) {
					if(stated.contains(grammar)) {
						match = true;
					}
				}
				if(!match) {
					problemCounter++;
					prob = true;										
					sb.append("   [prob] The ref ");
					sb.append(ref.getRNGName());
					sb.append(" does not resolve to a stated dependency.");
					sb.append("\n");
					sb.append("      Grammars that contain this define are: ");
					for(RNGDocument grammar : grammarsWithDefine) {
						sb.append(grammar.getFile().getName());
						sb.append(" ");
					}
					sb.append("\n");
					
					if(stated.size()>0){
						sb.append("      Stated dependencies are: ");
						for(RNGDocument grammar : stated) {
							sb.append(grammar.getFile().getName());
							sb.append(" ");
						}
					}else{
						sb.append("      This module states no dependencies.");
					}
					sb.append("\n");					
				}
			}			
		}		
		
		//check for false dependency declarations
		List<RNGDocument> stated = rdfDescription.getInternalDependencies(all);
		for(RNGDocument dep : stated) {
			boolean resolved = false;
			for(RNGRefElement ref : refs) {
				//if non of the refs are avail as defines in dep, report
				if(dep.getRNGDefines(ref.getRNGName()).size()>0) {
					resolved = true;
				}
			}
			if(!resolved) {
				prob = true;
				problemCounter++;
				sb.append("    [prob] The stated dependency " 
						+ dep.getFile().getName()   + " seems to be false\n");
			}
		}
		
		if(!prob) {
			sb.append("    No problems detected.");
		}
		stdout(sb.toString());
	}

	private void checkHasValueDocumentation(RNGDocument rng) throws Exception {
		List<RNGElement> missing = new ArrayList<RNGElement>();
		List<RNGValueElement> toCheck = rng.getRNGValues();
		for(RNGValueElement elem: toCheck) {
			if(elem.getDocumentationNextSibling()==null) {
				missing.add(elem);
			}
		}
		if(missing.size()>0) {
			StringBuilder sb = new StringBuilder();			
			sb.append("\n[prob] Lacking value documentation for:\n"); 
			for(RNGElement elem : missing) {
				problemCounter++;
				sb.append("     ").append(elem.toXML()).append(", ");
			}		
			stdout(sb.toString());
		}
	}

	private void checkHasDefineLevelRDF(RNGDocument rng) throws Exception {
		//check all elements and attributes
		//TODO also add data? 
		List<RNGElement> missing = new ArrayList<RNGElement>();
		
		List<? extends RNGElement> toCheck = rng.getRNGElements();
		for(RNGElement elem: toCheck) {			
			if(elem.getRDFDescriptionElement()==null) {
				missing.add(elem);
			}
		}
		
		toCheck = rng.getRNGAttributes();
		for(RNGElement elem: toCheck) {
			if(elem.getRDFDescriptionElement()==null) {
				missing.add(elem);
			}
		}
		
		if(missing.size()>0){
			StringBuilder sb = new StringBuilder();			
			sb.append("\nMissing inlined RDF for:\n"); 
			for(RNGElement elem : missing) {				
				Element desc = (Element)elem.copy();
				desc.removeChildren();				
				sb.append("   ").append(desc.toXML().replace("xmlns=\"http://relaxng.org/ns/structure/1.0\" ", "")).append(",\n");
				
			}		
			stdout(sb.toString());
		}
	}

	private void checkHasModuleLevelRDF(RNGDocument rng) throws Exception {
		RDFDescriptionElement rdfDesc = rng.getRDFDescriptionElement();
		if(rdfDesc==null){
			problemCounter ++;
			errout("   ", rng.getFile().getName(), " has no module-level RDF");
		}
	}
	
	private void checkModuleLevelRDF(RNGDocument rng, RNGDocuments context) throws Exception {
		RDFDescriptionElement rdfDesc = rng.getRDFDescriptionElement();
		if(rdfDesc!=null){					
			//check some deets
			//stated dependencies
			checkDependencies(rng);	
		}
	}

	private void checkShortTitle(RNGDocument rng) {
		Nodes carriers = rng.query("//dcterms:title", Constants.namespaces);
		for (int i = 0; i < carriers.size(); i++) {
			Element carrier = (Element) carriers.get(i);
			Attribute zshort = carrier.getAttribute(Constants.SHORT, Constants.Z_M12N_VOCAB_NS);
			if(zshort==null || zshort.getValue().length()<1) {
				problemCounter ++;
				stdout("    [prob] no or bad z:short on element ", carrier.toXML());
			}
		}
	}

	public static void main(String[] args) throws Exception {
		new SchemaPoolDiagnostics(args);
		System.out.println("\n\nSchemaPoolDiagnostics done.");
	}
		
	private void buildCollections() throws Exception {
		
		Collection<File> coll = tempRngPreprocessedDir.getFiles(true, ".+\\.rng$");		
		List<File> list = new ArrayList<File>(coll);
		Collections.sort(list);
		all = new RNGDocuments();
		for(File file : list) {
			if(file.getName().startsWith("_")) continue;
			all.add(file);
		}
		
		coremodules = new RNGDocuments();
		features = new RNGDocuments();
		ignores = new RNGDocuments();
		drivers = new RNGDocuments();
		for(RNGDocument rng : all) {
			if(rng.getFile().getParentFile().getName().equals("mod")) {
				String name = rng.getFile().getName();				
				if(name.matches("^mathml3.+\\.rng$|^xforms.+\\.rng$|^iana-lang-enum\\.rng$")) {
					ignores.add(rng);
				}else if (name.matches(".+-feature-.+\\.rng$|^ssml.+\\.rng$|^its-ruby.rng$")){
					features.add(rng);
				}else {
					coremodules.add(rng);
				}								
			}//if(rng.getFile().getParentFile().getName().equals("mod")) {
			else {
				drivers.add(rng);
			}
		}
				
	}


	private void stdout(Object... strings) {
		out(System.out, strings);			
	}
	
	private void errout(Object... strings) {
		out(System.err, strings);			
	}
	
	private void out(PrintStream out, Object... strings) {
		StringBuilder sb = new StringBuilder();		
		for(Object s : strings) {
			sb.append(s);
		}
		out.println(sb.toString());
	}
		
}