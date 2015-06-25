package guizilla.gui;
import javax.swing.*;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.util.ArrayList;
/**
 * This is where user inputs and all classes are managed: all functionality of SparkZilla operates from this class.
 * @author awarstad and kj13
 *
 */

//DEAL WITH CONTROL D INPUT - CLOSES BUFFEREDREADER
public class Browser {


	private boolean running;

	private ArrayList<HTMLParse> cache;

	private HTMLParse currentPage;

	private Client client;
	
	public JFrame window;
	
	private JTextField urlBar;
	

	/**
	 * constructs a new browser
	 */
	public Browser(){
		this.running = true;
		this.cache = new ArrayList<HTMLParse>();
		client = new Client();
		this.window = new JFrame("GUIzilla");
		this.window.setLayout(new BorderLayout());
		this.window.setSize(500,500);
		this.startPage();
	}
	
	
	
	private void makeWindow(){
		
		this.window.getContentPane().removeAll();
		
		JButton back = new JButton("back");
		back.addActionListener(new BackButton(this));
		
		JButton quit = new JButton("quit");
		quit.addActionListener(new QuitButton(this));
		
		this.urlBar = new JTextField("enter a url");
		this.urlBar.setLayout(new GridLayout());
		this.urlBar.setPreferredSize(new Dimension(400, 20));
		JButton urlGo = new JButton("go");
		urlGo.addActionListener(new URLButton(this));
		
		JPanel navBar = new JPanel(new FlowLayout());
		navBar.add(back);
		navBar.add(quit);
		navBar.add(this.urlBar);
		navBar.add(urlGo);
		
		this.window.add(navBar, BorderLayout.NORTH);
		this.window.pack();
	}
	
	
	
	private void startPage(){
		this.makeWindow();
		JTextArea welcome = new JTextArea("Welcome to GUIzilla!");
		welcome.setEditable(false);
		welcome.setPreferredSize(new Dimension(700,500));
		this.window.add(welcome, BorderLayout.CENTER);
		this.window.setVisible(true);
		this.window.pack();
	}
	
	



	
	



	
	
	/**
	 * goes to previous page in cache
	 */
	private void GUIback() {
		if (cache.size() != 0 && currentPage != null){
			
			int current = this.cache.indexOf(currentPage);
			this.cache.remove(current);
			if (current == 0){
				this.currentPage = null;
				this.startPage();
			} else {
				this.currentPage = cache.get(current -1);
				this.client.host = this.currentPage.host;
				this.GUIrender();
			}
		} else {
			this.startPage();
			JTextArea error = new JTextArea("This is the first page in the cache. You can't go back.");
			error.setEditable(false);
			this.window.add(error, BorderLayout.SOUTH);
			this.window.pack();
		}
	}





	
	private void GUIquit() {
		this.window.dispose();
		this.running = false;
		System.exit(0);
	}


	


	
	
	
	/**
	 * manages user input for entering url, and checks for valid url format
	 * @return a string corresponding to inputted url
	 */
	private String GUIgetURL() {
		String url = null;
		try {
			url = this.urlBar.getText();
			url.trim();
			if(url.length() < 8 || !url.substring(0, 7).equals("http://")) {
				this.urlBar.setText("Not a valid URL. Please try again.");
				url = null;
			}
		} catch (NullPointerException e) {
			this.urlBar.setText("There was a problem getting the URL.");
		}
		return url;
	}

	/**
	 * constructs a parse object out with the server response to the page request sets equal to current page
	 * @param url the user-inputted string corresponding to url
	 */
	private void newURL(String url) {
		URL newURL = new URL(url);
		String html = client.connectGet(newURL);
		this.setCurrentPage(html, newURL.host);
	}
	
	/**
	 * gets a new page from link
	 * @param path the path stored in the link
	 */
	public void linkURL(String path) {
		String url = "http://"+ this.client.host + path;
		newURL(url);
	}



	/**
	 * submits form input to server
	 * @param index - the index of the form in forms arraylist containing the submit button
	 */
	public void submit(int index) {

		Form form = this.currentPage.forms.get(index);
		String action = form.action;
		String s = form.formStuff.getDaughters();
		String submitStuff = s.substring(0, s.length() - 1);
		String url = "http://"+ this.client.host + action;
		String html = this.client.connectPost(new URL(url), submitStuff);
		this.setCurrentPage(html, this.client.host);
	}
	
	
	
