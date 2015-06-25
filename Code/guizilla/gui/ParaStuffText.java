package guizilla.gui;
import javax.swing.*;
/**
 * The class denoting text within paragraph tags.
 * @author awarstad and kj13
 *
 */
public class ParaStuffText extends ParaStuff {

	Text text;
	ParaStuff paraStuff;
	/**
	 * Constructs a paraStuffText element which holds the text in a paragraph
	 * @param text - the text within the paragraph tags
	 * @param paraStuff - the paraStuff elements which follow the text.
	 */
	public ParaStuffText(Text text, ParaStuff paraStuff) {
		this.text = text;
		this.paraStuff = paraStuff;
	}


	@Override
	public void GUIrender(JPanel display) {
		this.text.GUIrender(display);
		this.paraStuff.GUIrender(display);
	}
	
	
	
	
}
