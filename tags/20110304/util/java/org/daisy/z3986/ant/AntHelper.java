package org.daisy.z3986.ant;

import java.io.File;
import java.util.Collection;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.daisy.util.file.Directory;

public class AntHelper {

	/**
	 * run ant if the preprocessed schema dir is not up-to-date
	 */
	public static void update(Directory activeDir, Directory srcDir, File antBuildFile) throws Exception {
		if((!activeDir.exists()) || srcChanged(activeDir,srcDir)) {
			System.out.println(("Running Ant..."));
			Project p = new Project();			
			p.setUserProperty("ant.file", antBuildFile.getAbsolutePath());
			p.init();
			ProjectHelper helper = ProjectHelper.getProjectHelper();
			p.addReference("ant.projectHelper", helper);
			helper.parse(p, antBuildFile);
			p.executeTarget("preprocess-src-rng-schemas");
		}
	}
	
	/**
	 * Test if any of the files in the schema src dir is younger than
	 * the files (if any in the preprocessed dir)
	 * @return
	 */
	private static boolean srcChanged(Directory activeDir, Directory srcDir) {				
		Collection<File> sources = srcDir.getFiles(true, ".+\\.rng$");
		Collection<File> preprocs = activeDir.getFiles(true, ".+\\.rng$");		
		
		for(File source : sources) {
			for(File preproc : preprocs) {
				if(source.lastModified() > preproc.lastModified()) {
					return true;
				}
			}
		}		
		return false;
	}
	
}
