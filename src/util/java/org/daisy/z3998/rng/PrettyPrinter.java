package org.daisy.z3998.rng;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.util.file.Directory;
import org.daisy.z3998.Constants;
import org.daisy.z3998.xom.XOMUtil;

public class PrettyPrinter {

	/**
	 * Pretty print in place a set of RNG files using XOM.
	 * @param args 0: path to mother directory
	 * @param args 1: whether to remove unused namespace declarations from root element (true|false, omitted == false)
	 * @throws IOException 
	 */
	public PrettyPrinter(String[] args) throws Exception {
		Directory directory = new Directory(args[0]);
		Collection<File> files = directory.getFiles(true, ".+\\.rng$");
		for(File f : files) {

			Document doc = XOMUtil.build(f);
			
			if(args.length>1 && Boolean.parseBoolean(args[1])) {
				pruneNsDecls(doc.getRootElement());	
			}
			
			XOMUtil.serialize(doc, f);
		}
	}

	private void pruneNsDecls(Element root) throws Exception {
		
		Set<String> prefixesToPrune = new HashSet<String>();		
		for (int i = 0; i < root.getNamespaceDeclarationCount(); i++) {
			String prefix = root.getNamespacePrefix(i);
			if(prefix!=null && prefix.length()>0) {
				String uri = root.getNamespaceURI(prefix);		
				if(!used(uri,prefix, root)) {
					prefixesToPrune.add(prefix);				
				}
			}
		}		
		
		for(String prefix : prefixesToPrune) {
			root.removeNamespaceDeclaration(prefix);
		}
		
		//add this during rdf to docbook port, may be removed once done
		Nodes xlinks = root.query("//*[@*[namespace-uri()='"+Constants.XLINK_NS+"']]"); 
		if(xlinks.size()>0) {
			root.addNamespaceDeclaration(Constants.XLINK_PFX, Constants.XLINK_NS);
		}
				
	}

	private boolean used(String nsuri, String prefix, Element root) {
		Nodes match = root.query("//*[namespace-uri()='"+nsuri+"']|//*[@*[namespace-uri()='"+nsuri+"']]");
		Nodes matchRngNames = root.query("//*[contains(@name,'"+prefix+"')]");
		return match.size()>0 || matchRngNames.size()>0;
	}

	public static void main(String[] args) throws Exception {
		new PrettyPrinter(args);
	}
	
}
