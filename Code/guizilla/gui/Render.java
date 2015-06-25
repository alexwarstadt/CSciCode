package guizilla.gui;
import javax.swing.*;
/**
 * The interface which allows each HTML element to be rendered.
 * @author awarstad and kj13
 *
 */
public interface Render {
	
	/**
	 * this method is unique for each node in the parse tree.
	 * it displays a representation of that node in the GUI.
	 */
	public void GUIrender(JPanel display);
}
