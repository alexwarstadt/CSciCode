package guizilla;
import java.util.Hashtable;


import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.*;
/**
 * 
 * @author awarstad and kj13
 *
 */
public class Server {

	private Hashtable<String, Page> cache;
	//BROWSER NEEDS TO BE PRESENTING ERROR PAGES --> CURRENTLY JUST PRINTS LINE
	//EX: WHEN THE SERVER SENDS A BAD REQUEST, BROWSER DOESN'T SHOW html


	private static final int PORT = 8080;
	private ServerSocket ss;

	Socket socket;
	/**
	 * initializes our server
	 * creates a serverSocket and a hashtable for our cache
	 */
	public Server(){
		try {
			this.ss = new ServerSocket(PORT);
			this.cache = new Hashtable<String, Page>();
		} catch (IOException e) {
			this.badRequest();
			//other ways to deal with ioexcpetion?
		}
	}

	/**
	 * connect 
	 * connect opens the socket and decides whether the request
	 * is a post or a get request, throwing an error otherwise
	 */
	public void connect(){
		try {
			while (true) {
				this.socket = ss.accept();
				BufferedReader r = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
				System.out.println("reader");

				String header = r.readLine();
				String received = "";

				if (header.substring(0, 3).equals("GET")){
					String[] stuff = new String[4];
					for(int i = 0; i < 4; i++){

						if(header != null ) {
							if (!header.equals("Host: cslab4b:8080")) {
								stuff[i] = header;
								received += header;
							} else {
								i--;
							}
							header = r.readLine();
						}
					}
					String[] toSend = new String[4];
					if(this.checkHeaders(stuff)) {
						for (int i = 0; i < 3; i++){
							toSend[i] = stuff[i];
						}
						this.get(toSend);
					} else {
						this.badRequest();
					}
				} else if (header.substring(0, 4).equals("POST")){
					/*String[] stuff = new String[12];
					for(int i = 0; i < 12; i++){
						stuff[i] = header;
						if(header != null) {
							received += header;
							header = r.readLine();
							System.out.println(header);
						}
					}
					String[] toSend = new String[12];
					if(this.checkHeaders(stuff)) {
						for (int i = 0; i < 12; i++){
							toSend[i] = stuff[i];
						}*/
					this.post(r, header);
					/*} else {
						this.badRequest();
					}*/
				} else {
					this.badRequest();
				}
				System.out.println("received:" + received);
				socket.shutdownOutput();
			}

		} catch (IOException e) {
			this.badRequest();
		}
	}
	/**
	 * checkHeaders checks if the header received from browser is valid
	 * @param received - the header request sent by the browser
	 * @return boolean - true if the request is in valid syntax and false otherwise
	 */
	/**
	 * checkHeaders checks if the header received from browser is valid
	 * @param received - the header request sent by the browser
	 * @return boolean - true if the request is in valid syntax and false otherwise
	 */
	private boolean checkHeaders(String[] received){

		boolean check = containsMatch(received, "(GET|POST) /.+ HTTP/1.[01]");
		check = check && containsMatch(received, "(Connection|Accept): .+");
		check = check && containsMatch(received, "(User-Agent|Accept): .+");
		System.out.println(check);
		return check;

	}




	private static boolean checkHeaders1(String[] received){

		boolean check = containsMatch(received, "(GET|POST) /.+ HTTP/1.[01]");
		check = check && containsMatch(received, "Connection: .+");
		check = check && containsMatch(received, "User-Agent: .+");

		return check;

	}

	private static boolean containsMatch(String[] received, String regexp){
		for (int i = 0; i < received.length; i++){
			if (received[i].matches(regexp)) {
				return true;
			}
		}
		return false;
	}


