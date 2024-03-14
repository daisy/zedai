package org.daisy.z3998.rng.diagnostics;

import org.daisy.z3998.rng.model.RNGDefineElement;
import org.daisy.z3998.rng.model.RNGDocument;

/**
 * Report unused defines.
 */
public class UnusedDefines extends AbstractDiagnostics {
		
	public UnusedDefines(final String projectPath) throws Exception {
		super(projectPath);
		
		String defineName = null;
		boolean reffed = false;
		
		for(RNGDocument rng : all) {			
			for(RNGDefineElement define : rng.getRNGDefines()) {
				defineName = define.getRNGName();
				reffed = false;
				for(RNGDocument doc : all) {
					if(doc.getRNGRefs(defineName).size()>0) {
						reffed = true;
						break;
					}
				}
				if(!reffed) {
					System.out.println("Unused define: " + defineName + " [" + rng.getFile().getName() + "]");
				}
			}			
		}
		
	}

	/**
	 * @param args 0: path to zednext project root dir
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		new UnusedDefines(args[0]);
	}

}
