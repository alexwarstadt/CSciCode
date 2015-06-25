package guizilla.gui;

import javax.swing.*;
/**
 * Creates paragraphs inside the body.
 * @author awarstad and kj13
 *
 */
public class BodyStuffParagraph extends BodyStuff {
	Paragraph paragraph;
	BodyStuff bodyStuff;
	
	/**
	 * Creates a new paragraph and bodyStuff that follows.
	 * @param paragraph - the new paragraph to be created.
	 * @param bodyStuff - the body elements following this new paragraph.
	 */
	public BodyStuffParagraph(Paragraph paragraph, BodyStuff bodyStuff) {
		this.paragraph = paragraph;
		this.bodyStuff = bodyStuff;
	}
	@Override
	public void GUIrender(JPanel display) {
		this.paragraph.GUIrender(display);
		this.bodyStuff.GUIrender(display);
	}
	

}
