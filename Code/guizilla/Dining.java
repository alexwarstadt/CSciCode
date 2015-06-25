package guizilla;

import java.util.Hashtable;

public class Dining extends Page{
	/**
	 * defaultHandler
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return a string of html with the proper id, as given by the server
	 * the initial page that is rendered when this page is requested.
	 */
	@Override
	public String defaultHandler(Hashtable<String, String> inputs, String id) {
		return "<html><body><p>Thank you for visiting the Dining room homePage!</p>" +
				"<p>You've come to the right guide for all of your dining dreams at Brown</p> " +
				"<p>Please feel free to browse between sites as you decide which place will " +
				"best quench your hunger. The first place on our tour is <a href=\"/Dining/Ratty\"> " +
				"The Ratty</a> which is located on Wriston Quad. Please press the link to " +
				"view more on the ratty. Our tour will continue as you navigate through these pages." +
				"</p></body></html>";
		}
	/**
	 * Ratty
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return a string of html which represents this method as a page
	 */
		public String Ratty(Hashtable<String, String> inputs, String id) {
		return "<html><body><p>Welcome to the Ratty!</p><p>The Ratty is a hub of food with " +
				"cereal galore, steamed veggies for days, and a hearty salad bar. " +
				"Take a trip around all of the sections before committing to one part. " +
				"You don't want to miss anything! </p><p>Be sure to check out the " +
				"<a href=\"/Dining/IvyRoom\"> Ivy Room</a> which is located just below the Ratty, " +
				"in case you're feeling particularly fancy. </p></body></html>";
		}
		/**
		 * IvyRoom
		 * @param inputs - the hashtable of strings with kV pairs 
		 * that represent the input fields
		 * @param id - the id that correlates to this page
		 * @return a string of html which represents this method as a page
		 */
		public String IvyRoom(Hashtable<String, String> inputs, String id) {
		return "<html><body><p>Welcome to the Ivy Room!</p><p>Get excited for some groovy 70s " +
				"decorations! You'll miss your bellbottoms out here with all of the teal blues " +
				"and faded red-oranges. The wood panels make this cozy place feel like you're in " +
				"a woodsy haven. When you're ready, head for the smoothies or maybe some mac and " +
				"cheese. There's everything your snacking heart could desire down here. There are " +
				"so many vegetarian options, but vegans beware. There might not be enough to fuel " +
				"your long study nights, but never fear for <a href=\"/Dining/BlueRoom\">The Blue " +
				"Room</a> isn't too far from here.</p></body></html>";
		}
		/**
		 * BlueRoom
		 * @param inputs - the hashtable of strings with kV pairs 
		 * that represent the input fields
		 * @param id - the id that correlates to this page
		 * @return a string of html which represents this method as a page
		 */
		public String BlueRoom(Hashtable<String, String> inputs, String id) {
		return "<html><body><p>You made it to The Blue Room! Glad to have you here!</p>" +
				"<p>The blue room has everything you could ever need: yogurt parfaits, sandwiches, " +
				"naked burritos, and of course, Kabob and Curry. Need some coffee? So many " +
				"choices are at your finger tips! We've got cappuccinos, lattes, tea, and espresso " +
				"in case you're in dire need of a boost. Whatever you need, get excited because " +
				"the Blue Room is the answer to your wildest dreams!</p></body></html>";
		}
		/**
		 * clone
		 * creates a new sate of this page instance
		 */
		@Override
		public Dining clone() throws CloneNotSupportedException{
			Dining toReturn = (Dining) super.clone();
			return toReturn;
		}


}
