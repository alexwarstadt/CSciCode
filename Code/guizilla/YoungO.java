package guizilla;

import java.util.Hashtable;

public class YoungO extends Page{
	/**
	 * @param inputs - the hashtable of strings with kV pairs 
	 * that represent the input fields
	 * @param id - the id that correlates to this page
	 * @return a string of html with the proper id, as given by the server
	 * the initial page that is rendered when this page is requested.
	 */
	@Override
	public String defaultHandler(Hashtable<String, String> inputs, String id) {
	    return     "<html><body><p>Welcome to Young Orchard!</p>" +
	    		"<p>These incredible apartment-style dorms cater to all " +
	    		"your college needs! The kitchen is fully equipped with a fridge, " +
	    		"an oven, and storage space. You can entertain in the common room and " +
	    		"hang on to the option of retreating to your own private space. Yep, Young Orchard " +
	    		"has it all! Each member will have a single. Livin the dream!</p></body></html>";
	    }
	/**
	 * clone
	 * creates a new sate of this page instance
	 */
	@Override
	public YoungO clone() throws CloneNotSupportedException {
		YoungO toReturn = (YoungO) super.clone();
		return toReturn;
	}

}
