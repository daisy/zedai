package org.daisy.z3986;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import javax.xml.stream.XMLStreamException;

import org.codehaus.stax2.XMLInputFactory2;
import org.codehaus.stax2.XMLStreamReader2;
import org.daisy.util.xml.catalog.CatalogEntityResolver;
import org.daisy.util.xml.catalog.CatalogExceptionNotRecoverable;

import com.ctc.wstx.stax.WstxInputFactory;

/**
 * Iterate inside the build directory looking for broken links, including fragments.
 * <p>Assumes an Apache install whose DocumentRoot is set to the build dir.</p>
 * @author mgylling
 */
public class WebLinkChecker {

	private static final String wwwURI = "http://www.daisy.org/z3986/2012/";
	private static final String localhostURI = "http://localhost/";
	private boolean DEBUG = false;
	private int i = 0;
	
	private final Errors errors = new Errors();
	private final Set<String> checkedURIs = new HashSet<String>();
	private final Set<String> untraversedURIs = new HashSet<String>();
	private XMLInputFactory2 factory;
	
	public WebLinkChecker() throws Exception {
		try{
			initialize();
			checkURI(URI.create(localhostURI), null);
		}finally{
			System.err.println("URIs not traversed:"); 
			for(String uri : untraversedURIs) {
					System.err.println(uri);
			}
			System.err.println();
			System.err.print("Logged errors: ");
			if(errors.size()>0) {
				System.err.println();
				for(String error : errors) {
					System.err.println(error);
				}
			}else{
				System.err.println("none.");
			}
			
			System.err.println();
			System.err.print("URIs checked " + i);
				
			
		}		
	}
		
	/**
	 * 
	 * @param uriToCheck The URI to check
	 * @param carrier The resource in which uriToCheck appears
	 * @throws Exception
	 */
	private void checkURI(URI uriToCheck, URI carrier) throws Exception {
		
		if(!uriToCheck.isAbsolute()) throw new IllegalStateException(uriToCheck.toString() + " not absolute");
		
		String uriString = uriToCheck.toString();
		if(uriString.startsWith(wwwURI)) {			
			uriToCheck = URI.create(uriString.replace(wwwURI, localhostURI));
			uriString = uriToCheck.toString();			
		}
		
		if(uriToCheck.getHost().equals("localhost")) {
			log("checking uri " + uriString);
			try {		
				//check the resource
				URI resource = stripFragment(uriToCheck);					
				if(!checkedURIs.contains(resource.toString())) {	
					checkedURIs.add(resource.toString());		
					i++;
					URLConnection uc = uriToCheck.toURL().openConnection();					
					if(exists(uriToCheck, uc, carrier)) { 
						String mime = uc.getContentType();					
						if(mime.startsWith("text/html") || mime.startsWith("application/xhtml+xml")) {	
							iterate(resource);				
						}
					}
				}
				
				//check the URI fragment if any
				if(uriToCheck.getFragment()!=null && !checkedURIs.contains(uriString)) {		
					checkedURIs.add(uriString);
					i++;
					checkFragment(uriToCheck, carrier);
				}	
				
			}catch (Exception e) {
				errors.add("checkURI() exception: " + e.getMessage(), uriToCheck, carrier);
			}					
		} else { //if(uri.getHost().equals("localhost"))
			untraversedURIs.add(uriString);
		}		
	}

	/**
	 * Iterate over links in an xhtml doc, calling checkURI 
	 */
	private void iterate (URI uri) throws Exception {		
		InputStream is = null;
		XMLStreamReader2 reader = null;
		try{
			URL sourceURL = uri.toURL();
			is = sourceURL.openStream(); 
			reader = (XMLStreamReader2)factory.createXMLStreamReader(is);
			while(reader.hasNext()) {
				reader.next();
				if(reader.isStartElement() && reader.getLocalName() == Constants.ANCHOR) {
					String ref = reader.getAttributeValue(null, Constants.HREF);
					if(ref!=null) {
						URI link = uri.resolve(ref);
						checkURI(link, uri);
					}
				}
			} //while(reader.hasNext()) {	
		}catch (Exception e) {
			errors.add("[" + uri + "]" + e.getMessage());
		}finally{
			if(is!=null)is.close();
			if(reader!=null)reader.close();
		}
	}

	IDMap idMap = new IDMap();
	
	private void checkFragment(URI uri, URI carrier) throws Exception {
		URI resource = stripFragment(uri);
		String fragment = uri.getFragment();		
		Set<String> ids = idMap.get(resource);
		if(!ids.contains(fragment)) {
			errors.add("checkFragment(): ID '" + fragment + "' missing", uri, carrier);
		}
		
	}

	class IDMap extends HashMap<String,Set<String>> {
		
		public Set<String> get(URI uri) {
			String key = uri.toString();			
			if(!this.containsKey(key)) {
				Set<String> newSet = getIDs(uri);
				this.put(key, newSet);
			}
			return this.get(key);			
		}

		/**
		 * Build a set of IDs, return an empty set if fail
		 * @param uri
		 * @return
		 */
		private Set<String> getIDs(URI uri) {
			Set<String> ret = new HashSet<String>();
			InputStream is = null;
			XMLStreamReader2 reader = null;
			try{
				URL sourceURL = uri.toURL();
				is = sourceURL.openStream(); 
				reader = (XMLStreamReader2)factory.createXMLStreamReader(is);
				while(reader.hasNext()) {
					reader.next();
					if(reader.isStartElement()) {
						String id = reader.getAttributeValue(null, Constants.ID);
						if(id!=null) {
							ret.add(id);
						}
					}
				} //while(reader.hasNext()) {	
			}catch (Exception e) {
				errors.add("[" + uri + "]" + e.getMessage());
			}finally{
				if(is!=null) try {is.close();} catch (IOException e) {}
				if(reader!=null) try {reader.close();} catch (XMLStreamException e) {}
			}						
			return ret;
		}
	}
	
	private boolean exists (URI uri, URLConnection uc, URI carrier) {
		
		try{						
			HttpURLConnection con = (HttpURLConnection) uc;
		    con.setRequestMethod("HEAD");							      
		    if (con.getResponseCode() == HttpURLConnection.HTTP_OK) {
		    	return true;
		    }else{
		    	errors.add("exists(): Not HTTP_OK ", uri, carrier);							
		    }		    
		}catch (Exception e) {
			errors.add("exists(): " + e.getMessage(), uri, carrier);
		}    		
		return false;
		
	}

	private URI stripFragment(URI uri) throws URISyntaxException {
		return new URI(uri.getScheme(), uri.getHost(), uri.getPath(), null);
	}

	private void initialize() throws CatalogExceptionNotRecoverable {
		factory = new WstxInputFactory();
		factory.setXMLResolver(CatalogEntityResolver.getInstance());
		factory.setProperty(XMLInputFactory2.SUPPORT_DTD, false);
		factory.setProperty(XMLInputFactory2.IS_VALIDATING, false);
	}
		
	public static void main(String[] args) throws Exception {
		new WebLinkChecker();
	}

	private void log(String string) {
		if(DEBUG) {
			System.out.println(string);
		}		
	}

	class Errors extends ArrayList<String> {
//		@Override
//		public boolean add(String message) {
//			String err = "[err] "+ message;
//			if(DEBUG)System.err.println(err);
//			return super.add(err);
//		}

		public boolean add(String message, URI uri, URI carrier) {
			String err = "[carrier: "+ carrier +"][bad: " + uri + "][message: " + message +"]";
			if(DEBUG)System.err.println(err);
			return super.add(err);
		}
	}
}
