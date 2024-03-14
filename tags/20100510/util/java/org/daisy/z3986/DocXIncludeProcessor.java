package org.daisy.z3986;

import java.io.File;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import nu.xom.Attribute;
import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Node;
import nu.xom.Nodes;
import nu.xom.xinclude.XIncluder;
import nu.xom.xslt.XSLTransform;

import org.daisy.util.file.Directory;
import org.daisy.util.file.FileUtils;
import org.daisy.z3986.xom.XOMUtil;

/**
 * Preprocess the snippet, longdesc and spec example sources, escaping using XInclude
 * <p>Arguments:</p>
 * <ol>
 * <li>0: path to zednext project top dir</li>
 * </ol>
 */
public class DocXIncludeProcessor {
		
	private final Directory projectDir;
	private final Directory snippetsDir;
	private final Directory longdescsDir;
	private final Directory specExamplesDir;
	private final Directory tempDir;
	private final Directory tempXIncludeDir;
	private final Directory snippetsOutputDir;
	private final Directory longdescsOutputDir;
	private final Directory specExamplesOutputDir;
	private final List<ResultDoc> processedSnippetDocs;
	private final List<ResultDoc> processedLongdescDocs;
	private final List<ResultDoc> processedSpecExampleDocs;
	private XSLTransform dbToXhtTransform;
	
	Element xincTemplateElement;
	Attribute spaceTemplateAttribute;
	Element dbProgramListingTemplate;	
	
	public DocXIncludeProcessor(Directory projectRoot) throws Exception {
		this(new String[]{projectRoot.toString()});					
	}
		
	public DocXIncludeProcessor(String[] args) throws Exception {
				
		if(args.length!=1) throw new InvalidParameterException(args.toString());
		projectDir = new Directory(args[0]);
		snippetsDir = new Directory(projectDir, "src/doc/snippets");
		longdescsDir = new Directory(projectDir, "src/doc/longdescs");
		specExamplesDir = new Directory(projectDir, "src/spec/examples");
		tempDir = new Directory(projectDir, "temp");
		if(!projectDir.exists()) throw new IllegalStateException(projectDir.toString());
		if(!snippetsDir.exists()) throw new IllegalStateException(snippetsDir.toString());
		if(!longdescsDir.exists()) throw new IllegalStateException(longdescsDir.toString());
		if(!specExamplesDir.exists()) throw new IllegalStateException(specExamplesDir.toString());
		if(!tempDir.exists()) throw new IllegalStateException(tempDir.toString());
		
		processedSnippetDocs = new ArrayList<ResultDoc>();
		processedLongdescDocs = new ArrayList<ResultDoc>();
		processedSpecExampleDocs = new ArrayList<ResultDoc>();
		
		tempXIncludeDir = new Directory(tempDir, "xinclude-temp");
		tempXIncludeDir.mkdirs();

		snippetsOutputDir = new Directory(tempDir, "snippets-processed");
		longdescsOutputDir = new Directory(tempDir, "longdescs-processed");
		specExamplesOutputDir = new Directory(tempDir, "spec-examples-processed");
		
		//if the output dirs exist and have contents, just reload
		//(this class is instantiated several times during an Ant pass)
		
		Collection<File> snippetFiles = null;
		Collection<File> longdescFiles = null;
		Collection<File> specExampleFiles = null;

		boolean reuse = false;
		if(snippetsOutputDir.exists() && longdescsOutputDir.exists() && specExamplesOutputDir.exists()) {
			snippetFiles = snippetsOutputDir.getFiles(true, ".+snippets.xml");
			longdescFiles = longdescsOutputDir.getFiles(true, ".+longdescs.xml");
			specExampleFiles = specExamplesOutputDir.getFiles(true, ".+examples.xml");
			if(snippetFiles.size()>0 && longdescFiles.size()>0 && specExampleFiles.size()>0) {
				reuse = true;
			}	
		}
		
		File xsl = new File(longdescsDir,"/docbook2xhtml-lite.xsl");
		if(!xsl.exists()) throw new IllegalStateException(xsl.toString());		
		System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");		
	    dbToXhtTransform = new XSLTransform(new Builder().build(xsl.toURI().toString()));

		spaceTemplateAttribute = new Attribute("xml:space", Constants.XML_NS, "preserve");
		dbProgramListingTemplate = new Element("programlisting", Constants.DOCBOOK_NS);
		dbProgramListingTemplate.addAttribute(spaceTemplateAttribute);
		
		if(reuse) {			
			System.out.println("Reusing existing longdescs and snippets...");
			for(File f : snippetFiles) {
				processedSnippetDocs.add(new ResultDoc(XOMUtil.build(f)));
			}
			for(File f : longdescFiles) {
				processedLongdescDocs.add(new ResultDoc(XOMUtil.build(f)));
			}
			for(File f : specExampleFiles) {
				processedSpecExampleDocs.add(new ResultDoc(XOMUtil.build(f)));
			}
		}else{
			System.out.println("Creating a new set of longdescs and snippets...");
			snippetsOutputDir.mkdirs();		
			longdescsOutputDir.mkdirs();
			specExamplesOutputDir.mkdirs();
						
			xincTemplateElement = new Element("include", Constants.XINCLUDE_NS);
			xincTemplateElement.addAttribute(new Attribute("parse", "text"));
			xincTemplateElement.addAttribute(new Attribute("encoding", "UTF-8"));
			xincTemplateElement.addAttribute(new Attribute("href", ""));
													    
			snippetFiles = snippetsDir.getFiles(true, ".+snippets.xml");
			longdescFiles = longdescsDir.getFiles(true, ".+longdescs.xml");
			specExampleFiles = specExamplesDir.getFiles(true, ".+examples.xml");
					
			for(File snippetFile : snippetFiles) {
				Document processed = process(snippetFile, false);
				processedSnippetDocs.add(new ResultDoc(processed));
				XOMUtil.serialize(processed, new File(snippetsOutputDir,snippetFile.getName()));
			}
			
			for(File longdescFile : longdescFiles) {
				Document processed = process(longdescFile, true);
				processedLongdescDocs.add(new ResultDoc(processed));
				XOMUtil.serialize(processed, new File(longdescsOutputDir,longdescFile.getName()));			
			}
			
			for(File exampleFile : specExampleFiles) {
				Document processed = process(exampleFile, false);
				processedSpecExampleDocs.add(new ResultDoc(processed));
				XOMUtil.serialize(processed, new File(specExamplesOutputDir,exampleFile.getName()));
			}
			
			tempXIncludeDir.deleteContents(true);
			tempXIncludeDir.delete();
		} //if need to re-render
		System.out.println(this.getClass().getSimpleName() + " done.");
	}
	
