package guizilla;

import java.util.Hashtable;
import java.util.LinkedList;

public class Geoffs extends Page{
	private String bread;
	private String meat;
	private LinkedList<String> toppings;
	/**
	 * instantiates a LinkedList for toppings
	 */
	public Geoffs() {
		this.toppings = new LinkedList<String>();
	}
	/**
	 * defaultHandler
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return a string of html with the proper id, as given by the server
	 * the initial page that is rendered when this page is requested.
	 */
	@Override
	public String defaultHandler(Hashtable<String, String> t, String id) {
		return "<html><body><p>Sandwiches</p>" +
				"<form method=\"post\" action=\"/id:"+id+"/getMeat\">" + 
				"<p>Enter your desired meat</p>" +
				"<input type=\"text\" name=\"meat\" />"+
				"<input type=\"submit\" value=\"submit\" />"+
				"</form></body></html>";
	}
	/**
	 * getMeat
	 * the page seen after the form from above has been submitted
	 * updates the string fields based on the inputs from
	 * the user
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return updates the String fields that are changed by the user input
	 */
	public String getMeat(Hashtable<String, String> t, String id) {
		this.meat = t.get("meat"); 
		if (this.meat == null || this.meat.equals("_______")) {
			this.meat = "tofu";
		}
		return "<html><body><p>What kind of bread do you want on your " + 
		this.meat + " sandwich? </p><form method=\"post\" action=\"/id:"+
		id+"/finalize\">" + "<p>Enter your desired bread: </p>"+"<input type=\"text\" name=\"bread\"" +
		" />"+ "<p>Add some toppings!</p><input type=\"text\" name=\"toppings\"" +
		" />"+ "<input type=\"submit\" value=\"submit\" /></form></body></html>";

	}

	/**
	 * finalize
	 * the page seen after the form from above has been submitted
	 * updates the string fields based on the inputs from
	 * the user
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return updates the String fields that are changed by the user input
	 * and updates the LinkedList<String> that holds the toppings inputs
	 */
	public String finalize(Hashtable<String, String> t, String id) {
		this.bread = t.get("bread");
		String topping = t.get("toppings");
		if(topping == null || topping.equals("_______")) {
			topping = "anchovies";
		}
		this.toppings.add(topping);
		String tops = "";
		for(String elt: this.toppings) {

			tops += " " + elt;
			
		}
		if(this.bread == null || this.bread.equals("_______")) {
			this.bread = "wonderbread";
		}
		return "<html><body><p>You have built your sandwich!! You ordered " + 
		this.meat + " as your meat, " + this.bread + 
		" as your bread! These are your toppings: " + tops + " If you would like more" +
		"toppings, enter here: </p><form method=\"post\" action=\"/id:"+
		id+"/finalize\">"+"<input type=\"text\" name=\"toppings\" />" +
		"<input type=\"submit\" value=\"submit\" /></form></body></html>";

	}

	/**
	 * clones this geoff page and manually copies elements of the linkedlist
	 * to this newly cloned state.
	 * @return returns a new state of this geoff page
	 * 
	 */
	@Override
	public Geoffs clone() throws CloneNotSupportedException {
		System.out.println(this.toppings.size());
		Geoffs newGeoffs = (Geoffs) super.clone();
		newGeoffs.toppings = new LinkedList<String>();
		System.out.println(this.toppings.size());
		if(this.toppings.size() > 0) {
		for (String elt : this.toppings){
			newGeoffs.toppings.add(elt);
		}
		}
		return newGeoffs;

	}



}
