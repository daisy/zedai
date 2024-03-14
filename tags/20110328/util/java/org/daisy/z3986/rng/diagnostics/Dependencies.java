package org.daisy.z3986.rng.diagnostics;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.daisy.z3986.rng.model.RNGDocument;
import org.daisy.z3986.rng.model.RNGRefElement;

/**
 * List suggestions about dependency declarations in core modules
 */
public class Dependencies extends AbstractDiagnostics {
		
	/**
	 * 
	 * @param projectPath project root path
	 * @throws Exception
	 */
	public Dependencies(final String projectPath) throws Exception {
		super(projectPath);
		
		//loop over all modules that have the db:info annotation
		for(RNGDocument rng : mod.getRNGDocumentsWithInfoAnnotations()) {
			
			List<RNGDocument> statedDependencies = rng.getDocbookInfoElement().getInternalDependencies(all);
			
			List<RNGDocument> scope = new ArrayList<RNGDocument>();
			scope.addAll(statedDependencies); scope.add(rng);
			
			//check whether a dependency seems to be missing
			List<RNGRefElement> nonresolvingRefs = new ArrayList<RNGRefElement>();
			
			for(RNGRefElement ref : rng.getRNGRefs()) {
				if(!containsDefine(ref.getRNGName(), scope)) {	
					nonresolvingRefs.add(ref);	
				}
			}
			
			//check whether a stated dependency is redundant
			//if the current doc has no ref that points to defines in extdep then redundant
			
			List<RNGDocument> redundantDeps = new ArrayList<RNGDocument>();
			
			for(RNGDocument statedDep : statedDependencies) {					
				boolean pointsToDep = false;
				for(RNGRefElement ref : rng.getRNGRefs()) {					
					if(statedDep.getRNGDefines(ref.getRNGName()).size()>0) {
						pointsToDep = true; break;
					}					
				}
				if(!pointsToDep) {
					redundantDeps.add(statedDep);					
				}
			}
									
			//report
			if(nonresolvingRefs.size()>0) {
				Set<String> dupeCheck = new HashSet<String>();
				System.err.println("\nMissing dependencies in " + rng.getFile().getName() +":");				
				for(RNGRefElement ref : nonresolvingRefs) {
					String xml = ref.toXML();
					if(!dupeCheck.contains(xml)) {  
						dupeCheck.add(xml);
						System.err.print("   " + xml);
						System.err.println(" (available in " + getDocumentsWithDefine(ref.getRNGName()) + ")");
					}
				}
			}
			
			if(redundantDeps.size()>0) {
				System.err.println("\nRedundant dependency declaration in " + rng.getFile().getName() +":");
				for(RNGDocument doc : redundantDeps) {
					System.err.println("   " + doc.getFile().getName());
				}
			}
		}
		
		
		
	}

	private String getDocumentsWithDefine(String name) throws Exception {
		StringBuilder sb = new StringBuilder();
		for(RNGDocument doc : all.getRNGDocumentsWithDefines(name)) {
			sb.append(doc.getFile().getName()).append(", ");
		}
		sb.delete(sb.length()-2, sb.length());
		return sb.toString();		
	}

	private boolean containsDefine(String name, List<RNGDocument> scope) throws Exception {
		boolean match = false;
		for(RNGDocument doc : scope) {
			if(doc.getRNGDefines(name).size()>0) {
				match=true; break;
			}
		}
		return match;		
	}

	/**
	 * @param args 0: path to zednext project root dir
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		new Dependencies(args[0]);
	}

}
