package org.daisy.z3986.rng;

import java.io.File;
import java.io.IOException;
import java.util.Collection;

import nu.xom.Document;

import org.daisy.util.file.Directory;
import org.daisy.z3986.xom.XOMUtil;

public class PrettyPrinter {

	/**
	 * Pretty print in place a set of RNG files using XOM.
	 * @param args 0: path to mother directory
	 * @throws IOException 
	 */
	public PrettyPrinter(String[] args) throws Exception {
		Directory directory = new Directory(args[0]);
		Collection<File> files = directory.getFiles(true, ".+\\.rng$");
		for(File f : files) {
			Document doc = XOMUtil.build(f);
			prettyPrint(doc);
			XOMUtil.serialize(doc, f);
		}
	}

	private void prettyPrint(Document doc) throws Exception {
		/* seems nothing special is really needed here */
		/* could remove unused root ns decls as added by the xslt */
		
	}

	public static void main(String[] args) throws Exception {
		new PrettyPrinter(args);
	}
	
}
