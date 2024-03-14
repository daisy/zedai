package org.daisy.z3998.n3;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.daisy.z3998.xom.XOMUtil;

public class N3Modifier {
	boolean dropJena = false;
	boolean dropWikiLinks = false;
	boolean modifyDate = false;
	boolean dateModified = false;
	
	public N3Modifier(String[] args) throws Exception {
		
		File input = new File(args[0]);
		File output = new File(args[1]);
		
		BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(input), Charset.forName("UTF-8")));
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(output), Charset.forName("UTF-8")));
		
		modifyDate = args[2].equals("true");
		dropJena = args[3].equals("true");
		dropWikiLinks = args[4].equals("true");
		
		String line;		
		while((line = reader.readLine())!=null) {
			String modified = handle(line);
			if(modified!=null) {
				writer.write(modified);
				writer.newLine();
			}
		}
		writer.flush();
		writer.close();
		reader.close();
	}

	/**
	 * Modify Notation3 based files. Requires that each n3 statement occurs on its own line
	 * Arguments:
	 * <ul>
	 * <li>0: input n3 file</li>
	 * <li>1: output n3 file</li>
	 * <li>2: Whether to rewrite first occurrence of a dcterms:date line using current time ('true'|'false')</li>
	 * <li>3: Whether to filter out all lines starting with "jena:" ('true'|'false')</li>
	 * </ul>
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		new N3Modifier(args);		
	}
	
	private String handle(String line) {
		if(dropJena && line.trim().startsWith("jena:")) {
			return null;
		}
		String ret = line;
		if(modifyDate && !dateModified && line.trim().startsWith("dcterms:date")) {
			dateModified = true;
			String date = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ").format(Calendar.getInstance().getTime());
			ret = "  dcterms:date \"" + date + "\" ;";
		}
		if(dropWikiLinks && line.contains("[[")) {
						
			//force each [[ to occur on its own line
			String mline = line.replace("[[", "\n[[");
			
			StringBuffer buffer = new StringBuffer();
			Pattern pattern = Pattern.compile("\\[{2}.+\\]{2}");
			Matcher matcher = pattern.matcher(mline);
			while (matcher.find()) {						
			    matcher.appendReplacement(buffer, replace(matcher.group()));			  
			}
			matcher.appendTail(buffer);
			ret = buffer.toString().replace("\n", "");
		}
		return ret.replaceAll("\t", " ");
	}

	private String replace(String group) {		
		//we get either [[(#)link label]]
		//or [[(#)link label with spaces]]
		//or [[(#)link]]
		
		String value = XOMUtil.stripWikiSyntax(XOMUtil.prepWikiLinkString(group));
		
		String linkValue = value;
		String labelValue = null;					
		int point = value.indexOf(' ');
		if (point > 0) { 
			linkValue = value.substring(0, point);
			labelValue = value.substring(point+1);
		}			
		return (labelValue!=null) ? labelValue + "(" + linkValue + ")" : linkValue;
	}
	
}
