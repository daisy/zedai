package org.daisy.z3986.xom;

import nu.xom.Document;
import nu.xom.xinclude.XIncluder;

import org.daisy.util.file.FilenameOrFileURI;

public class XOMXIncluder {

	/**
	 * Perform an XInclude pass using XOM.
	 * Arguments:
	 * <ol start="0">
	 * <li>input path</li>
	 * <li>output path</li>
	 * </ol>
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		Document doc = XOMUtil.build(FilenameOrFileURI.toFile(args[0]));
		XIncluder.resolveInPlace(doc);
		XOMUtil.serialize(doc, FilenameOrFileURI.toFile(args[1]));		
	}

}