	/**
	 * parses html, adds to cache, sets equal to current page and renders
	 * @param html - the html string received from server after posting or getting
	 */
	private void setCurrentPage(String html, String host) {
		if (html != null) {
			HTMLParse htmlParse = new HTMLParse(html, host);
			
			try {
				
				htmlParse.parseHTMLPage();
				cache.add(htmlParse);
				this.currentPage = htmlParse;
				this.cache.add(currentPage);
			
				this.GUIrender();
				this.createListeners();
				
			} catch (ParseException e) {
				JTextArea welcome = new JTextArea("There was a problem parsing the response from the server.");
				welcome.setEditable(false);
				this.window.add(welcome, BorderLayout.CENTER);
				this.window.pack();
				this.client.host = this.client.lastHost;
			} catch (TokenMgrError e) {
				JTextArea welcome = new JTextArea("there was an error with the tokenizer.");
				welcome.setEditable(false);
				this.window.add(welcome, BorderLayout.CENTER);
				this.window.pack();
				this.client.host = this.client.lastHost;
			}
		} else {
			JTextArea welcome = new JTextArea("There was a problem getting a response from the server.");
			welcome.setEditable(false);
			this.window.add(welcome, BorderLayout.CENTER);
			this.window.pack();
			this.client.host = this.client.lastHost;
		}
	}
	
	
	
	
	
	
	
	private class ButtonActionListener implements ActionListener{
		
		private Browser browser;
		
		private Clickable clickable;
		
		private ButtonActionListener(Browser browser, Clickable clickable){
			this.browser = browser;
			this.clickable = clickable;
		}

		@Override
		public void actionPerformed(ActionEvent e) {
			this.clickable.click(browser);
			
		}
	}
	
	
	
	
	
	
	
	
	
	private void createListeners() {
		for(Clickable x : currentPage.fields) {
			x.button.addActionListener(new ButtonActionListener(this, x) {
			});
		}
	}
	
	
	
	
	
	
	
	private static class BackButton implements ActionListener {
		private Browser browser;
		private BackButton(Browser browser){
			this.browser = browser;
		}
		@Override
		public void actionPerformed(ActionEvent e) {
			browser.GUIback();
		}
	}
	
	private static class QuitButton implements ActionListener {
		private Browser browser;
		private QuitButton(Browser browser){
			this.browser = browser;
		}
		@Override
		public void actionPerformed(ActionEvent e) {
			browser.GUIquit();
		}
	}
	
	private static class URLButton implements ActionListener {
		private Browser browser;
		private URLButton(Browser browser){
			this.browser = browser;
		}
		@Override
		public void actionPerformed(ActionEvent e) {
			String url = browser.GUIgetURL();
			if (url != null){
				browser.newURL(browser.GUIgetURL());
			}
		}
	}
	
	
	
	private void GUIrender() {
		this.makeWindow();

		JPanel display = new JPanel();
		BoxLayout layout = new BoxLayout(display, BoxLayout.Y_AXIS);
		display.setLayout(layout);
		display.setPreferredSize(new Dimension(700, 500));
		this.currentPage.htmlPage.GUIrender(display);
		display.setPreferredSize(new Dimension(700, 500));
		JScrollPane scroll = new JScrollPane(display, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
		scroll.createVerticalScrollBar();
		scroll.setPreferredSize(new Dimension(700, 500));

		window.add(scroll, BorderLayout.CENTER);
		window.pack();
		window.setVisible(true);
		
		
	}
	
	
	/*private void fileTest() {
		try {
		System.out.println("Enter a file: ");
		String file = this.userInput.readLine();
		BufferedReader r = new BufferedReader(new FileReader(file));
		String current = r.readLine();		
		String html = "";
		while (current != null) {
			html += current;
			current = r.readLine();
		}
		System.out.println(html);
		r.close();
		setCurrentPage(html);
		
		} catch (IOException e){
			System.out.println("IOE");
		}
	}*/






	/**
	 * constructs an instance of browser and runs until quit
	 * @param args - none
	 */
	public static void main(String[] args) {

		Browser b = new Browser();

		while(b.running) {
		}


	}

}
