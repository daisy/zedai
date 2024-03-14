package org.daisy.z3998.rng.model;

import javax.xml.parsers.SAXParserFactory;

import nu.xom.Builder;

import org.daisy.util.file.FilenameOrFileURI;

import com.ctc.wstx.sax.WstxSAXParserFactory;

public class RNGBuilder {
	private static Builder builder;
	
	public static RNGDocument build(String systemID) throws Exception {
		if(builder==null) {
			SAXParserFactory spf = new WstxSAXParserFactory();
			spf.setNamespaceAware(true);
			builder = new Builder(spf.newSAXParser().getXMLReader(),false, new RNGNodeFactory());
		}
		return (RNGDocument)builder.build(FilenameOrFileURI.toURI(systemID).toString());
	}
	
}