	public boolean member(String[] received, String look) {
		for(String r : received) {
			if(r.equals(look)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * get
	 * handles get requests, reflecting the desired page
	 * and sending this html to the send method.
	 * @param received - the entire header of the request received
	 */
	public void get(String[] received){
		System.out.println("recieved");
		String[] header = received[0].split(" ");
		String path = header[1];
		try{
			String html = this.reflect(path, new Hashtable<String, String>());
			this.send(null, html);
		}catch (ServerException e) {

		}


	}
	/**
	 * post
	 * checks last two lines of header
	 * to ensure valid post request
	 * then handles post requests, updating the hashtables
	 * and uses request to invoke proper method
	 * sending the desired html to the send method.
	 * @param received - the entire header of the request received
	 */
	public void post(BufferedReader r, String header){
		System.out.println("post");
		String received = "";
		String[] h = header.split(" ");
		String path = h[1];
		try {
		while (header != null && !header.matches("Content-Length.+")) {
			received += header;
			header = r.readLine();
			System.out.println(1+header);
		}
		while (header != null){
			received += header;
			header = r.readLine();
			System.out.println(2+header);
		}
		String[] contlen = header.split(" ");
		
			int cl = Integer.parseInt(contlen[1]);
			String inputs = "";
			for (int i = 0; i < cl; i++) {

				int y = r.read();
				if(y == -1) {
					this.badRequest();
					break;
					
				}
				inputs += (char)y;
			}
				String[] inputsArray = URLDecoder.decode(inputs, "UTF-8").split("&");

				Hashtable<String, String> table = new Hashtable<String, String>(inputsArray.length);
				for (String pair: inputsArray) {
					String[] kv = pair.split("=");
					System.out.println(pair);
					if (kv.length != 2){
						System.out.println("kv");
						this.badRequest();

						return;
					} else {
						table.put(kv[0], kv[1]);
					}
				}

				
				String html = this.reflect(path, table);

				this.send(null, html);
			
		} catch (NumberFormatException e) {
			this.badRequest();
			return;
		} catch (UnsupportedEncodingException e) {
			System.out.println("unsupported");
			this.badRequest();
			return;
		} catch (ServerException e) {

		} catch(IOException e) {
			this.badProcessing();
			return;
		}
		/*String[] line = received[3].split(" ");
		if(!line[0].equals("Content-Type:")){
			this.badRequest();
		} else {
			line = received[4].split(" ");
			if(!line[0].equals("Content-Length:")) {
				this.badRequest();
			} else {*/
		/*try{
			int cLength = Integer.parseInt(line[1]);
			//checks if the length of the string received
			//is less than the expected length
			if(received[6].length() < cLength) {
				this.badRequest();
			}
		} catch(NumberFormatException e) {
			this.badRequest();	
		}
		if(!received[5].equals("")){
			this.badRequest();
		} else {*/
		

		 
	}









	/**
	 * reflect initiates the reflection of the page requested by client
	 * @param path - the path which includes information on the desired class
	 * @param table - the hashtable to be sent to the new instances of the page that's being reflected
	 * @return the string of html to be sent back to the client
	 */
	public String reflect(String path, Hashtable<String, String> table) throws ServerException {
		System.out.println("reflect");
		path = path.trim();
		String newString = "";
		String[] topHeader = path.split("/");

		if(topHeader.length < 1) {
			this.badPath();
			throw new ServerException();
		}
		try {
			if(topHeader.length > 0) {
				String id = "";
				if (topHeader[1].length() > 3) {
					if (topHeader[1].substring(0,3).equals("id:")){
						id = topHeader[1].substring(3, topHeader[1].length());
						//NEED TO ASK WHAT TO DO WHEN HEADER ISN'T ID but has numbers
						// --> ALL requests shouldn't have id, but 
						//are invalid if are numbers and not id infront

						//} else {
						//	this.badRequest();
					}
				}
				System.out.println(id + "this is the id");
				Page pageInstance = null;
				if (id.length() == 0) {
					String title = topHeader[1];
					Class<?> page = Class.forName("guizilla."+title);
					pageInstance = (Page) page.newInstance();

				} else {
					if(cache.get(id) != null){
						System.out.println("made it to the cache");
						pageInstance = (Page) cache.get(id).clone();
					} else {
						System.out.println("id not in cache, null!!");
						this.badPath();
						throw new ServerException();
					}
				}
				String p = pageInstance.toString();
				String[] p2 = p.split("@");
				String newID = p2[1];

				cache.put(newID, pageInstance);
				Method pageMethod = null;
				if (topHeader.length == 3){ //will it ever be greater?

					pageMethod =  pageInstance.getClass().getMethod(topHeader[2], Hashtable.class, String.class);

				} else if (topHeader.length == 2) {
					System.out.println("default");
					pageMethod =  pageInstance.getClass().getMethod("defaultHandler", Hashtable.class, String.class);
				} else {
					this.badPath();
					throw new ServerException();
				}
				newString = (String) pageMethod.invoke(pageInstance, table, newID);


			} else {
				this.badPath();
				throw new ServerException();
			}
		} catch(ClassNotFoundException e) {
			//reacting to page not found
			this.badPath();
			throw new ServerException();
		} catch (IllegalAccessException e) {
			//reacting to page not being accessible
			this.badPath();
			throw new ServerException();
		} catch(InstantiationException e) {
			this.badPath();
			System.out.println(e.toString());
		} catch(NoSuchMethodException e) {
			//thrown by getMethod
			this.badPath();
			throw new ServerException();
		}catch(InvocationTargetException e) {
			//for invoke
			this.badPath();
			throw new ServerException();
		} catch (CloneNotSupportedException e) {
			this.badProcessing();
			throw new ServerException();
		} catch (SecurityException e) {
			//thrown by getMethod
			this.badPath();
			throw new ServerException();
		} catch (IllegalArgumentException e) {
			this.badPath();
			throw new ServerException();
		} if(newString == null) {
			this.badProcessing();
			throw new ServerException();
		}
		return newString;



	}






	/**
	 * gathers and writes the information that's to be sent to the client
	 * @param header - the header to be put in front of the html
	 * @param html - the html string to be linked to the header
	 */
	public void send(String header, String html){

		if (header == null){
			header = "HTTP/1.0 200 OK\r\nServer: Sparkserver/1.0" +
					"\r\nConnection: close"+"\r\nContent-Type: text/html\r\n" + "\r\n";
		} 
		String toSend = header + html;
		try {

			BufferedWriter w = new BufferedWriter(new OutputStreamWriter(this.socket.getOutputStream()));
			System.out.println("sending:" + toSend);
			w.write(toSend);
			w.flush();
		} catch(IOException e) {
			System.out.println("ioe");
			this.badProcessing();
			return;
		}

	}
	/**
	 * changes header to 400 bad request if the information in the header
	 * that's sent from client is invalid
	 */
	public void badRequest(){
		System.out.println("request");
		String samplePage = "<html><body><p>400 Bad Request</p></body></html>";

		String header = "HTTP/1.0 400 Bad Request\r\nServer: Sparkserver/1.0" +
				"\r\nConnection: close"+"\r\nContent-Type: text/html\r\n\r\n";

		this.send(header, samplePage);

	}
	/**
	 * changes header to 404 not found
	 * if the path received in the header is invalid
	 */
	public void badPath() {
		System.out.println("path");
		String samplePage = "<html><body><p>404 Not Found</p></body></html>";
		String header = "HTTP/1.0 404 Not Found\r\nServer: Sparkserver/1.0" +
				"\r\nConnection: close"+"\r\nContent-Type: text/html\r\n\r\n";
		this.send(header,samplePage);

	}

	/**
	 * changes the header to 500 if the processing
	 * of the desired page is interrupted
	 */
	public void badProcessing() {
		String samplePage = "<html><body><p>500 Internal Server Error</p></body></html>";
		String header = "HTTP/1.0 500 Internal Server Error\r\nServer: Sparkserver/1.0" +
				"\r\nConnection: close"+"\r\nContent-Type: text/html\r\n\r\n";
		this.send(header,samplePage);
	}


	/**
	 * gets the socket to begin waiting
	 * @param args
	 */
	public static void main(String[] args) {

		/*URLDecoder.decode(inputs, "UTF-8").split("&");
gzip,deflate,sdch
*/

		Server n = new Server();
		n.connect();
	}
}



//do we have to test with chrome? then do we have to ignore 100 headers?


