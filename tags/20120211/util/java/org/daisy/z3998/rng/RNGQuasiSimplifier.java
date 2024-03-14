package org.daisy.z3998.rng;

import java.io.PrintStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.namespace.QName;

import nu.xom.Attribute;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Elements;
import nu.xom.Node;
import nu.xom.Nodes;
import nu.xom.ParentNode;

import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3998.Constants;
import org.daisy.z3998.xom.XOMUtil;

public class RNGQuasiSimplifier {
	/**
	 * TODO ws normalization
	 * TODO option to keep some classes nonatomic
	 * TODO normalization of <mixed> etc, as per SRNG
	 * TODO handle start combine	
	 */
			
	private boolean verbose = true;
	private boolean debug = false;
	private StringBuilder sb; 
		
	private String activeFeature = "none";
	
	public RNGQuasiSimplifier(String[] args) throws Exception {
		
		long start = System.nanoTime();			
		verbose = (args.length > 2) ? Boolean.parseBoolean(args[2]) : false;
		debug = (args.length > 3) ? Boolean.parseBoolean(args[3]) : false;
		
//		debug = true;
//		verbose = true;
				
		Document grammar = XOMUtil.build(FilenameOrFileURI.toURI(args[0]).toString());
				
		doDereference(grammar.getRootElement(), true);
				
		doNamespaces(grammar.getRootElement());
		
		doDatatypes(grammar.getRootElement());
		
		doFlatten(grammar.getRootElement());
				
		delete(grammar.getRootElement(), ".//xhtml:*"); //TEMP
		
		delete(grammar.getRootElement().getChildElements(Constants.DOCUMENTATION, Constants.RNGA_NS));  //TEMP
		
		doStarts(grammar);
		
		doCombineDefines(grammar);
		
		doAtomizeDefines(grammar, ".//rng:element");
		
		doAtomizeDefines(grammar, ".//rng:attribute");
		
		doChoiceRefs(grammar);
		
		doExpandNonAtomicDefineRefs(grammar);
		
		doUnusedDefines(grammar);
		
		doVariantSchematronDistribution(grammar);
		
		if(debug) {
			checkUnusedDefines(grammar);			
		}
		
		doClean(grammar);
						
		XOMUtil.serialize(grammar,FilenameOrFileURI.toFile(args[1]));	
				
		System.out.println("RngQuasiSimplifier spent " + (System.nanoTime()-start)/1000000);
		
		if(verbose||debug) {
			Nodes elements = grammar.getRootElement().query("//rng:element", Constants.namespaces);
			Nodes attributes = grammar.getRootElement().query("//rng:attribute", Constants.namespaces);
			Nodes refs = grammar.getRootElement().query("//rng:ref", Constants.namespaces);
			Nodes defines = grammar.getRootElement().query("//rng:define", Constants.namespaces);
			
			stdout("Grammar contains ", elements.size(), " <rng:element/>, ", attributes.size(), " <rng:attribute/>, ", refs.size(), " <rng:ref/>, ", defines.size(), " <rng:define/>.");
						
		}
	}

	/**
	 * Specific to ZedAI: if one define in a group of variants have schematron embedded, then
	 * copy that schematron to the other variants in the group
	 */
	private void doVariantSchematronDistribution(Document grammar) {	
				
		Nodes elementDefines = grammar.getRootElement().query("//rng:define[rng:element]", Constants.namespaces);
		Map<QName, Set<Element>> sorted = new HashMap<QName, Set<Element>>();
		for (int i = 0; i < elementDefines.size(); i++) {
			Element define = (Element) elementDefines.get(i);
			Element element = define.getFirstChildElement(Constants.ELEMENT,Constants.RNG_NS);
			String ns = element.getAttributeValue(Constants.NS); 
			String name = element.getAttributeValue(Constants.NAME);			
			if(ns!=null && name !=null) {
				QName qname = new QName(ns, name);
				if(!sorted.containsKey(qname)) {
					sorted.put(qname, new HashSet<Element>());
				}
				sorted.get(qname).add(define);
			}else{
				if(debug) {
					stdout("WARNING: no qname created for: ", define.getAttributeValue(Constants.NAME), "in #doVariantSchematronDistribution");
				}
			}
		}
		
		for(QName key : sorted.keySet()) {
			Set<Element> defs = sorted.get(key);
			if(defs.size()>1) {
				//we have multiple defs of the same qname
				//get those that contain schematron				
				int defsWithSCH = 0;
				Nodes sch = null;
				for (Element def : defs) {
					Nodes test = def.query(".//sch:*[parent::rng:*]", Constants.namespaces);
					if(test.size()>0) {
						defsWithSCH++;
						sch = test;
					}
				}
				
				if(defsWithSCH>0) {
					if(defsWithSCH==1) {
						errout("====> Distributing schematron for ", key, " to ", defs.size()-1, " elements");
						//copy sch as last child of element in those
						//defines that has no sch
						for (Element def : defs) {
							Nodes test = def.query(".//sch:*", Constants.namespaces);
							if(test.size()<1) {
								Element element = def.getFirstChildElement(Constants.ELEMENT,Constants.RNG_NS);
								for (int i = 0; i < sch.size(); i++) {
									element.appendChild(sch.get(i).copy());
									errout("====> adding sch to " + def.getAttributeValue(Constants.NAME));
								}
							}							
						}						
					}else{
						errout("====> WARNING: multiple defs with qname ", key, " contain schematron (RNGQuasiSimplifier#doVariantSchematronDistribution)");
					}
				}				
			}
		}		
	}

