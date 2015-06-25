package guizilla.gui;
import javax.swing.*;
/**
 * Constructs a paragraph as found in a form
 * @author awarstad and kj13
 *
 */
public class FormStuffParagraph extends FormStuff {
	
	Paragraph paragraph;
	FormStuff formStuff;
	
	/**
	 * makes a paragraph within a form.
	 * @param paragraph - the paragraph
	 * @param formStuff - the formstuff following this new paragraph
	 */
	public FormStuffParagraph(Paragraph paragraph, FormStuff formStuff) {
		this.paragraph = paragraph;
		this.formStuff = formStuff;
	}
	@Override
	public String getDaughters() {
		return this.formStuff.getDaughters();
	}
	@Override
	public void click(Browser b) {
	}
	
	@Override
	public void GUIrender(JPanel display) {
		this.paragraph.GUIrender(display);
		this.formStuff.GUIrender(display);
	}

}
