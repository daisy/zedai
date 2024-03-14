package org.daisy.z3998;

import java.util.List;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;
import nu.xom.ProcessingInstruction;
import nu.xom.Text;

import org.daisy.util.file.Directory;
import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3998.xom.XOMUtil;

/**
 * Expand examples in docbook specs or primers. We use this instead of standard xinclude
 * to increase odds of schema-valid examples without the need for manual inspection.
 * The key is the PI <?example id="foo" ?>, embedded in the docs
 * <p>Arguments:</p>
 * <ol start="0">
 * <li>path to project root dir</li>
 * <li>path to input spec or primer</li>
 * <li>spec or primer output path</li>
 * </ol>
 */
public class SpecExampleExpander {
	private final Directory projectDir;
	private Attribute spaceTemplateAttribute;
	int count;
	
	public SpecExampleExpander(String[] args) throws Exception {
		
		projectDir = new Directory(args[0]);
		spaceTemplateAttribute = new Attribute("xml:space", Constants.XML_NS, "preserve");
		
		Document doc = XOMUtil.build(FilenameOrFileURI.toURI(args[1]).toString());	
		
		DocXIncludeProcessor docxi = new DocXIncludeProcessor(projectDir);
		
		Nodes examples = doc.getRootElement().query("//processing-instruction('example')");
						
		for (int i = 0; i < examples.size(); i++) {
			ProcessingInstruction pi = (ProcessingInstruction) examples.get(i);
			String id = getID(pi);
			
			List<Element> snippets = docxi.getSpecExample(id);
			if(snippets.isEmpty()) throw new IllegalStateException("no spec example found for id " + id);
			if(snippets.size()>1) System.err.println("WARNING: more than one spec example matched " + id);
			Element example = snippets.get(0);
			Text text = new Text(example.getValue());
			pi.getParent().replaceChild(pi, text);
			((Element)text.getParent()).addAttribute((Attribute)spaceTemplateAttribute.copy());
			++count;
		}
		
		XOMUtil.serialize(doc,FilenameOrFileURI.toFile(args[2]));
	}

	private String getID(ProcessingInstruction pi) {
		String value = pi.getValue();
		return value.replace("id=", "").replace("\"", "").replace("\'", "").trim();						
	}

	public static void main(String[] args) throws Exception {
		System.out.println(("SpecExampleExpander..."));
		SpecExampleExpander see = new SpecExampleExpander(args);
		System.out.println(("SpecExampleExpander done. Expanded " + see.count + " examples."));
	}

}
