package org.daisy.z3986.xsd;

import java.io.File;
import java.io.IOException;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.daisy.util.file.FileUtils;
import org.daisy.util.xml.SimpleNamespaceContext;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSParser;
import org.w3c.dom.ls.LSSerializer;

public class XSDFixer {

	/**
	 * Cleanup of XSDs output from Trang.
	 * <p>
	 * Arguments:
	 * </p>
	 * <ol>
	 * <li>0: path to input file</li>
	 * <li>1: path to output file (may be same as input path (using DOM))</li>
	 * </ol>
	 */
	public static void main(String[] args) {
		File input = new File(args[0]);
		File output = new File(args[1]);

		try {

			DOMImplementationRegistry registry = DOMImplementationRegistry
					.newInstance();
			DOMImplementationLS impl = (DOMImplementationLS) registry
					.getDOMImplementation("LS");

			Document xsd = build(input.toURI().toString(), impl);

			xsd = normalizeRDFaAttributes(xsd);

			write(xsd, output.toURI().toString(), impl);

		} catch (Exception e) {
			e.printStackTrace();
			try {
				FileUtils.copy(input, output);
			} catch (IOException e1) {
				e1.printStackTrace();
			}
		}

	}

	private static Document normalizeRDFaAttributes(Document xsd) {
		/*
		 * Trang expands out all attlists. Change the RDFa collection to refer
		 * to one single attributeGroup
		 */
		try {
			XPathFactory xpf = XPathFactory.newInstance();
			XPath xpath = xpf.newXPath();						
			SimpleNamespaceContext cnt = new SimpleNamespaceContext();
			cnt.declareNamespace("xs", XSD_NS);
			xpath.setNamespaceContext(cnt);
			//select all parents that declare the following optional attrs:
			//about, content, datatype, typeof, property, rel, resource, rev
			String exp = 	
			    "//xs:*[xs:attribute[@name='about' and not(@use='required')] " +
					"and xs:attribute[@name='content' and not(@use='required')] " +
					"and xs:attribute[@name='datatype' and not(@use='required')] " +
					"and xs:attribute[@name='typeof' and not(@use='required')] " +
					"and xs:attribute[@name='property' and not(@use='required')] " +
					"and xs:attribute[@name='rel' and not(@use='required')] "+ 
					"and xs:attribute[@name='resource' and not(@use='required')] " +
					"and xs:attribute[@name='rev' and not(@use='required')]]";
			NodeList elems = (NodeList) xpath.evaluate(exp, xsd, XPathConstants.NODESET);			
			System.out.println("RDFa collections to prune: " + elems.getLength());
			if(elems.getLength()>0) {
				final String rdfaAttrGroupName ="rdfaAttribs";
				
				//create one single attributeGroup that all the others can ref
				//Element attrGroup = xsd.createElementNS(XSD_NS, "attributeGroup");
				Element attrGroup = xsd.createElement("xs:attributeGroup"); //TODO assuming prefix
				Attr name = xsd.createAttribute("name"); name.setTextContent(rdfaAttrGroupName);
				attrGroup.getAttributes().setNamedItem(name);				
				Element source = (Element) elems.item(0);
				String exp2 = 	
				    "xs:attribute[@name='about' or @name='content' or @name='datatype' or @name='typeof' " +
				    "or @name='property' or @name='rel' or @name='resource' or @name='rev']"; 
				NodeList toCopy = (NodeList) xpath.evaluate(exp2, source, XPathConstants.NODESET);				
				for (int i = 0; i < toCopy.getLength(); i++) {
					Element e = (Element)toCopy.item(i);
					attrGroup.appendChild(e.cloneNode(true));
				}				
				xsd.getDocumentElement().appendChild(attrGroup);
								
				//iterate over nodelist and replace with ref to attr group				
				for (int i = 0; i < elems.getLength(); i++) {
					Element elem = (Element) elems.item(i);
					NodeList toDelete = (NodeList) xpath.evaluate(exp2, elem, XPathConstants.NODESET);
					for (int k = 0; k < toDelete.getLength(); k++) {
						Node del = toDelete.item(k);
						del.getParentNode().removeChild(del);
					}
					//Element attrGroupRef = xsd.createElementNS(XSD_NS, "attributeGroup");
					Element attrGroupRef = xsd.createElement("xs:attributeGroup");
					Attr ref = xsd.createAttribute("ref"); 
					ref.setTextContent("z3986:" + rdfaAttrGroupName); //TODO assuming prefix
					attrGroupRef.getAttributes().setNamedItem(ref);
					elem.appendChild(attrGroupRef);					
				}
			} //if(elems.getLength()>0)
			
		} catch (XPathExpressionException e) {
			e.printStackTrace();
		}
		return xsd;
	}

	private static void write(Document doc, String uri, DOMImplementationLS impl)
			throws Exception {
		LSSerializer writer = impl.createLSSerializer();
		writer.getDomConfig().setParameter("format-pretty-print", Boolean.TRUE);
		boolean result = writer.writeToURI(doc, uri);
		if (!result)
			throw new IOException("XSDFixer#write");
		System.out.println("XSDFixer succesfully serialized " + uri);

	}

	private static Document build(String uri, DOMImplementationLS impl)
			throws Exception {
		LSParser builder = impl.createLSParser(
				DOMImplementationLS.MODE_SYNCHRONOUS, null);
		builder.getDomConfig().setParameter("namespaces", Boolean.TRUE);
		builder.getDomConfig().setParameter("validate", Boolean.FALSE);
		builder.getDomConfig()
				.setParameter("validate-if-schema", Boolean.FALSE);
		return builder.parseURI(uri);
	}

	private static final String XSD_NS = "http://www.w3.org/2001/XMLSchema";

}
