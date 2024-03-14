package org.daisy.z3986.rng;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import nu.xom.Attribute;
import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;
import nu.xom.xslt.XSLTransform;

import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3986.Constants;
import org.daisy.z3986.xom.XOMUtil;

public class RNGVocabEnumGenerator {
	private XSLTransform transform;
	
	/**
	 * Generate RNG enums from RDF XML.
	 * <p>Arguments:</p>
	 * <ol start="0">
	 * <li>path to input RDF XML doc</li>
	 * <li>path to output RNG schema</li>
	 * </ol>
	 * @throws Exception 
	 */
	public RNGVocabEnumGenerator(String[] args) throws Exception {
		
		Document input = XOMUtil.build(FilenameOrFileURI.toURI(args[0]).toString());	
		
		Document result = new Document(new Element(Constants.GRAMMAR, Constants.RNG_NS));
		result.getRootElement().addNamespaceDeclaration(Constants.RNGA_PFX, Constants.RNGA_NS);
		
		Element defineTemplate = new Element(Constants.DEFINE, Constants.RNG_NS);
		defineTemplate.addAttribute(new Attribute(Constants.NAME, ""));
		defineTemplate.addAttribute(new Attribute(Constants.COMBINE, Constants.CHOICE));
		defineTemplate.appendChild(new Element(Constants.CHOICE, Constants.RNG_NS));
		
		Element valueTemplate = new Element(Constants.VALUE, Constants.RNG_NS);
		Element docTemplate = new Element(Constants.DOCUMENTATION, Constants.RNGA_NS);
		
		/*
		 * Get all rdf:Description with a zt:for property; where rdf:type = property or bag, 
		 * and where zt:for contains one or several IDs of target elements
		 * <rdf:Description rdf:about="http://www.daisy.org/z3986/2012/vocab/structure/#topic-sentence">
    	 *   <rdfs:comment>...</rdfs:comment>
    	 *   <rdf:member rdf:resource="..."/>
    	 *   <rdfs:label>...</rdfs:label>
    	 *   <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
    	 *   <zt:for>z3986.foo z3986.bar</zt:for>
  		 * </rdf:Description>
		 */
		Nodes subjects = input.getRootElement().query("//rdf:Description[zt:for]", Constants.namespaces);
		
		if(subjects.size()==0) return;
		
		Map<String,List<Element>> targetMap = buildTargetMap(subjects);
		
		for(String target : targetMap.keySet()) {
			String defineName = target + ".role.attrib.content.enum";
			Element define = (Element)defineTemplate.copy();
			Element choice = define.getFirstChildElement(Constants.CHOICE, Constants.RNG_NS);
			
			define.getAttribute(Constants.NAME).setValue(defineName);
									
			for(Element rdfDesc : targetMap.get(target)) {
				String label = rdfDesc.getFirstChildElement("label", Constants.RDFS_NS).getValue();								
				Element value = (Element)valueTemplate.copy();
				value.appendChild(label);
				choice.appendChild(value);
				
				String comment = rdfDesc.getFirstChildElement("comment", Constants.RDFS_NS).getValue();
				if(comment!=null) {
					Element doc = (Element)docTemplate.copy();
					doc.appendChild(comment);
					choice.appendChild(doc);
				}
			}
			result.getRootElement().appendChild(define);
			
		}
		
		XOMUtil.serialize(new Document(cleanNamespaces(result)),FilenameOrFileURI.toFile(args[1]));
		System.out.println(this.getClass().getSimpleName() + " done.");
	}

	private Element cleanNamespaces(Document result) throws Exception {		
	    if(transform == null) {
	    	buildTransform();
	    }
	    return (Element) transform.transform(result).get(0);		 
	}
		
	private void buildTransform() throws Exception {
		System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
		Builder builder = new Builder();
	    Document stylesheet = builder.build(namespaceCleanerXSL,"about:blank");
	    transform = new XSLTransform(stylesheet);
	}
	
	/**
	 * Build a map where key = destination element ID and value is the
	 * list of RDF description elements to get the enum values from
	 */
	private Map<String, List<Element>> buildTargetMap(Nodes subjects) throws Exception {
		Map<String,List<Element>> targetMap = new HashMap<String,List<Element>>();
		for (int i = 0; i < subjects.size(); i++) {
			Element rdfDesc = (Element)subjects.get(i);
			RDFType type = getRDFType(rdfDesc);
			
			Element ztfor = rdfDesc.getFirstChildElement("for", Constants.ZEDAI_TURTLE_NS);
			String[] targets = ztfor.getValue().split(" ");
			for (int j = 0; j < targets.length; j++) {
				String target = targets[j];
				if(!targetMap.containsKey(target)) {
					targetMap.put(target, new ArrayList<Element>());
				}
				if(type == RDFType.PROPERTY) {
					//plain single prop to add
//					System.err.println(target + " ==> " + rdfDesc.getFirstChildElement("label", Constants.RDFS_NS).getValue());
					targetMap.get(target).add(rdfDesc);
				}else {
					//a bag, add all its members
					String bagID = rdfDesc.getAttributeValue("about", Constants.RDF_NS);
					String xpath = "//rdf:Description[rdf:member/@rdf:resource = '" + bagID + "']";
					Nodes members = rdfDesc.getDocument().getRootElement().query(xpath, Constants.namespaces);
					//members now also contain sub-bags
					for (int k = 0; k < members.size(); k++) {
						Element member = (Element) members.get(k);						
						RDFType memberType = getRDFType(member);
						if(memberType == RDFType.PROPERTY) { //skip sub-bags
							targetMap.get(target).add(member);	
//							System.err.println(target + " ==> " + member.getFirstChildElement("label", Constants.RDFS_NS).getValue());
						}	
					}
				}
			}
		}
		return targetMap;
	}

	private RDFType getRDFType(Element rdfDesc) throws Exception {
		//<rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
		//<rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag"/>
		String resource = rdfDesc.getFirstChildElement("type", Constants.RDF_NS)
			.getAttributeValue(Constants.RESOURCE, Constants.RDF_NS);
		if(resource.equals(Constants.RDF_BAG_URI)) {
			return RDFType.BAG;
		}
		if(resource.equals(Constants.RDF_PROPERTY_URI)) {
			return RDFType.PROPERTY;
		}
		throw new IllegalStateException("not a property or bag type");
	}

	private enum RDFType {
		PROPERTY,
		BAG;
	}
	
	public static void main(String[] args) throws Exception {
		new RNGVocabEnumGenerator(args);
	}

	String namespaceCleanerXSL = 
		"<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' " +
		"xmlns:a='http://relaxng.org/ns/compatibility/annotations/1.0' version='2.0'>" +
		"<xsl:output method='xml' encoding='utf-8' omit-xml-declaration='yes' />" +
		"<xsl:template match='@*|node()'>" +
		"<xsl:copy>" +
		"	<xsl:apply-templates select='@*|node()'/> " +
		"</xsl:copy>" +
		"</xsl:template>"+
		"<xsl:template match='a:documentation'>" +
		" <a:documentation>" +
		"   <xsl:apply-templates />" +
		" </a:documentation>" +
		"</xsl:template>"+
		"</xsl:stylesheet>";
}
