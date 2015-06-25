package guizilla.gui;
import javax.swing.*;

/**
 * parent class to all active elements
 * @author awarstad kj13
 *
 */
public abstract class Clickable {
	
	public JButton button;
	
	/**
	 * performs relevant actions when an active element is called by user
	 * @param b - the current state of the browser
	 */
	public abstract void click(Browser b);
	
	
}
