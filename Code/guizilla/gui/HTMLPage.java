package guizilla.gui;

import javax.swing.*;
/**
 * The entire HTMLPage
 * @author awarstad and kj13
 *
 */
public class HTMLPage implements Render{
	Body body;
	/**
	 * Constructs the HTMLPage
	 * @param body - the entire body within the html tags.
	 */
	public HTMLPage(Body body){
		this.body = body;
	}
	
	
	
	@Override
	public void GUIrender(JPanel display) {
		this.body.GUIrender(display);
	}
}
