package guizilla;

import java.util.Hashtable;
/**
 * sample page with a form
 * @author awarstad and kj13
 *
 */
public class Shop extends Page{
	
	private String firstName;
	private String lastName;
	private String number;
	private String antique;
	
	public Shop() {
	    
	}
	/**
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return a string of html with the proper id, as given by the server
	 * the initial page that is rendered when this page is requested.
	 */
	@Override
	public String defaultHandler(Hashtable<String, String> inputs, String id) {
	return "<html><body><p>Welcome to Kim's Antiques!</p><p>Thanks for visiting us! " +
			"We hope that you'll be able to find all the antiques you could imagine! " +
			"Please enter your name, number, and what antique you're searching for in the form below:" +
			"</p>"+"<form method=\"post\" action=\"/id:"+id+"/getAntique\">" + 
			"<p>Enter your first name: </p>"+"<input type=\"text\" name=\"first\" />"+
			"<p>Enter your last name: </p>"+"<input type=\"text\" name=\"last\" />"+  
			"<p>Enter your number: </p>"+"<input type=\"text\" name=\"number\" />"+ 
			"<p>Enter your desired antique: </p>"+"<input type=\"text\" name=\"antique\" />"+ 
			"<input type=\"submit\" value=\"submit\" />"+"</form></body></html>";
	}

	/**
	 * getAntique
	 * the page seen after the form from above has been submitted
	 * updates the string fields based on the inputs from
	 * the user
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return the html string that represents a page that includes the input information
	 */
	public String getAntique(Hashtable<String, String> t, String id) {
	        this.firstName = t.get("first");
	        this.lastName = t.get("last");
	        this.number = t.get("number");
	        this.antique = t.get("antique"); 
	        if(this.firstName == null || this.firstName.equals("Type your input here..")) {
	        	this.firstName = "Mike";
	        	
	        }
	        if(this.lastName == null || this.lastName.equals("Type your input here..")) {
	        	this.lastName = "Wazowski";
	        }
	        if (this.number == null || this.number.equals("Type your input here..")) {
	        	this.number = "555.555.5555";
	        }
	        if (this.antique == null || this.antique.equals("Type your input here..")) {
	        	this.antique = "bench";
	        }
	        return "<html><body><p>Great! Thanks, " + firstName + " " + lastName + "! we'll be searching for " + 
	        		antique + " and will give you a call at " + number + 
	        		" when we find something we think you'll like!</p><p>Have a great day!</p>" +
	        		"</body></html>";

	}
	/**
	 * clone
	 * creates a new sate of this page instance
	 */
	@Override
	public Shop clone() throws CloneNotSupportedException{
		Shop toReturn = (Shop) super.clone();
		return toReturn;
	}

}
