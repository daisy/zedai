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

	private static final String wwwURI = "http://www.daisy.org/z3986/2010/";
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
			checkURI(URI.create(localhostURI));
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
		
	private void checkURI(URI uri) throws Exception {
		
		if(!uri.isAbsolute()) throw new IllegalStateException(uri.toString() + " not absolute");
		
		String uriString = uri.toString();
		if(uriString.startsWith(wwwURI)) {			
			uri = URI.create(uriString.replace(wwwURI, localhostURI));
			uriString = uri.toString();			
		}
		
		if(uri.getHost().equals("localhost")) {
			log("checking uri " + uriString);
			try {		
				//check the resource
				URI resource = stripFragment(uri);					
				if(!checkedURIs.contains(resource.toString())) {	
					checkedURIs.add(resource.toString());		
					i++;
					URLConnection uc = uri.toURL().openConnection();					
					if(exists(uri, uc)) { 
						String mime = uc.getContentType();					
						if(mime.startsWith("text/html") || mime.startsWith("application/xhtml+xml")) {	
							iterate(resource);				
						}
					}
				}
				
				//check the URI fragment if any
				if(uri.getFragment()!=null && !checkedURIs.contains(uriString)) {		
					checkedURIs.add(uriString);
					i++;
					checkFragment(uri);
				}	
				
			}catch (Exception e) {
				errors.add(e.getMessage(), uri);
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
						checkURI(link);
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
	
	private void checkFragment(URI uri) throws Exception {
		URI resource = stripFragment(uri);
		String fragment = uri.getFragment();		
		Set<String> ids = idMap.get(resource);
		if(!ids.contains(fragment)) {
			errors.add("ID '" + fragment + "' missing", uri);
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
	
	private boolean exists (URI uri, URLConnection uc) {
		
		try{						
			HttpURLConnection con = (HttpURLConnection) uc;
		    con.setRequestMethod("HEAD");							      
		    if (con.getResponseCode() == HttpURLConnection.HTTP_OK) {
		    	return true;
		    }else{
		    	errors.add("Not HTTP_OK ", uri);							
		    }		    
		}catch (Exception e) {
			errors.add(e.getMessage(), uri);
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
		@Override
		public boolean add(String message) {
			String err = "[err] "+ message;
			if(DEBUG)System.err.println(err);
			return super.add(err);
		}

		public boolean add(String message, URI uri) {
			String err = "[err][" + uri.toString() + "] " + message;
			if(DEBUG)System.err.println(err);
			return super.add(err);
		}
	}
}