	public List<ResultDoc> getProcessedSnippetDocs() {
		return processedSnippetDocs;
	}
	
	public List<ResultDoc> getProcessedLongdescDocs() {
		return processedLongdescDocs;
	}
	
	public List<ResultDoc> getProcessedSpecExampleDocs() {
		return processedSpecExampleDocs;
	}
	
	/**
	 * Get a list of snippets for given id. The return elements
	 * are dummy zedai:snippet elements, with a text-only child.
	 * @return A list that may be empty, but never null.
	 */
	public List<Element> getSnippets(String id, Destination dest) {
		List<Element> ret = new ArrayList<Element>(1);
		for(ResultDoc sd : processedSnippetDocs) {
			if(sd.elements.containsKey(id)) {
				ret.addAll(sd.getElements(id, dest));
			}	
		}
		return ret;
	}

	/**
	 * Get a list of spec examples for given id. The return elements
	 * are dummy zedai:snippet elements, with a text-only child.
	 * @return A list that may be empty, but never null.
	 */
	public List<Element> getSpecExample(String id) {
		List<Element> ret = new ArrayList<Element>(1);
		for(ResultDoc sd : processedSpecExampleDocs) {
			if(sd.elements.containsKey(id)) {
				ret.addAll(sd.getElements(id, Destination.spec));
			}	
		}
		return ret;
	}
	
	/**
	 * Get a list of longdescs for given id.
	 * @return A list that may be empty, but never null.
	 * @throws Exception 
	 */
	public List<Element> getLongdescs(String id, Destination dest, QNameProvider.OutputGrammar format) throws Exception {
		List<Element> ret = new ArrayList<Element>(1);
		
		for(ResultDoc sd : processedLongdescDocs) {
			if(sd.elements.containsKey(id)) {
				ret.addAll(sd.getElements(id, dest));
			}	
		}
		if(format == QNameProvider.OutputGrammar.DOCBOOK) {
			return toDocbook(ret);
		} else {
			return toXhtml(toDocbook(ret));
		}
	}
	
	private List<Element> toDocbook(List<Element> docbookElements) throws Exception {
		//replace any zedai:escape element with a db:programlisting
		for(Element dbElem : docbookElements) {
			toDocbook(dbElem);
		}
		return docbookElements;
	}
	
	private Node toDocbook(Node dbElem) throws Exception {
		//replace any zedai:escape element with a db:programlisting		
		Nodes escapes = dbElem.query("//auth:escape", Constants.namespaces);
		for (int i = 0; i < escapes.size(); i++) {
			Element code = (Element) escapes.get(i);
			Element dbpl = (Element)dbProgramListingTemplate.copy();
			//there is only one text child here assumedly				
			for (int j = 0; j < code.getChildCount(); j++) {
				Node child = code.getChild(j);
				child.detach();
				dbpl.appendChild(child);
			}
			code.getParent().replaceChild(code, dbpl);				
		}			
		return dbElem;
	}
	
