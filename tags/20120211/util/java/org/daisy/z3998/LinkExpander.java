package org.daisy.z3998;

import java.util.HashMap;
import java.util.Map;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.Nodes;

import org.daisy.util.xml.Namespaces;

/**
 * This class
 * <ul>
 * <li>Finds labels for label-less links (stemming from wiki markup in module
 * doc)</li>
 * <li>Redirects nonresolving fragment URIs to sibling docs in the spec suite
 * (stemming from the short form links used in module doc)</li>
 * </ul>
 * Contexts when this is potentially called:
 * <ul>
 * <li>on the docbook CMP specdoc during absdef expansion (input is DocBook)</li>
 * <li>on the xhtml resource directories during absdef expansion (input is
 * XHTML)</li>
 * <li>when running the SchemaDocPreProcessor (input is RNG with inline XHTML
 * doc)</li> </li>
 */
public class LinkExpander {

	private final Document input;
	private final InputType inputType;
	private final Document spec;
	private final Document cmp;
	private final QNameProvider qnames;

	private Map<String, Element> inputIDMap;
	private Map<String, Element> specIDMap;
	private Map<String, Element> cmpIDMap;

	/**
	 * Constructor
	 * 
	 * @param input
	 *            the Document to modify in place
	 * @param qnames
	 *            the QNameProvider used by the caller
	 * @param spec
	 *            the Docbook version of the spec
	 * @param cmp
	 *            the Docbook version of the core module pool document
	 * @throws Exception
	 */
	public LinkExpander(Document input, QNameProvider qnames, Document spec, Document cmp) throws Exception {
		
		if(input==null) throw new IllegalStateException("input is null");
		if(qnames==null) throw new IllegalStateException("qnames is null");
		if(spec==null) throw new IllegalStateException("spec is null");
		if(cmp==null) throw new IllegalStateException("cmp is null");
		
		
		
		this.input = input;
		this.qnames = qnames;
		this.spec = spec; 
		this.cmp = cmp;
		this.inputType = getInputType();
		
//		System.out.print(">>>>>>>>>>> Input is: " + input.getBaseURI().substring(input.getBaseURI().lastIndexOf('/')));
//		System.out.print(">>>>>>>>>>> Spec is: " + spec.getBaseURI().substring(input.getBaseURI().lastIndexOf('/')));
//		System.out.print(">>>>>>>>>>> CMP is: " + cmp.getBaseURI().substring(input.getBaseURI().lastIndexOf('/')));
//		System.out.print(">>>>>>>>>>> Input is: " + input.getBaseURI().substring(input.getBaseURI().lastIndexOf('/')));
//		System.out.print(">>>>>>>>>>> Spec is: " + spec.getBaseURI().substring(input.getBaseURI().lastIndexOf('/')));
//		System.out.print(">>>>>>>>>>> InputType is: " + inputType);
		
		buildIDMaps();
//		System.out.println(">>>>>>>>>>> handling broken fragment links");
		handleBrokenFragmentLinks();
//		System.out.println(">>>>>>>>>>> handling labelless links");
		handleLabellessLinks();
	}

