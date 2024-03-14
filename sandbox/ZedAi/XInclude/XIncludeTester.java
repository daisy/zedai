package org.rfbd.jpritchett;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

/**
 * Demonstration of applying an XSLT transform to an XML document that uses XInclude
 * @author jpritchett
 * @version 2009-01-09
 */
public class XIncludeTester {

	/**
	 * @param args Arguments are:  infile xslt outfile
	 */
	public static void main(String[] args) throws FileNotFoundException, ParserConfigurationException, SAXException, TransformerConfigurationException, TransformerException {
		System.out.println("XIncludeTester 2009-01-09");

		// Get the arguments
		if (args.length != 3) {
			System.err.println("Usage:  XIncludeTester <infile> <xslt> <outfile>");
			return;
		}
		String inFile = args[0];
		String xsltFile = args[1];
		String outFile = args[2];
		System.out.println("Transforming " + inFile + " with " + xsltFile + " resulting in " + outFile);

		// Set up all the SAX stuff
		SAXParserFactory parserFactory = SAXParserFactory.newInstance();
		parserFactory.setNamespaceAware(true);

		// Turn on XInclude for all parsers created by this factory
		parserFactory.setXIncludeAware(true);

		// Here we turn off the xml:base fixup so that the output files will schema validate
		parserFactory.setFeature("http://apache.org/xml/features/xinclude/fixup-base-uris", false);

		SAXParser parser = parserFactory.newSAXParser();
		XMLReader reader = parser.getXMLReader();

		Source xmlSource = new SAXSource(reader, new InputSource(new FileInputStream(inFile)));
		Source xsltSource = new SAXSource(reader, new InputSource(new FileInputStream(xsltFile)));
		Result outResult = new StreamResult(outFile);

		// Set up all the XSLT stuff
 		TransformerFactory transformerFactory = TransformerFactory.newInstance();
        javax.xml.transform.Transformer transformer = transformerFactory.newTransformer(xsltSource);

		// Do the transform!
		transformer.transform(xmlSource, outResult);

		System.out.println("Done.");
		return;
	}
}