	private void checkUnusedDefines(Document grammar) throws Exception {
		Map<String, List<Element>> refMap = buildNameMap(grammar.getRootElement(), Constants.REF);
		Elements defines = grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS);
		for (int i = 0; i < defines.size(); i++) {
			Element define = defines.get(i);
			String name = define.getAttributeValue(Constants.NAME);				
			if(!refMap.containsKey(name)) {
				stdout("remaining unused define: ", name);
			}
		}
		
	}

	/**
	 * Run a subset of the RelaxNG simplification process.
	 * <p>Arguments:</p>
	 * <ol>
	 * <li>0: path to input RNG schema</li>
	 * <li>1: path to output RNG schema</li>
	 * <li>2: verbose, 'true'|'false', is optional</li>
	 * <li>3: debug, 'true'|'false', is optional</li>
	 * </ol>
	 */
	public static void main(String[] args) throws Exception {
		new RNGQuasiSimplifier(args);
	}

	/**
	 * Dereference externalRef and include elements. 
	 * Result is a single grammar document.
	 * @throws Exception 
	 */
	private void doDereference(final Element grammar, final boolean isDriver) throws Exception {			
		doExternalRefs(grammar);		
		if(isDriver) addFeatureFlag(grammar);
		descendantWalker(grammar, new WalkerListener(){
			public void onElement(Element element) throws Exception {
				if(element.getLocalName() == Constants.INCLUDE && element.getNamespaceURI() == Constants.RNG_NS) {
					if(isDriver) setActiveFeature(element);
					URI includeURI = URI.create(grammar.getDocument().getBaseURI()).resolve(element.getAttributeValue("href"));
					Document included = XOMUtil.build(includeURI.toString());			
					doDereference(included.getRootElement(), false);
					doOverrides(element, included);			
					addFeatureFlag(included.getRootElement());	
					//delete(included.getRootElement().getChildElements(Constants.RDF, Constants.RDF_NS));
					delete(included.getRootElement().getChildElements(Constants.INFO, Constants.DOCBOOK_NS));
					element.getParent().replaceChild(element, included.getRootElement().copy());
				}				
			}});						 
	}
		
	private void doExternalRefs(final Element grammar) throws Exception {	
		final Match match = new Match();
		descendantWalker(grammar, new WalkerListener() {			
			public void onElement(Element externalRef) throws Exception {
				if(externalRef.getLocalName() == Constants.EXTERNALREF) {		
					match.bool = true;
					URI externalRefURI = URI.create(grammar.getDocument().getBaseURI()).resolve(externalRef.getAttributeValue("href"));
					Document refDocument = XOMUtil.build(externalRefURI.toString());			
					externalRef.getParent().replaceChild(externalRef, refDocument.getRootElement());
				}
			}
		});
		if(!match.bool) return;
		doExternalRefs(grammar);									
	}

	/**
	 * Move the datatypeLibrary attribute to each individual data element. Add type="token" to values.
	 * @throws Exception 
	 */
	private void doDatatypes(Element grammar) throws Exception {
		descendantWalker(grammar, new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS) {
					if(element.getLocalName() == Constants.DATA  && element.getAttribute(Constants.DATATYPELIBRARY)==null) {
						Element libraryCarrier = XOMUtil.getAncestorWithAttribute(element, Constants.DATATYPELIBRARY);
						String value = (libraryCarrier!=null) ? libraryCarrier.getAttributeValue(Constants.DATATYPELIBRARY) : "";
						element.addAttribute(new Attribute(Constants.DATATYPELIBRARY, value));
					}else if (element.getLocalName() == Constants.VALUE && element.getAttribute(Constants.TYPE)==null) {
						element.addAttribute(new Attribute(Constants.TYPE, Constants.TOKEN));			
						element.addAttribute(new Attribute(Constants.DATATYPELIBRARY, ""));
					}
				}				
			}
		});				
	}
	
	/**
	 * Replace all grammar and div elements by their children
	 * @throws Exception 
	 */
	private void doFlatten(Element grammar) throws Exception {
		final Match match = new Match();
		descendantWalker(grammar, new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if((element.getLocalName() == Constants.DIV || element.getLocalName() == Constants.GRAMMAR) && element.getNamespaceURI() == Constants.RNG_NS) {
					match.bool = true;
					replaceByChildren(element);
				}
			}
		});	
		if(!match.bool) return;
		doFlatten(grammar);
	}
	
	/**
	 * Give each rng:element and rng:attribute a local ns attr. Input doc still has nested grammars from which the info is fetched.
	 * The result is a document where no @name on rng:element and rng:attribute contains a prefixed QName.
	 * @throws Exception 
	 */
	private void doNamespaces(final Element grammar) throws Exception {
		final Element root = grammar.getDocument().getRootElement();
		
		descendantWalker(grammar, new WalkerListener() {
			
			public void onElement(Element element) throws Exception {
				
				if((element.getLocalName() == Constants.ELEMENT || element.getLocalName() == Constants.ATTRIBUTE 
						|| element.getLocalName() == Constants.NAME || element.getLocalName() == Constants.NSNAME)
						&& element.getNamespaceURI() == Constants.RNG_NS) {
					
					String ns="";
					
					//if given @name is prefixed, use that, else look for @ns
					if(element.getAttributeValue(Constants.NAME) != null && element.getAttributeValue(Constants.NAME).contains(":")) {						
						String nameValue = element.getAttributeValue(Constants.NAME);
						String pfx = nameValue.substring(0, nameValue.indexOf(':'));												
						String sfx = nameValue.substring(nameValue.indexOf(':')+1);												
						ns = element.getNamespaceURI(pfx);
						element.addAttribute(new Attribute(Constants.NAME, sfx));												
					}else {
						//else look for @ns					
						ns = element.getAttributeValue(Constants.NS);
						if(ns == null && element.getLocalName() != Constants.ATTRIBUTE) {
							Element nsdeclarator = XOMUtil.getAncestorWithAttribute(element, Constants.NS);
							if(nsdeclarator!=null) {
								ns = nsdeclarator.getAttributeValue(Constants.NS);
							}else {
								ns="";							
							}								
						}
					}
					if(ns==null) ns="";
					element.addAttribute(new Attribute(Constants.NS,ns));
					
					//for convenience, make sure all grammar namespaces+prefixes
					//are declared on root. We assume the grammars default namespace
					//is available as @ns on the root
					if(!ns.equals("")) {
						if(!(root.getAttributeValue(Constants.NS).equals(ns))) {	
							String prefix = getPrefix(ns);						
							if(root.getNamespaceURI(prefix)==null) {
								root.addNamespaceDeclaration(prefix, ns);
							}
						}
					}
					
				}
			}	
		});				
	}
	
	
	/**
	 * Handle include overrides (nested define and start elements).
	 */
	private void doOverrides(Element include, Document included) {
		Elements overriding = include.getChildElements();		
		for (int i = 0; i < overriding.size(); i++) {				
			Element override = (Element) overriding.get(i);
			if(override.getNamespaceURI() == Constants.RNG_NS){
				if(override.getLocalName() == Constants.DEFINE) {
					String name = override.getAttributeValue(Constants.NAME);					
					Nodes overridden = included.query("//rng:define[@name='" + name + "']", Constants.namespaces);
					for (int k = 0; k < overridden.size(); k++) {
						Element overriddenDefine = (Element) overridden.get(k);
						overriddenDefine.getParent().replaceChild(overriddenDefine, override.copy());
					}
				}else if(override.getLocalName() == Constants.START) {
					Nodes starts = included.query("//rng:start", Constants.namespaces);
					for (int j = 0; j < starts.size(); j++) {
						Element start = (Element) starts.get(j);
						start.getParent().replaceChild(start, override.copy());
					}
				}				
			}
		}		
	}

	private void doStarts(Document grammar) {
		//remove starts that are notAllowed		
		Elements children = grammar.getRootElement().getChildElements(Constants.START, Constants.RNG_NS);
		for (int i = 0; i < children.size(); i++) {
			Element start = children.get(i);
			//if this start only has an rng:notAllowed, kill it
			if(start.getChildElements(Constants.NOTALLOWED, Constants.RNG_NS).size()>0) {
				start.getParent().removeChild(start);
			}
		}				
	}

	/**
	 * Combine defines with the same name. The result is a grammar where each define has a unique name.
	 * @throws Exception 
	 */
	private void doCombineDefines(Document grammar) throws Exception {
		Map<String,List<Element>> defineMap = buildNameMap(grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS));
		for(String name : defineMap.keySet()) {
			List<Element> defines = defineMap.get(name);
			if(defines.size()>1) {
				//System.out.println("multiple defines for " + name);
				CombineType combineType = getCombineType(defines);
				//create an entirely new define, add the dupes content to it, delete the source define
				Element newDefine = new Element(Constants.DEFINE, Constants.RNG_NS);
				newDefine.addAttribute(new Attribute(Constants.NAME, name));
				Element newDefineSingleChild = new Element(combineType.name(),Constants.RNG_NS);				
				newDefine.appendChild(newDefineSingleChild);
				
				boolean annoAdded = false;
				for(Element define : defines) {
					Elements children = define.getChildElements();
					for (int i = 0; i < children.size(); i++) {
						Element child = children.get(i);
						//only bring the first docbook:annotation element, and all RNG elements over
						if(child.getNamespaceURI() == Constants.DOCBOOK_NS) {
							if(annoAdded) {								
								continue;																	
							}else {				
								child.detach();
								newDefine.insertChild(child, 0);
								annoAdded = true;
							}
						}else if(child.getNamespaceURI() == Constants.RNG_NS){	
							child.detach();
							newDefineSingleChild.appendChild(child);
						}else{
							stdout("WARNING: not adding child {", 
									child.getNamespaceURI(),"}",child.getLocalName(), 
									 " when combining defines ");
						}						
					}							
					define.getParent().removeChild(define);					
				}
				//TODO here would be the spot to remove non-alone notAllowed children,
				//instead of doing it in doClean
				grammar.getRootElement().appendChild(newDefine);
			}
		}
	}

	private void doAtomizeDefines(Document grammar, String selector) throws Exception {
		//get all defines in the grammar
		Elements defines = grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS);
		if(debug) {
			int all = grammar.getRootElement().query("//rng:define", Constants.namespaces).size();
			if(all != defines.size()) {
				errout("Mismatch in definecount in doAtomizeDefines");
			}
		}
		//build a Map<@rng:name, List<Element>
		Map<String,List<Element>> defineMap = buildNameMap(defines);
		//create a merged List of all defines
		List<Element> defineList = new ArrayList<Element>();
		for(List<Element> defs : defineMap.values()) {
			defineList.addAll(defs);
		}
		//call the worker method, passing both the map and the merged list
		doAtomizeDefines(grammar, defineList, defineMap, selector);
	}
	
	/**
	 * Make all selected elements be unique patterns in a define (possibly wrapped in <optional>)
	 */
	private void doAtomizeDefines(Document grammar, List<Element> defines
			, Map<String,List<Element>> defineMap, String selector) throws Exception {
				
		List<Element> addedDefines = new ArrayList<Element>();
		
		for (int i = 0; i < defines.size(); i++) {
			Element define = defines.get(i);			
			Nodes subjects = define.query(selector, Constants.namespaces); 

			if (subjects.size()==0) continue;
			
			//collect all elements in this define that need to be turned into a ref
			List<Element> elementsToReplace = new ArrayList<Element>(); 
			for (int j = 0; j < subjects.size(); j++) {
				boolean ok = false;
				Element subject = (Element)subjects.get(j); 
				Element subjectParent = (Element)subject.getParent();
				if(subjectParent.getLocalName() == Constants.DEFINE) {
					//make sure define has only this one rng:element child
					if(exactlyOneRngElement(subjectParent.getChildElements()) != null) {
						ok = true;
					}
				} else if(subjectParent.getLocalName() == Constants.OPTIONAL) {
					Element optionalParent = (Element)subjectParent.getParent();
					if(exactlyOneRngElement(subjectParent.getChildElements()) != null
							&& optionalParent.getLocalName() == Constants.DEFINE
							&& exactlyOneRngElement(optionalParent.getChildElements())!=null) {
						ok = true;
					}
				} 
				if(!ok)	elementsToReplace.add(subject);				
			}
												
			for (Element elementToReplace : elementsToReplace ) {
				String newDefineName = define.getAttributeValue(Constants.NAME) + "." + elementToReplace.getAttributeValue(Constants.NAME);
				int r = 0;
				String unique = newDefineName;
				while(defineMap.containsKey(unique)){
					unique = newDefineName + "_" + ++r;			
				}
				newDefineName = unique;
				
				Element newDefine = new Element(Constants.DEFINE,Constants.RNG_NS);
				Element newRef = new Element(Constants.REF,Constants.RNG_NS);
				Attribute nameAttr = new Attribute(Constants.NAME,newDefineName); 
				newDefine.addAttribute(nameAttr);
				newRef.addAttribute((Attribute)nameAttr.copy());				
				newDefine.appendChild(elementToReplace.copy());
				elementToReplace.getParent().replaceChild(elementToReplace, newRef);
				define.getParent().insertChild(newDefine, define.getParent().indexOf(define));
									
				//add the new define to the maps
				defineMap.put(newDefineName, new ArrayList<Element>());
				defineMap.get(newDefineName).add(newDefine);
				addedDefines.add(newDefine);
													
			}
		}
		
		if(addedDefines.size()>0) {
			doAtomizeDefines(grammar, addedDefines, defineMap, selector);
		}
		
		if(debug) {
			Nodes failed = grammar.getRootElement().query("./rng:define[count(" + selector + ")>1]", Constants.namespaces);
			for (int i = 0; i < failed.size(); i++) {
				Element fail = (Element)failed.get(i).copy();
				fail.removeChildren();
				errout("AtomizeElementDefines missed: " ,	fail.toXML());
			}
		}
	}
	
	private void doChoiceRefs(Document grammar) {
		Nodes choiceRefs = grammar.getRootElement().query("./rng:define//rng:choice/rng:ref", Constants.namespaces);
		
		Set<String> fixed = new HashSet<String>();
		
		for (int i = 0; i < choiceRefs.size(); i++) {			
			Element ref = (Element)choiceRefs.get(i);	
			String defineName = ref.getAttributeValue(Constants.NAME);
			if (fixed.contains(defineName)) continue;
									
			Element define = getDefine(grammar, defineName);
			
			Boolean hasSingleChildPattern = exactlyOneRngElement(define.getChildElements()) != null;
					
			if(!hasSingleChildPattern) {
				//stdout("changing define " , define.getAttribute(NAME).getValue(), " to have single child pattern by adding a group");
				Element group =  new Element(Constants.GROUP,Constants.RNG_NS);				
				Elements children = define.getChildElements();
				for (int j = 0; j < children.size(); j++) {					
					Element child = children.get(j);
					if(child.getNamespaceURI() == Constants.RNG_NS){
						group.appendChild(child.copy());
						child.getParent().removeChild(child);
					}
				}
				define.appendChild(group);
				fixed.add(defineName);
			}
		}	
		
	}

	/**
	 * Replace all refs that refer to non-atomic defines with the content of that define.
	 * The result is a grammar where all remaining refs refer to defines with a single element,
	 * attribute, data or value child, possibly wrapped in optional.
	 */
	private void doExpandNonAtomicDefineRefs(Document grammar) throws Exception {
		//Map<String, List<Element>> refMap = buildNameMap(grammar.getRootElement(), REF);
		Elements defines = grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS);
		for (int i = 0; i < defines.size(); i++) {
			Element define = defines.get(i);
			final Elements defineChildren = define.getChildElements();
			final String defineName = define.getAttributeValue(Constants.NAME);
			final DefineType defineType = getDefineType(define);
							
			descendantWalker(grammar.getRootElement(), new WalkerListener() {
				public void onElement(Element ref) throws Exception {
					if(ref.getLocalName() == Constants.REF && ref.getAttributeValue(Constants.NAME).equals(defineName)) {
						if(defineType == DefineType.other) {
							//is non-atomic, replace all refs with contents of define							
							int pos = ref.getParent().indexOf(ref);							
							for (int j = 0; j < defineChildren.size() ; j++) {
								Element defineChild = defineChildren.get(j);
								if(defineChild.getNamespaceURI() == Constants.RNG_NS) {
									ref.getParent().insertChild(defineChild.copy(), ++pos);
								}	
							}								
							ref.getParent().removeChild(ref);														
						}else{
							//is an atomic define, annotate the refs pointing to it
							ref.addAttribute(new Attribute("zrng:define", Constants.Z3998_RNG_NS, defineType.name()));
						}
					}
				}
			});
			
		}
		
		if(debug) {
			Nodes failed = grammar.getRootElement().query("//rng:ref[not(@zrng:define)]", Constants.namespaces);
			for (int i = 0; i < failed.size(); i++) {
				Element ref = (Element)failed.get(i);
				errout("ref without xrng:define", ref.toXML());
			}
		}
		
	}

	private DefineType getDefineType(Element define) throws Exception {				
		Element defineChild = exactlyOneRngElement(define.getChildElements());
		if(defineChild!=null) {			
			String localName = defineChild.getLocalName(); 
			if(localName == Constants.ELEMENT) {			
				return DefineType.element;	
			}else if(localName == Constants.ATTRIBUTE) {
				return DefineType.attribute;
			}else if(localName == Constants.DATA) {
				return DefineType.data;
			}else if(localName == Constants.OPTIONAL) {
				return getDefineType(defineChild);
			}
		}
		return DefineType.other;		
	}
	
	/**
	 * Remove all defines that are not referenced from any ref
	 * @throws Exception 
	 */
	private void doUnusedDefines(Document grammar) throws Exception {
		Map<String, List<Element>> refMap = buildNameMap(grammar.getRootElement(), Constants.REF);
		Elements defines = grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS);
		boolean foundUnused = false;
		StringBuilder sb = new StringBuilder("Removed unused defines: ");
		for (int i = 0; i < defines.size(); i++) {
			Element define = defines.get(i);
			String name = define.getAttributeValue(Constants.NAME);
			if(!refMap.containsKey(name)) {
				define.getParent().removeChild(define);
				foundUnused = true;
				if(debug|verbose) {
					sb.append(name).append(", ");
				}
			}
		}				
		if(foundUnused) {
			if(debug|verbose) {
				stdout(sb.toString());
			}
			doUnusedDefines(grammar);
		}
	}

	private void doClean(Document grammar) throws Exception {
		//remove nested choice, interleave and optional
		replaceByChildren("//rng:choice/rng:choice|//rng:interleave/rng:interleave|//rng:optional/rng:optional", grammar.getRootElement());
		
		//remove all non-alone <empty/> children of element//interleave 
		delete(grammar.getRootElement(), "//rng:element//rng:interleave[rng:empty and count(rng:*)>1]/rng:empty");
				
//		//remove notAllowed children of choice, when the notAllowed is not the only child of that choice
//		delete(grammar.getRootElement(),"//rng:choice[rng:notAllowed and count(rng:*)>1]/rng:notAllowed");
//		
//		//remove notAllowed children of interleave, when the notAllowed is not the only child of that interleave
//		delete(grammar.getRootElement(),"//rng:interleave[rng:notAllowed and count(rng:*)>1]/rng:notAllowed");
		
		//remove all notAllowed that has siblings
		delete(grammar.getRootElement(),"//rng:*[rng:notAllowed and count(rng:*)>1]/rng:notAllowed");
		
		//remove all notAllowed that are the single child of optional
		delete(grammar.getRootElement(),"//rng:optional[rng:notAllowed and count(rng:*)=1]");
		
//		//remove zeroOrMore children of choice, when that zeroOrMore is not the only child of choice and
//		//the zeroOrMore has exactly one child named notAllowed
//		delete(grammar.getRootElement(),"//rng:choice[count(rng:*)>1 and rng:zerOrMore/rng:notAllowed and count(rng:zerOrMore/rng:*) = 1]/rng:zeroOrMore");
//
//		//remove zeroOrMore children of interleave, when that zeroOrMore is not the only child of interleave and
//		//the zeroOrMore has exactly one child named notAllowed
//		delete(grammar.getRootElement(),"//rng:interleave[count(rng:*)>1 and rng:zerOrMore/rng:notAllowed and count(rng:zerOrMore/rng:*) = 1]/rng:zeroOrMore");
						
		//remove interleaves with only one child pattern
		replaceByChildren("//rng:interleave[count(rng:*)=1]", grammar.getRootElement());
		
		//remove empty inside choice, if empty has one other rng sibling, and choice as zeroOrMore parent		
		//delete(grammar.getRootElement(),"//rng:zeroOrMore/rng:choice[rng:empty and count(rng:*)=2]/rng:empty");
		
		//remove choice with only one child pattern
		replaceByChildren("//rng:choice[count(rng:*)=1]", grammar.getRootElement());

		//remove zeroOrMore with only one zeroOrMore child
		replaceByChildren("//rng:zeroOrMore[rng:zeroOrMore and count(*)=1]", grammar.getRootElement());
		
		//remove all zeroOrMore where empty is only child
		delete(grammar.getRootElement(),"//rng:zeroOrMore[rng:empty and count(rng:*)=1]");
		
		//remove all zeroOrMore where notAllowed is only child
		delete(grammar.getRootElement(),"//rng:zeroOrMore[rng:notAllowed and count(rng:*)=1]");

		//remove element/interleave that only contains attribute ref children	
		doAttrInterleaves(grammar);
		
		//remove all <empty/> children of element unless empty is only child 
		delete(grammar.getRootElement(),"//rng:element[rng:empty and count(rng:*)>1]/rng:empty");

		//add more namespaces to root to allow the serializer to strip out locally
		grammar.getRootElement().addNamespaceDeclaration(Constants.DCTERMS_PFX, Constants.DCTERMS_NS);		
		grammar.getRootElement().addNamespaceDeclaration(Constants.Z_M12N_VOCAB_PFX, Constants.Z_M12N_VOCAB_NS);		
		//grammar.getRootElement().addNamespaceDeclaration(Constants.RDF_PFX, Constants.RDF_NS);
		grammar.getRootElement().addNamespaceDeclaration(Constants.ISO_SCH_PFX, Constants.ISO_SCH_NS);
		grammar.getRootElement().addNamespaceDeclaration(Constants.DOCBOOK_PFX, Constants.DOCBOOK_NS);
	}

	/**
	 * Remove element/interleave that only contain atomic attr refs
	 */
	private void doAttrInterleaves(Document grammar) throws Exception {
		Nodes interleaves = grammar.getRootElement().query("./rng:define//rng:element/rng:interleave", Constants.namespaces);
		for (int i = 0; i < interleaves.size(); i++) {
			Element interleave = (Element) interleaves.get(i);
			if(isAttrInterleave(interleave)) {
				replaceByChildren(interleave);
			}			
		}		
	}
	
	/**
	 * Find out whether given interleave element only has attribute patterns (direct or by ref) children 
	 */
	private boolean isAttrInterleave(Element interleave) throws Exception {
		Nodes interleaveChildren = interleave.query(".//rng:*", Constants.namespaces);
		for (int k = 0; k < interleaveChildren.size(); k++) {
			Element child = (Element) interleaveChildren.get(k);
			String localName = child.getLocalName();
			if(localName == Constants.OPTIONAL || localName == Constants.ATTRIBUTE || localName == Constants.EMPTY) {
				continue;
			} else if (localName == (Constants.REF) && child.getAttributeValue(Constants.DEFINE,Constants.Z3998_RNG_NS).equals(Constants.ATTRIBUTE)) {
				continue;
			} 
			return false;			
		}
		return true;
	}

	/**
	 * Types of define patterns. element, attribute and data types
	 * are defines with a single rng child with that name. other is
	 * anything else.
	 */
	private enum DefineType {
		other, element, attribute, data;
	}
	
	private enum CombineType {
		interleave, choice;
	}

	private CombineType getCombineType(List<Element> defines) {
		for(Element define : defines) {
			String combineValue = define.getAttributeValue(Constants.COMBINE);
			if(combineValue!=null) {
				return CombineType.valueOf(combineValue);
			}
		}
		return null;
	}

	/**
	 * If incoming Elements contains exactly one rng ns element, 
	 * return that element, else return null. Elements in
	 * other namespaces are allowed, other types of Nodes are allowed
	 */
	private Element exactlyOneRngElement(Elements elements) {
		Element rng = null;
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			if(element.getNamespaceURI() == Constants.RNG_NS) {
				 if(rng!=null) return null;	//more than one	
				 rng = element;
			}
		}		
		return rng;
	}
	
	/**
	 * Z39.98 specific: if the include has parent div with class='feature',
	 * then this include is a Feature include, whose x:id = the feature machinename.
	 * @param include An include element appearing in the driver.
	 */
	private void setActiveFeature(Element include) {
		Nodes nodes = include.query("parent::rng:div[@xhtml:class='feature']", Constants.namespaces);
		if(nodes.size() == 1) {
			Element div = (Element) nodes.get(0);
			activeFeature = div.getAttributeValue(Constants.ID, Constants.XHTML_NS);			
		}else{
			activeFeature = "none";	
		}
	}
	
	private void addFeatureFlag(Element grammar) throws Exception{	
		grammar.getDocument().getRootElement().addNamespaceDeclaration("zrng", Constants.Z3998_RNG_NS);
		descendantWalker(grammar, new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI()==Constants.RNG_NS &&
					(element.getLocalName() == Constants.ELEMENT || element.getLocalName() == Constants.ATTRIBUTE
							|| element.getLocalName() == Constants.DATA || element.getLocalName() == Constants.VALUE)){
						element.addAttribute(new Attribute(Constants.ZRNG_FEATURE,Constants.Z3998_RNG_NS,activeFeature));
				}
			}							
		});		
	}
	
	/**
	 * Replace all elements matching the given XPath expression by their children.
	 * The given selector must not match the root element, not anything other node type than elements.
	 */
	private void replaceByChildren(String xpath, Element context) throws Exception {
		Nodes toReplace = context.query(xpath, Constants.namespaces);
		if(toReplace.size() == 0) return;
		for (int i = 0; i < toReplace.size(); i++) {
			replaceByChildren((Element) toReplace.get(i));
		}
		replaceByChildren(xpath, context);
	}

	/**
	 * Replace the given element by its children. The given 
	 * element must not be the root node.	 
	 * @throws Exception
	 */
	private void replaceByChildren(Element element) throws Exception {
		ParentNode parent = element.getParent();
		int pos = parent.indexOf(element);
		Elements toInsert = element.getChildElements();
		for (int j = 0; j < toInsert.size(); j++) {
			Element child = toInsert.get(j);
			child.detach();
			parent.insertChild(child, ++pos);
		}
		parent.removeChild(element);						
	}

	