	/**
	 * Iterate over the input tree, checking whether any XHTML or DOCBOOK links
	 * has a label, if not, try to create a label, if fail print a warning. Note
	 * that we dont check all types of links; only a subset (xhtml:a and
	 * docbook:link).
	 * 
	 * @throws Exception
	 * @throws Exception
	 */
	private void handleLabellessLinks() throws Exception {
		walk(input, new WalkerListener() {

			public void onElement(Element element) throws Exception {
				
				// if xhtml:a or docbook:link
				if (isLinkElement(element)) {
					String label = element.getValue();
					if (label == null || label.trim().length() < 1) {						
						label = findLabel(element);
						if (label != null && label.trim().length() > 0) {
							//printLabelAddedWarning(element, label);
							element.appendChild(label);
						} else {
							printNoLinkLabelFoundWarning(element);
						}
					}
				}
			}

			private String findLabel(Element element) {
				Attribute linkAttr = getLinkAttr(element);
				if(linkAttr!=null) {
					String uri = linkAttr.getValue().trim();
					//the label sought might be in input doc, 
					//in spec, or in cmp. Note that the input
					//doc might also be cmp, and note that we
					//ignore any docbook <xref> since those are 
					//handled by the docbook xslt.
					
					Element labelCarrier = null;
					InputType labelCarrierDocumentType = null;
					
					//first look locally
					if(uri.startsWith("#")) {
						labelCarrier = inputIDMap.get(uri.substring(1).trim());								
					}					
					//then check spec and cmp
					if(labelCarrier==null) {
						if(uri.startsWith(Constants.ZEDAI_WWW_SPEC_PATH)) {
							labelCarrier = specIDMap.get(uri.substring(uri.indexOf("#")+1));
							labelCarrierDocumentType = InputType.DOCBOOK;
						}else if(uri.startsWith(Constants.ZEDAI_WWW_CMP_PATH)) {
							labelCarrier = cmpIDMap.get(uri.substring(uri.indexOf("#")+1));
							labelCarrierDocumentType = InputType.DOCBOOK;
						}
					}
					
					if(labelCarrier!=null) {
						if(labelCarrierDocumentType == InputType.DOCBOOK) {
							return getLabelFromDocBook(labelCarrier);
						}else {
							return getLabel(labelCarrier);
						}
					}					
				}								
				return null;
			}
			
			private String getLabelFromDocBook(Element elem) {
				if(elem!=null) {			
					String ret = elem.getAttributeValue(Constants.XREFLABEL);
					if(ret!=null) return ret;
					
					if(elem.getLocalName().equals("biblioentry")) {
						return elem.getFirstChildElement("abbrev", Constants.DOCBOOK_NS).getValue();
					}
					
					Element child = elem.getFirstChildElement(Constants.TITLE, Constants.DOCBOOK_NS);
					if(child!=null) {
						return child.getValue();
					}
					
					child = elem.getFirstChildElement(Constants.CAPTION, Constants.DOCBOOK_NS);
					if(child!=null) {
						return child.getValue();
					}
				}
				return null;
			}

			private String getLabel(Element elem) {
				if(elem!=null) {			
					String ret = elem.getAttributeValue(Constants.XREFLABEL);
					if(ret!=null) return ret;
					
					Nodes nodes = elem.query(".//*[@xreflabel]", Constants.namespaces);
					if(nodes.size()>0) {
						return ((Element)nodes.get(0)).getAttributeValue(Constants.XREFLABEL); 
					}
					//TODO may need more here		
					
					Element caption = elem.getFirstChildElement(Constants.CAPTION, Namespaces.XHTML_10_NS_URI);
					if(caption!=null) {
						return caption.getValue();
					}
					
					Element print = (Element)elem.copy();
					print.removeChildren();
					System.err.println(">>>>>>> WARNING failed getting a label from " + print.toXML());
				}
				return null;
			}

			
			private void printNoLinkLabelFoundWarning(Element element) {
				System.err
				.println("Warning: found no label for element '"
						+ element.toXML()
						+ " in"
						+ input.getBaseURI().substring(
								input.getBaseURI()
										.lastIndexOf('/')));
			}
			
			private void printLabelAddedWarning(Element element, String label) {
				System.out
				.println("Info: adding label '"+ label +"' to element "
						+ element.toXML()
						+ " in "
						+ input.getBaseURI().substring(
								input.getBaseURI()
										.lastIndexOf('/')));
			}
		});
	}

	/**
	 * Iterate over the input tree, checking whether any fragment XHTML or
	 * DOCBOOK links resolve, if not, reset those links to spec or cmp, issuing
	 * a warning for each reset.
	 * 
	 * @throws Exception
	 */
	private void handleBrokenFragmentLinks() throws Exception {
		
		walk(input, new WalkerListener() {

			public void onElement(Element element) throws Exception {
				Attribute linkAttr = getLinkAttr(element);
				if (linkAttr != null && (linkAttr.getLocalName()==Constants.LINKEND || linkAttr.getValue().trim().startsWith("#"))) {
					String id = linkAttr.getValue().trim();
					if (id.startsWith("#"))
						id = id.substring(1);

					if (!inputIDMap.containsKey(id)) {
						
						boolean specIdMatch = false;
						boolean cmpIdMatch = false;
						
						if (specIDMap.containsKey(id))
							specIdMatch = true;
						if (cmpIDMap.containsKey(id))
							cmpIdMatch = true;
						if (specIdMatch == cmpIdMatch) {
							if(specIdMatch) {
								System.err.println("ERROR (LinkExpander): spec and cmp both matches id " + id + printLocation(element));
								specIdMatch = false; //choose the CMP match
							}else{
								System.err.println("ERROR (LinkExpander): neither spec nor cmp matches id " + id + printLocation(element));
								return;
							}
						}

						
						if (specIdMatch) {
							prependPathToFragment(linkAttr, Constants.ZEDAI_WWW_SPEC_PATH);
						} else if (cmpIdMatch) {
							prependPathToFragment(linkAttr, Constants.ZEDAI_WWW_CMP_PATH);
						} else {
							throw new IllegalStateException(
									"no spec or cmp match for id "
											+ id);
						}	
						
						if (linkAttr.getLocalName()==Constants.LINKEND) {
							//change to xlink:href
							Attribute xh = new Attribute(Constants.XLINK_PFX + ":" +  Constants.HREF, Constants.XLINK_NS, linkAttr.getValue());
							element.addAttribute(xh);
							element.removeAttribute(linkAttr);
							if(element.getLocalName()==Constants.XREF) {
								//change to link
								Element link = new Element(Constants.LINK, Constants.DOCBOOK_NS);
								link.addAttribute((Attribute)xh.copy());
								element.getParent().replaceChild(element, link);
							}
						}					
																								
					} //if (!inputIDMap.containsKey(id))
				}
			}

			private String printLocation(Element element) {
				String location;
				Element copy = (Element)element.copy();
				for (int i = 0; i < copy.getChildCount(); i++) {
					copy.getChild(i).getParent().removeChild(i);
				}
				location = "[" + copy.toXML() + "]";
				
				location += " [" + element.getDocument().getRootElement().getBaseURI()+ "]";
				
				return location;
			}

			private void prependPathToFragment(Attribute linkAttr, String prepend) {
				printResetWarning(linkAttr.getValue(), prepend);
				String origValue = linkAttr.getValue().trim();
				String hash = origValue.startsWith("#") ? "" : "#";
				linkAttr.setValue(prepend + hash + origValue);
			}

			private void printResetWarning(String uri, String prepend) {
				String path = (prepend.equals(Constants.ZEDAI_WWW_SPEC_PATH)) ? "SPEC PATH" : "CMP PATH"; 
									
				System.out.println("Warning: changing the uri '"
						+ uri
						+ " by prepending the "
						+ path
						+ " in "
						+ input.getBaseURI().substring(
								input.getBaseURI().lastIndexOf('/')));
			}

		});

	}

