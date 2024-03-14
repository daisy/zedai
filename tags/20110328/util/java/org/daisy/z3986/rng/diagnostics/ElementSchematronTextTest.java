package org.daisy.z3986.rng.diagnostics;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.z3986.Constants;
import org.daisy.z3986.rng.RNGQuasiSimplifier;
import org.daisy.z3986.xom.XOMUtil;


/**
 * List elements that allows text in their content models and that
 * does not seem to have the not-empty schematron test
 */
public class ElementSchematronTextTest extends AbstractDiagnostics {
		
	/**
	 * 
	 * @param projectPath project root dir
	 * @param driverPath driver to use for testing
	 * @throws Exception
	 */
	public ElementSchematronTextTest(final String projectPath, final String driverPath) throws Exception {
		super(projectPath);		
		File out = new File(tempDir,"elementSchematronTest.rng");		
		new RNGQuasiSimplifier(new String[]{driverPath,out.getAbsolutePath()});	
		doTest(out);		
		out.delete();
	}

	private void doTest(File out) throws Exception {
		Document rng = XOMUtil.build(out);
		Nodes elementsWithText = rng.getRootElement().query("//rng:element[descendant::rng:text]", Constants.namespaces);
		List<String> missingSch = new ArrayList<String>();
		for (int i = 0; i < elementsWithText.size(); i++) {
			Element element = (Element)elementsWithText.get(i);
			Nodes sch = element.query(".//sch:*[contains(@test,'count(*) > 0 or string-length(normalize-space(.)) > 0')]",Constants.namespaces);
			if(sch.size()<1) {
				missingSch.add("  {" +element.getAttributeValue(Constants.NS) + "}" + element.getAttributeValue(Constants.NAME));
			}
		}
				
		System.err.println("The following elements were found to allow text and miss the non-empty schematron test.");
		System.err.println("Note that in some cases the abscence of the test is intentional.");
		Collections.sort(missingSch);
		for(String s : missingSch) {				
			System.err.println(s);
		}
		
	}

	/**
	 * @param args 0: project path 1: path to driver to use for testing
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		new ElementSchematronTextTest(args[0], args[1]);
	}


}
