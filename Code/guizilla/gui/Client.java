package guizilla.gui;
import java.io.*;
import java.net.Socket;

/**
 * connects to server and receives server response
 * @author awarstad and kj13
 *
 */
public class Client {

	private static final int PORT = 8080;

	String host;

	Socket s;
	
	String lastHost;

	/**
	 * constructs a new client
	 */
	public Client() {
	}





	/**
	 * receives server response to client
	 * @return a string of html
	 */
	public String getResponse() {
		String html = null;
		try {
			BufferedReader r = new BufferedReader(new InputStreamReader(this.s.getInputStream()));
			String header = r.readLine();
			if (!header.substring(9, 12).equals("200")){
				System.out.println("Path cannot be found");
			} else {

				int i = r.read();
				while (i != -1){
					html += (char) i;
					i = r.read();
					
				}
				s.shutdownInput();
				r.close();
			}
		} catch (IOException e) {
			System.out.println(e.toString());
			System.out.println("There was a problem receiving server output.");
		}
		return html;
	}





	/**
	 * connects to server with GET header
	 * @param url - the url sent from the browser
	 * @return the html response from the server
	 */
	public String connectGet(URL url) {
		String html = null;
		try {
			this.lastHost = this.host;
			this.host = url.host;
			this.s = new Socket(this.host, PORT);

			BufferedWriter w = new BufferedWriter(new OutputStreamWriter(s.getOutputStream()));
			w.write("GET " + url.path + " HTTP/1.0\r\n");
			w.write("Connection: close\r\n");
			w.write("User-Agent: Sparkzilla/1.0\r\n");
			w.write("\r\n");
			w.flush();
			s.shutdownOutput();
			html = this.getResponse();
			w.close();
		} catch (IOException e) {
			System.out.println("host not found.");
		}
		return html;
	}





	/**
	 * connects to server with POST header
	 * @param url - the url sent from the browser
	 * @param formData - a string encapsulating inputted form data, in good header format with &s
	 * @return server response html string
	 */
	public String connectPost(URL url, String formData) {
		String html = null;
		try {
			this.lastHost = this.host;
			this.host = url.host;
			this.s = new Socket (host, PORT);
			BufferedWriter w = new BufferedWriter(new OutputStreamWriter(s.getOutputStream()));
			w.write("POST " + url.path + " HTTP/1.0\r\nConnection: close\r\nUser-Agent: Sparkzilla/1.0\r\n" +
					"Content-Type: application/x-www-form-urlencoded\r\nContent-Length: " + 
					formData.length() + "\r\n\r\n" + formData + "\r\n");
			w.flush();
			s.shutdownOutput();
			html = this.getResponse();
			w.close();
		} catch (IOException e) {
			System.out.println("there was a problem with getting connected to the socket while posting");
			System.out.println(e.toString());
		}
		return html;
	}



}


