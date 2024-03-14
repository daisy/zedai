package org.daisy.z3998.rng;

import java.io.File;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.daisy.util.file.Directory;
import org.daisy.z3998.DocXIncludeProcessor;
import org.daisy.z3998.QNameProvider;
import org.daisy.z3998.DocXIncludeProcessor.Destination;
import org.daisy.z3998.rng.model.RNGAttributeElement;
import org.daisy.z3998.rng.model.RNGBuilder;
import org.daisy.z3998.rng.model.RNGDocument;
import org.daisy.z3998.rng.model.RNGElementElement;

public class ExternalDocDiagnostics {
	private final Directory projectDir;
	private final Directory tempDir;	
	private final File allRngQuasiSimplified;
	
	/**
	 * Print info on elements lacking snippets and/or longdescs.
	 * <p>Note that only elements with an existing RDF annotation are included in the result listing.</p>
	 * @param args:
	 * <ol start="0">
	 * 	<li>path to zednext project top dir</li>
	 * </ol>
	 */
	public ExternalDocDiagnostics(String[] args) throws Exception {
		projectDir = new Directory(args[0]);
		tempDir = new Directory(projectDir, "temp");
				
		allRngQuasiSimplified = new File(tempDir, "externalDocDiagnosticsSimplified.rng");
		if(!allRngQuasiSimplified.exists()) {
			File allRngSrcDriver = new File(projectDir,"src/schema/_z3998-all.rng");
			new RNGQuasiSimplifier(new String[]{allRngSrcDriver.getPath(),allRngQuasiSimplified.getPath()});
		}
		
		RNGDocument rng = RNGBuilder.build(allRngQuasiSimplified.toURI().toString());
		DocXIncludeProcessor docxi = new DocXIncludeProcessor(projectDir);
		
		report(rng, docxi);
	}

	private void report(RNGDocument rng, DocXIncludeProcessor docxi) throws Exception {
		List<String> missingElementSnippets = new ArrayList<String>();
		List<String> missingElementLongdescs = new ArrayList<String>();
		List<String> missingAttributeSnippets = new ArrayList<String>();
		List<String> missingAttributeLongdescs = new ArrayList<String>();
		
		List<RNGElementElement> elements = rng.getRNGElements(true);
		for(RNGElementElement element : elements) {
			String name = element.getAncestorDefine().getRNGName();

			if(docxi.getSnippets(name, Destination.any).size() < 1) {
				missingElementSnippets.add(name);
			}
			if(docxi.getLongdescs(name, Destination.any, QNameProvider.OutputGrammar.XHTML).size() < 1) {
				missingElementLongdescs.add(name);
			}
		}

		List<RNGAttributeElement> attributes = rng.getRNGAttributes(true);
		for(RNGAttributeElement attribute : attributes) {
			
			String name = attribute.getAncestorDefine().getRNGName();

			if(docxi.getSnippets(name, Destination.any).size() < 1) {
				missingAttributeSnippets.add(name);
			}
			if(docxi.getLongdescs(name, Destination.any, QNameProvider.OutputGrammar.XHTML).size() < 1) {
				missingAttributeLongdescs.add(name);
			}
		}
		
		stdout("\nMissing snippets for " , missingElementSnippets.size() , " elements:\n "); printList(missingElementSnippets);		
		stdout("\nMissing longdescs for " , missingElementLongdescs.size() , " elements:\n "); printList(missingElementLongdescs);
		stdout("\nMissing snippets for " , missingAttributeSnippets.size() , " attributes:\n "); printList(missingAttributeSnippets);		
		stdout("\nMissing longdescs for " , missingAttributeLongdescs.size() , " attributes:\n "); printList(missingAttributeLongdescs);
	}

	private void printList(List<String> list) {
		Collections.sort(list);
		
		StringBuilder sb = new StringBuilder();
		int i = 0;
		for(String s : list) {
			i++;			
			if(Integer.toString(i).endsWith("0")) {
				sb.append(s).append("\n");
			}else {
				sb.append(s).append(", ");
			}	
		}
		stdout(sb.toString());
	}

	public static void main(String[] args) throws Exception {
		new ExternalDocDiagnostics(args);
		System.out.println("\nExternalDocDiagnostics done.");
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
