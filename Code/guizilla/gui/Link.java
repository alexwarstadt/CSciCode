package guizilla.gui;
import javax.swing.*;
/**
 * The information between the link tags.
 * @author awarstad and kj13
 *
 */
public class Link extends Clickable implements Render{
	String href;
	Text text;
	int counter;

	/**
	 * Creates a link element
	 * @param href - the url associated with the link element
	 * @param text - the text held inside of the link element
	 * @param counter - the index of the link in the field arrayList
	 */
	public Link(String href, Text text, int counter) {
		this.href = href;
		this.text = text;
		this.counter = counter;
		this.button = new JButton(this.text.text);
	}


	@Override
	public void click(Browser b) {
		b.linkURL(href);
	}

	
	
	@Override
	public void GUIrender(JPanel display) {
		display.add(this.button);
	}
	
}
