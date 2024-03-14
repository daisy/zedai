package org.daisy.z3998.docbook;

import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;
import nu.xom.xinclude.XIncluder;

import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3998.Constants;
import org.daisy.z3998.xom.XOMUtil;

public class BibliographyChecker {

	/**
	 * Check that all entries in a bibliography are actually referenced.
	 * @param args 0: path to a docbook document.
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		/* note that CM and RDs also reference entries */
		Document doc = XOMUtil.build(FilenameOrFileURI.toURI(args[0]).toString());
		XIncluder.resolveInPlace(doc);	
		Nodes links = doc.getRootElement().query("//*[@linkend]", Constants.namespaces);
		Nodes biblioentries = doc.getRootElement().query("//db:bibliography//db:biblioentry", Constants.namespaces);
		for (int i = 0; i < biblioentries.size(); i++) {
			Element entry = (Element)biblioentries.get(i);
			String id = entry.getAttributeValue(Constants.ID,Constants.XML_NS);
			boolean used = false;
			for (int k = 0; k < links.size(); k++) {
				Element link = (Element)links.get(k);
				String linkend = link.getAttributeValue(Constants.LINKEND);
				if(linkend.equals(id)) {
					used = true;
					break;
				}
			}
			if(!used) System.err.println("biblioentry "+ id + " not used.");
		}
	}

}
