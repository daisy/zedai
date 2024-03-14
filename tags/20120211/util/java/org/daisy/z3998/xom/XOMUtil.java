package org.daisy.z3998.xom;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.SAXParserFactory;

import nu.xom.Attribute;
import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.Node;
import nu.xom.Nodes;
import nu.xom.ParentNode;
import nu.xom.Serializer;
import nu.xom.Text;

import org.daisy.z3998.Constants;
import org.daisy.z3998.QNameProvider;
import org.daisy.z3998.QNameProvider.Type;

import com.ctc.wstx.sax.WstxSAXParserFactory;

public class XOMUtil {
	private static Builder builder;
	
	public static Document build(String systemID) throws Exception {
		if(builder==null) {
			SAXParserFactory spf = new WstxSAXParserFactory();
			spf.setNamespaceAware(true);
			builder = new Builder(spf.newSAXParser().getXMLReader());
		}
		return builder.build(systemID);
	}
	
	public static Document build(File file) throws Exception {		
		return build(file.toURI().toString());
	}
	
	public static void serialize(Document grammar, File output) throws Exception {
		  output.getParentFile().mkdirs();
		  FileOutputStream fos = new FileOutputStream(output);
		  Serializer serializer = new Serializer(fos, "utf-8");		  
	      serializer.setIndent(4);
	      serializer.setMaxLength(0);
	      serializer.write(grammar);  
	      fos.close();
	}
	
	/**
	 * Replace old by the children of add. 
	 */
	public void replaceByChildren(Element old, Element add) throws Exception {
		ParentNode parent = old.getParent();
		int pos = parent.indexOf(old);
		Elements toInsert = add.getChildElements();
		for (int j = 0; j < toInsert.size(); j++) {
			Element child = toInsert.get(j);
			child.detach();
			parent.insertChild(child, ++pos);
		}
		parent.removeChild(old);						
	}
	
	private static void replace(Node replaced, List<Node> replacements) {
		ParentNode parent = replaced.getParent();
		int pos = parent.indexOf(replaced);
		parent.removeChild(replaced);
		if(pos==0) pos = -1;
		for (Node node : replacements) {			
			node.detach();		
			parent.insertChild(node, ++pos);			
		}	
	}
		
	/**
	 * Parse the children of given Element, turning any found wiki tokens into 
	 * elements. The returned element is a (detached) copy of the given element, 
	 * so the client needs to insert.
	 * @throws Exception 
	 */
	public static Element parseWikiSyntax(Element parent, QNameProvider qnameProvider) throws Exception {
		
		Element ret = (Element)parent.copy();
		
		Map<Node, List<Node>> replaced = new LinkedHashMap<Node, List<Node>>();
		
		for (int i = 0; i < ret.getChildCount(); i++) {
			Node n = ret.getChild(i);
			if(n instanceof Text) {
				Text text = (Text)n;
				String value = text.getValue();
				if(value.contains("[[") || value.contains("{")) {
					List<Node> textReplacement = parseWikiSyntax(value, qnameProvider);
					replaced.put(n, textReplacement);
				}
			}
			else if (n instanceof Element) {				
				Element parsed = parseWikiSyntax((Element)n, qnameProvider);
				n.getParent().replaceChild(n, parsed);
			}
		}
				
		for(Node toReplace : replaced.keySet()) {	
			List<Node> replacements = replaced.get(toReplace);
			replace(toReplace,replacements);					
		}				
		return ret;				
	}
	
