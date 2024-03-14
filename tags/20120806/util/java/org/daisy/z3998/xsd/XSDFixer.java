package org.daisy.z3998.xsd;

import java.io.File;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3998.Constants;
import org.daisy.z3998.xom.XOMUtil;


public class XSDFixer {

	private static final String rdfaAttrGroupName ="rdfaAttribs";
	private static final String xsdAttrGroupName ="attributeGroup";
	
	/**
	 * Cleanup of XSDs output from Trang.
	 * <p>
	 * Arguments:
	 * </p>
	 * <ol>
	 * <li>0: path to input file</li>
	 * <li>1: path to output file (may be same as input path (using DOM))</li>
	 * </ol>
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		
		File output = FilenameOrFileURI.toFile(args[1]);
		Document xsd = XOMUtil.build(FilenameOrFileURI.toFile(args[0]));
		
		xsd = normalizeRDFaAttributes(xsd);
		
		XOMUtil.serialize(xsd, output);
		
	}

	private static Document normalizeRDFaAttributes(Document xsd) {
		/*
		 * Trang expands out all attlists. Change the RDFa collection to refer
		 * to one single attributeGroup
		 */
		String exp = 	
		    "//xs:*[xs:attribute[@name='about' and not(@use='required')] " +
				"and xs:attribute[@name='content' and not(@use='required')] " +
				"and xs:attribute[@name='datatype' and not(@use='required')] " +
				"and xs:attribute[@name='typeof' and not(@use='required')] " +
				"and xs:attribute[@name='property' and not(@use='required')] " +
				"and xs:attribute[@name='rel' and not(@use='required')] "+ 
				"and xs:attribute[@name='resource' and not(@use='required')] " +
				"and xs:attribute[@name='rev' and not(@use='required')]]";
		
		Nodes elements = xsd.getRootElement().query(exp, Constants.namespaces); 
		
		System.out.println("XSDFixer: RDFa collections to prune: " + elements.size());
		
		if(elements.size()>0) {
		
			//create one single attributeGroup for all others to ref
			Element attributeGroup = new Element(xsdAttrGroupName, Constants.XSD_NS);
			attributeGroup.addAttribute(new Attribute(Constants.NAME, rdfaAttrGroupName));
			Element source = (Element) elements.get(0);
			String exp2 = 	
			    "xs:attribute[@name='about' or @name='content' or @name='datatype' or @name='typeof' " +
			    "or @name='property' or @name='rel' or @name='resource' or @name='rev']";			
			Nodes toCopy = source.query(exp2,Constants.namespaces);				
			for (int i = 0; i < toCopy.size(); i++) {
				Element e = (Element)toCopy.get(i);
				attributeGroup.appendChild(e.copy());
			}				
			//System.out.println("appending:: " + attributeGroup.toXML());
			xsd.getRootElement().appendChild(attributeGroup);
			
			//replace to ref the new group
			String prefix = getCoreNSPrefix(xsd);
			for (int i = 0; i < elements.size(); i++) {
				Element elem = (Element) elements.get(i);
				
				Nodes toDelete = elem.query(exp2, Constants.namespaces);
				for (int k = 0; k < toDelete.size(); k++) {
					Element del = (Element) toDelete.get(k);
					del.getParent().removeChild(del);
				}
				
				Element attributeGroupRef = new Element(xsdAttrGroupName, Constants.XSD_NS);
				attributeGroupRef.addAttribute(new Attribute(Constants.REF, prefix + rdfaAttrGroupName));
				
				elem.appendChild(attributeGroupRef);					
			}
		} //if(elements.size()>0)
		return xsd;
	}

	private static String getCoreNSPrefix(Document xsd) {
		Element root = xsd.getRootElement();
		String targetNS = root.getAttributeValue("targetNamespace");
		for (int i = 0; i < root.getNamespaceDeclarationCount(); i++) {
			String prefix = root.getNamespacePrefix(i);
			String uri = root.getNamespaceURI(prefix);
			if(uri.equals(targetNS)) {
				return prefix + ":";
			}
		}
		throw new NullPointerException();
	}

}
