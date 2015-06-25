package guizilla.gui;
import javax.swing.*;
/**
 * the class which prepares a url for the client.
 * @author awarstad and kj13
 *
 */
public class URL {

	String host;
	String path;
	/**
	 * Constructs a url
	 * @param url - the string of the complete url as received by the user.
	 */
	public URL(String url) {
		url = url.substring(6);
		String[] getHost = url.split("/");
		this.host = getHost[1];
		this.path = url.substring(this.host.length() + 1, url.length());
		
		
		
	}
	
}