	public static List<Node> parseWikiSyntax(String string, QNameProvider qnames) throws Exception {		
					
		List<Node> ret = new ArrayList<Node>();	
		
		if(!string.contains("[[") && !string.contains("{")) {
			ret.add(new Text(string));
			return ret;
		}
		
		String currentNS = qnames.getCurrentDefaultNamespace(); 	
		String currentPFX = Constants.nsMap.get(currentNS);
		
		if(code==null || qnames.getCurrentOutputGrammar() != lastSeenGrammar){
			lastSeenGrammar = qnames.getCurrentOutputGrammar();			
			code = qnames.getElement(Type.ELEMENT_CODE);
			codeStartTag = "<" + code.getLocalName() +">";
			codeEndTag = "</" + code.getLocalName() +">";
			link = qnames.getElement(Type.ELEMENT_LINK);
			linkStartTag = "<" + link.getLocalName() +">";
			linkEndTag = "</"  + link.getLocalName() +">";
			idrefAttr = qnames.getAttribute(Type.ATTRIBUTE_LINK_IDREF);	//will be null when xhtml				
			hrefAttr = qnames.getAttribute(Type.ATTRIBUTE_LINK_URI);						
		}
				
		StringBuilder sbl = new StringBuilder();
		sbl.append("<text xmlns='").append(currentNS);
		sbl.append("' xmlns:xlink='").append(Constants.XLINK_NS).append("'>");
		char prev = ' '; 
		for (int i = 0; i < string.length(); i++) {
			char ch = string.charAt(i);
			if(ch == '{'){
				sbl.append(codeStartTag);
			}else if(ch == '}'){
				sbl.append(codeEndTag);
			}else if(ch == '[') {
				if(prev == '[') {
					sbl.append(linkStartTag);
				}	
			}else if(ch == ']') {
				if(prev == ']') {
					sbl.append(linkEndTag);
				}	
			}else{
				sbl.append(ch);
			}
			prev = ch;
		}
		sbl.append("</text>");
		String build = sbl.toString();
		
		Document doc;
		try{		
			doc = builder.build(build, qnames.getCurrentHost().getBaseURI());
		}catch (Exception e) {
			System.err.println("error when loading string: " + build);
			throw e;
		}
		
		StringBuilder xpath = new StringBuilder();
		xpath.append("//");
		xpath.append(currentPFX); 
		xpath.append(":");
		xpath.append(link.getLocalName());
		
		Nodes links = doc.getRootElement().query(xpath.toString() , Constants.namespaces);
		for (int i = 0; i < links.size(); i++) {
			Element link = (Element)links.get(i);
			
			String value = prepWikiLinkString(link.getValue());
			String linkValue = value;
			String labelValue = null;
						
			int point = value.indexOf(' ');
			if (point > 0) { 
				linkValue = value.substring(0, point);
				labelValue = value.substring(point+1);
			}	
									
			link.getParent().replaceChild(
					link, qnames.getLink(
							linkValue, labelValue));
									
		}
					
		for (int i = 0; i < doc.getRootElement().getChildCount(); i++) {
			Node child = doc.getRootElement().getChild(i);
			ret.add(child);			
		}
		return ret;
	}
	
	public static String prepWikiLinkString(String value) {
		value = value.replace('\r',' ');
		value = value.replace('\n',' ');
		while(value.contains("  ")) {
			value = value.replace("  ", " ");
		}	
		return value.trim();
	}

	/**
	 * Append the child nodes of source to destination, copying them from the source. 
	 */
	public static void appendChildren(Element destination, Element source) {
		for (int i = 0; i < source.getChildCount(); i++) {
			Node node = source.getChild(i);	
			destination.appendChild(node.copy());
		}				
	}
	
	/**
	 * Append the children nodes to parent, copying them from the source. 
	 */
	public static void appendChildren(Element parent, List<Node> children) {
		for(Node node : children) {
			parent.appendChild(node.copy());
		}		
	}
		
	/**
	 * Retrieve the nearest ancestor element that has the given attribute,
	 * or null if no such ancestor exists.
	 */
	public static Element getAncestorWithAttribute(Element element, String attrName) {
		ParentNode parent = element.getParent();
		if(parent!=null && parent instanceof Element) {			
			Element eparent = (Element)parent;
			if(eparent.getAttribute(attrName)!=null){
				return eparent;
			}
			return getAncestorWithAttribute(eparent, attrName);
		}	
		return null;
	}

	/**
	 * Retrieve the nearest ancestor element that has the given name,
	 * or null if no such ancestor exists.
	 */
	public static Element getAncestor(Element element, String localName, String namespaceURI) {
		ParentNode parent = element.getParent();
		if(parent!=null && parent instanceof Element) {			
			Element eparent = (Element)parent;
			if(eparent.getLocalName().equals(localName)
					&& eparent.getNamespaceURI().equals(namespaceURI)){
				return eparent;
			}
			return getAncestor(eparent, localName, namespaceURI);
		}	
		return null;
	}
	
	public static String stripWikiSyntax(String value) {
		StringBuilder sb = new StringBuilder();
		char[] chars = value.toCharArray();
		for (int i = 0; i < chars.length; i++) {
			char c = chars[i];
			if(c != '[' && c != ']' && c != '{' && c != '}') {
				sb.append(c);
			}
		}
		return sb.toString();
	}

	private static Element code;
	private static String codeStartTag;
	private static String codeEndTag;
	private static Element link;
	private static String linkStartTag;
	private static String linkEndTag;
	private static Attribute idrefAttr;		
	private static Attribute hrefAttr;
	
	private static QNameProvider.OutputGrammar lastSeenGrammar;
}
