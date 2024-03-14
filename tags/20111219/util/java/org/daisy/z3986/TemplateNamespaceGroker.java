package org.daisy.z3986;

import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Nodes;

import org.daisy.util.file.FilenameOrFileURI;
import org.daisy.z3986.xom.XOMUtil;

/**
 * Add ns decls for features selectively to the document templates generated in build-ai.xml#build-doc-template
 * @author mgylling
 */
public class TemplateNamespaceGroker {

	public TemplateNamespaceGroker(String[] args) throws Exception {
		
		Document input = XOMUtil.build(FilenameOrFileURI.toURI(args[0]).toString());
		
		//note: we lock the prefix for decl vocab to be 'z3986' /auth:head 
		Nodes featureDecls = input.getRootElement().query("auth:head//auth:meta[contains(@rel,':feature')]", Constants.namespaces);
		for (int i = 0; i < featureDecls.size(); i++) {			
			try{
				String featureRdUri = ((Element)featureDecls.get(i)).getAttributeValue(Constants.RESOURCE);
				
				if(featureRdUri.contains(Constants.MACHINE_NAME_ITS_RUBY)) {
					input.getRootElement().addNamespaceDeclaration(Constants.ITS_PFX, Constants.ITS_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_FORMS)) {
					input.getRootElement().addNamespaceDeclaration(Constants.XFORMS_PFX, Constants.XFORMS_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_MATHML)) {
					input.getRootElement().addNamespaceDeclaration(Constants.MATHML_PFX, Constants.MATHML_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_REND)) {
					input.getRootElement().addNamespaceDeclaration(Constants.REND_PFX, Constants.REND_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_SELECT)) {
					input.getRootElement().addNamespaceDeclaration(Constants.SELECT_PFX, Constants.SELECT_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_SSML)) {
					input.getRootElement().addNamespaceDeclaration(Constants.SSML_PFX, Constants.SSML_NS);
				}
				else if(featureRdUri.contains(Constants.MACHINE_NAME_DESCRIPTION)) {
					input.getRootElement().addNamespaceDeclaration(Constants.DESCRIPTION_PFX, Constants.DESCRIPTION_NS);
				}
			}catch (Exception e) {
				e.printStackTrace();
			}	
		}
				
		XOMUtil.serialize(input, FilenameOrFileURI.toFile(args[0]));
	}

	public static void main(String[] args) throws Exception {
		new TemplateNamespaceGroker(args);
	}
}

