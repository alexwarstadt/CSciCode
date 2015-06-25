package guizilla.gui;
import javax.swing.*;
/**
 * the class which holds all text elements
 * @author awarstad and kj13
 *
 */
public class Text implements Render{
	String text;
	/**
	 * Constructs a text object which holds the text information.
	 * @param text - the string of text.
	 */
	public Text(String text) {
		this.text = text;
	}
	
	
	@Override
	public void GUIrender(JPanel display) {
		JTextArea displayText = new JTextArea(text);
		displayText.setEditable(false);
		display.add(displayText);
	}
	
	
}
