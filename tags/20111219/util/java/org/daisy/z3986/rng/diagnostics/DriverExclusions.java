package org.daisy.z3986.rng.diagnostics;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import nu.xom.Attribute;
import nu.xom.Nodes;

import org.daisy.z3986.Constants;
import org.daisy.z3986.rng.model.RNGDocument;

/**
 * List modules in /mod/ that a driver doesn't include.
 */
public class DriverExclusions extends AbstractDiagnostics {
		
	/**
	 * 
	 * @param projectPath project root path
	 * @param driverFilename the driver to check, if null, all drivers are checked
	 * @throws Exception
	 */
	public DriverExclusions(final String projectPath, final String driverFilename) throws Exception {
		super(projectPath);
		
		for(RNGDocument driver : drivers) {
			if(driverFilename == null || driverFilename.equals(driver.getFile().getName())) {
				Set<String> includedModules = new HashSet<String>();
				List<String> excludedModules = new ArrayList<String>();
				
				Nodes includes = driver.getRootElement().query("//rng:include/@href", Constants.namespaces);
				for (int i = 0; i < includes.size(); i++) {					
					String hrefValue = ((Attribute) includes.get(i)).getValue();
					String moduleName = hrefValue.substring(hrefValue.lastIndexOf("/")+1);
					includedModules.add(moduleName);
				}
				
				for(RNGDocument module : mod) {
					if(!includedModules.contains(module.getFile().getName())) {
						excludedModules.add(module.getFile().getName());
					}
				}
				
				if(excludedModules.size()>0) {					
					Collections.sort(excludedModules);
					System.err.println("Driver " + driver.getFile().getName() + " does not directly reference these modules:");
					for(String s : excludedModules) {
						System.err.println("   " + s);
					}
				}
			}
		}
		
	}

	/**
	 * @param args 0: path to zednext project root dir 1: filename of driver to check (optional)
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		new DriverExclusions(args[0], (args.length>1) ? args[1] : null);
	}

}
