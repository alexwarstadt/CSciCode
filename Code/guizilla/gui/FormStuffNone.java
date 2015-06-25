package guizilla.gui;
import javax.swing.*;
/**
 * A holder for the form close tag
 * @author awarstad and kj13
 *
 */
public class FormStuffNone extends FormStuff {
	
	/**
	 * constrcuts a formStuffNone which denotes the end of the form.
	 */
	public FormStuffNone() {
	}


	@Override
	public String getDaughters() {
		return "";
	}

	@Override
	public void click(Browser b) {
	}

	@Override
	public void GUIrender(JPanel display) {
	}

}
