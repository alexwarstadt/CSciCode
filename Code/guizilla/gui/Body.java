package guizilla.gui;

import javax.swing.*;
/**
 * A Body object encapsulates everything inside the body tags.
 * @author awarstad and kj13
 *
 */
public class Body implements Render{
	BodyStuff bodyStuff;
	
	
	/**
	 * constructs a new body object with the rest of the body to follow
	 * @param bodyStuff
	 */
	public Body(BodyStuff bodyStuff){
		this.bodyStuff = bodyStuff;
	}


	@Override
	public void GUIrender(JPanel display) {
		this.bodyStuff.GUIrender(display);
	}

}