//	/**
//	 * Retrieve the nearest ancestor element that has the given name,
//	 * or null if no such ancestor exists.
//	 */
//	private Element getAncestorWithName(String localName, String nsURI, Element child) {
//		ParentNode parent = child.getParent();
//		if(parent!=null && parent instanceof Element) {			
//			Element eparent = (Element)parent;
//			if(eparent.getLocalName() == localName && eparent.getNamespaceURI() == nsURI){
//				return eparent;
//			}
//			return getAncestorWithName(localName, nsURI, eparent);
//		}	
//		errout("null or non-element parent for: \n ", child.toXML());
//		return null;
//	}

	/**
	 * Delete all matches of the given XPath expression
	 */
	private void delete(Element context, String xpath) {
		Nodes nodes = context.query(xpath, Constants.namespaces);
		stdout("Deleting ", nodes.size(), " nodes using selector ", xpath);
		delete(nodes);
	}

	/**
	 * Delete all given Nodes
	 */
	private void delete(Nodes nodes) {		
		for (int i = 0; i < nodes.size(); i++) {
			Node node = nodes.get(i);
			ParentNode parent = node.getParent();
			if(parent!=null) {
				parent.removeChild(node);
			}else{
				errout("Could not delete node ", node);
			}
		}
	}

	/**
	 * Get a named define being a child of root
	 */
	private Element getDefine(Document grammar, String name) {
		Elements defines = grammar.getRootElement().getChildElements(Constants.DEFINE, Constants.RNG_NS);
		for (int i = 0; i < defines.size(); i++) {
			Element define = defines.get(i);
			if(define.getAttributeValue(Constants.NAME).equals(name)) {
				return define;
			}			
		}
		return null;
	}

	/**
	 * Delete all given Elements
	 */
	private void delete(Elements elements) {		
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			ParentNode parent = element.getParent();
			if(parent!=null) {
				parent.removeChild(element);
			}else{
				errout("Could not delete node ", element);
			}
		}
	}
	
	/**
	 * Builds a map where key is a rng name, and value a list of elements with that value in their @name
	 */
	private Map<String,List<Element>> buildNameMap(Element in, final String rngElementLocalName)  throws Exception{
		final Map<String,List<Element>> map = new HashMap<String,List<Element>>();		
		descendantWalker(in, new WalkerListener() {
			public void onElement(Element element) throws Exception {
				if(element.getNamespaceURI() == Constants.RNG_NS && 
						element.getLocalName() == rngElementLocalName) {
					String name = element.getAttributeValue(Constants.NAME);
					if(!map.containsKey(name)) {
						map.put(name, new ArrayList<Element>());
					}
					map.get(name).add(element);
				}				
			}
		});		
		return map;
	}
	
	/**
	 * Builds a map where key is a rng name, and value a list of elements with that value in their @name
	 */
	private Map<String,List<Element>> buildNameMap(Elements in)  throws Exception{
		final Map<String,List<Element>> map = new HashMap<String,List<Element>>();		
		for (int i = 0; i < in.size(); i++) {
			Element element = in.get(i);			
			String name = element.getAttributeValue(Constants.NAME);
			if(name==null) continue;
			if(!map.containsKey(name)) {
				map.put(name, new ArrayList<Element>());
			}
			map.get(name).add(element);	
		}
		return map;
	}
		
	private void stdout(Object... strings) {
		out(System.out, false, strings);			
	}
	
	private void errout(Object... strings) {
		out(System.err, true, strings);			
	}
	
	private void out(PrintStream out, boolean overrideVerbose, Object... strings) {
		if(sb==null) sb = new StringBuilder();
		if(overrideVerbose || verbose || debug) {
			for(Object s : strings) {
				sb.append(s);
			}
			out.println(sb.toString());
			sb.delete(0, sb.length());
		}	
		
	}
	
	/**
	 * Get a prefix for a namespace URI.
	 */
	private String getPrefix(String nsuri) {
		String prefix = Constants.nsMap.get(nsuri);
		if(prefix == null) {
			String newPrefix = "i";			
			while(Constants.nsMap.values().contains(newPrefix)) {
				newPrefix += "i";				
			}
			Constants.nsMap.put(nsuri,newPrefix);
			stdout("no prefix preregistered for " , nsuri, ", using '", newPrefix, "'.");
			prefix = newPrefix;
		}		
		return prefix;
	}
	
	private void descendantWalker(Element in, WalkerListener listener) throws Exception {			
		Elements elements = in.getChildElements();
		for (int i = 0; i < elements.size(); i++) {
			Element element = elements.get(i);
			listener.onElement(element);
			descendantWalker(element, listener);			
		}
	}
	
	interface WalkerListener {		
		void onElement(Element element) throws Exception;
	}
	
	class Match {
		boolean bool = false;
	}
		
}