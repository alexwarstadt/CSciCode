package guizilla.gui;
import javax.swing.*;

/**
 * parent of forms in body.
 * @author awarstad and kj13
 *
 */
public class BodyStuffForm extends BodyStuff {
	Form form;
	BodyStuff bodyStuff;
	
	/**
	 * Creates a new form inside of the body using the form object
	 * while including the rest of the body after the form.
	 * @param form - a new form contained within.
	 * @param bodyStuff - all elements after this new form.
	 */
	public BodyStuffForm(Form form, BodyStuff bodyStuff) {
		this.form = form;
		this.bodyStuff = bodyStuff;
	
	}
	
	
	@Override
	public void GUIrender(JPanel display) {
		this.form.GUIrender(display);
		this.bodyStuff.GUIrender(display);
	}

}