	private boolean isLinkElement(Element element) {
		if ((element.getLocalName() == Constants.ANCHOR && element
				.getNamespaceURI() == Constants.XHTML_NS)
				|| (element.getLocalName() == Constants.LINK && element
						.getNamespaceURI() == Constants.DOCBOOK_NS)) {
			return true;
		}
		return false;
	}
	
	/**
	 * Return a xhtml:href or docbook:linkend or xlink:href attribute if it exists, else null. 
	 */
	private Attribute getLinkAttr(Element element) {
		// xhtml
		Attribute linkAttr = element.getAttribute(Constants.HREF);
		if (linkAttr != null)  return linkAttr;
		
		// docbook
		linkAttr = element.getAttribute(Constants.LINKEND);
		if (linkAttr != null)  return linkAttr;

		//xlink
		linkAttr = element.getAttribute(Constants.HREF, Constants.XLINK_NS);
		
		return linkAttr;
		
	}

	private void buildIDMaps() {
		// docbook or xhtml or rng
		if (this.inputType == InputType.XHTML) {
			inputIDMap = buildIDMap(input, Constants.ID, null);
		} else {
			inputIDMap = buildIDMap(input, Constants.ID, Constants.XML_NS);
		}
		// always docbook
		specIDMap = buildIDMap(this.spec, Constants.ID, Constants.XML_NS);
		cmpIDMap = buildIDMap(this.cmp, Constants.ID, Constants.XML_NS);
	}

	private Map<String, Element> buildIDMap(Document doc,
			String idAttrLocalName, String idAttrNamespace) {
		String idAttrName = idAttrLocalName;
		if (idAttrNamespace != null) {
			idAttrName = Constants.nsMap.get(idAttrNamespace) + ":"
					+ idAttrLocalName;
		}

		Map<String, Element> map = new HashMap<String, Element>();
		Nodes nodes = doc.getRootElement().query("//*[@" + idAttrName + "]",
				Constants.namespaces);
		for (int i = 0; i < nodes.size(); i++) {
			Element elem = (Element) nodes.get(i);
			if (idAttrNamespace != null) {
				map.put(elem
						.getAttributeValue(idAttrLocalName, idAttrNamespace),
						elem);
			} else {
				map.put(elem.getAttributeValue(idAttrLocalName), elem);
			}
		}
		return map;
	}

	private InputType getInputType() {
		if (input.getRootElement().getLocalName() == Constants.GRAMMAR) {
			return InputType.RNG;
		} else if (input.getRootElement().getLocalName() == Constants.HTML) {
			return InputType.XHTML;
		}
		return InputType.DOCBOOK;
	}

	private enum InputType {
		DOCBOOK, XHTML, RNG;
	}

	private void walk(Document in, WalkerListener listener) throws Exception {
		listener.onElement(in.getRootElement());
		walk(in.getRootElement(), listener);
	}

	private void walk(Element in, WalkerListener listener) throws Exception {
		Elements elements = in.getChildElements();
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			listener.onElement(element);
			walk(element, listener);
		}
	}

	public interface WalkerListener {
		void onElement(Element element) throws Exception;
	}
	
//	public static void main(String[] args) throws Exception {
//		//debug
//		
//		
//		
//	}
	
}