	private List<Element> toXhtml(List<Element> docbookElements) throws Exception {
		List<Element> ret = new ArrayList<Element>();
								
		//run the docbook-xhtml transform			    
	    Nodes nodes = new Nodes();
	    for(Element dbe : docbookElements) {
	    	nodes.append(dbe);	
	    }	    	    
	    Nodes results = dbToXhtTransform.transform(nodes);
		for (int i = 0; i < results.size(); i++) {
			Element result = (Element)results.get(i);
			ret.add(result);
		}
	    return ret;
	}

	public enum Destination {
		absdef,
		doc,
		spec,
		any;
	}
			
	private Document process(File input, boolean isLongdescMode) throws Exception {
		Document inputDoc = XOMUtil.build(input.toURI().toString());
		
		//resolve any hardcoded xincludes
		XIncluder.resolveInPlace(inputDoc);
				
		//find each element with @about (which is the indicator we use)
		Nodes nodes = inputDoc.getRootElement().query("//*[@about]"); 
		
		//push the content of each to-escape element out to a text file				
		for (int i = 0; i < nodes.size(); i++) {
			if(!isLongdescMode) {
				//in the snippet case, push all element contents
				pushContents((Element) nodes.get(i));
			} else {
				//in the longdesc case, only push z:escape descendants
				Nodes escapes = ((Element) nodes.get(i)).query(".//auth:escape", Constants.namespaces);
				for (int k = 0; k < escapes.size(); k++) {
					pushContents((Element) escapes.get(k));
				}
			}			
		}
						
		//re-xi:resolve the document 		
		XIncluder.resolveInPlace(inputDoc);		
				
		return inputDoc;
	}

	private void pushContents(Element elem) throws Exception {
		File tempFile = getTempFile();													
		elem.addAttribute((Attribute)spaceTemplateAttribute.copy());
		String contents = getContents(elem);		
		FileUtils.writeStringToFile(tempFile, contents, "UTF-8");		
		//replace the content of the element with an xi:include parse=text
		Element xinc = (Element)xincTemplateElement.copy();
		xinc.getAttribute("href").setValue(tempFile.toURI().toString());		
		elem.removeChildren();
		elem.appendChild(xinc);
	}
	
	private String getContents(Element elem) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < elem.getChildCount(); i++) {
			Node child = elem.getChild(i);
			sb.append(child.toXML());
		}
		return sb.toString();
	}

	int c = 1;
	private File getTempFile() {
		StringBuilder sb = new StringBuilder();
		sb.append("xinc_");
		sb.append(++c);
		sb.append(".txt");
		return new File(tempXIncludeDir,  sb.toString());
	}

	public static void main(String[] args) throws Exception {
		new DocXIncludeProcessor(args);
	}
	
	public class ResultDoc extends Document {
		
		
		//map where key = the values of @about 
		private Map<String, List<ProcessedElement>> elements;
		
		public ResultDoc(Document doc) {
			super(doc);
			elements = new HashMap<String, List<ProcessedElement>>();
			Nodes nodes = doc.getRootElement().query("//*[@about]", Constants.namespaces); 			
			for (int i = 0; i < nodes.size(); i++) {
				Element element = (Element) nodes.get(i);				
				String[] abouts; 
				Destination dest;
				try{
					abouts = element.getAttributeValue("about").split(" ");
					dest = Destination.valueOf(element.getAttributeValue(DESTINATION_ATTRIB));
				}catch (Exception e) {
					throw new IllegalStateException("missing dest or about attribute on" + element.toXML());
				}
				for (int j = 0; j < abouts.length; j++) {
					String about = abouts[j];
					if(!elements.containsKey(about)) {
						elements.put(about, new ArrayList<ProcessedElement>(1));
					}
					elements.get(about).add(new ProcessedElement(element, dest));
				}				
			}			
		}
		
		/**
		 * Get a 0..n size list of elements for the given id, 
		 * or null if none exists.
		 */
		public List<Element> getElements(String id, Destination dest) {
			List<ProcessedElement> list = elements.get(id);
			List<Element> ret = new ArrayList<Element>();
			for(ProcessedElement pe : list) {
				if(dest == Destination.any || pe.dest == Destination.any || pe.dest == dest) {
					ret.add(pe.element);
				}
			}
			return ret;
		}
		
	}
	
	private class ProcessedElement {
		private final Element element;
		private final Destination dest;

		public ProcessedElement(Element element, Destination dest) {
			this.element = element;
			this.dest = dest;
		}
	}
	
	private static final String DESTINATION_ATTRIB = "dest";
 
}
