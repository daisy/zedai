package org.daisy.z3998.rng.diagnostics;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.daisy.util.file.Directory;
import org.daisy.z3998.ant.AntHelper;
import org.daisy.z3998.rng.model.RNGDocument;
import org.daisy.z3998.rng.model.RNGDocuments;

public abstract class AbstractDiagnostics {
	
	protected final Directory projectDir;
	protected final Directory driversDir;
	protected final Directory tempDir;
	protected final Directory tempRngPreprocessedDir;
	private final File antBuildFile;
	
	/** drivers (in parent dir of /mod/) **/
	protected RNGDocuments drivers;			
	/** every rng in /schema/ **/
	protected RNGDocuments all;
	/** every rng in /mod/ **/
	protected RNGDocuments mod;
	/** core modules (excludes features and ignores) **/
	protected RNGDocuments coremodules;		
	/** feature rng's that we control (can edit) **/
	protected RNGDocuments features;		
	/** any rng's that we dont control (cant edit) **/
	protected RNGDocuments ignores; 		
	

	
	/**
	 * Constructor.
	 * @param projectPath path to zednext project top dir
	 */
	public AbstractDiagnostics(String projectPath) throws Exception {
		projectDir = new Directory(projectPath);
		driversDir = new Directory(projectDir, "src/schema");
		tempDir = new Directory(projectDir, "temp");
		tempRngPreprocessedDir = new Directory(tempDir, "all-src-rng-preprocessed");
		antBuildFile = new File(projectDir,"build-ai.xml");
		
		AntHelper.update(tempRngPreprocessedDir, driversDir, antBuildFile);
		
		Collection<File> coll = tempRngPreprocessedDir.getFiles(true, ".+\\.rng$");		
		List<File> list = new ArrayList<File>(coll);
		Collections.sort(list);
		all = new RNGDocuments();
		for(File file : list) {
			if(file.getName().startsWith("_")) continue;
			all.add(file);
		}
		
		coremodules = new RNGDocuments();
		features = new RNGDocuments();
		ignores = new RNGDocuments();
		drivers = new RNGDocuments();
		mod = new RNGDocuments();
		
		for(RNGDocument rng : all) {
			if(rng.getFile().getParentFile().getName().equals("mod")) {
				mod.add(rng);
				String name = rng.getFile().getName();				
				if(name.matches("^mathml3.+\\.rng$|^xforms.+\\.rng$|^iana-lang-enum\\.rng$")) {
					ignores.add(rng);
				}else if (name.matches(".+-feature-.+\\.rng$|^ssml.+\\.rng$|^its-ruby.rng$")){
					features.add(rng);
				}else {
					coremodules.add(rng);
				}								
			}//if(rng.getFile().getParentFile().getName().equals("mod")) {
			else {
				drivers.add(rng);
			}
		}
	}
}
