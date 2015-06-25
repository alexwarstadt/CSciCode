package guizilla.gui;

import javax.swing.*;

/**
 * The submit button associated with a form
 * @author awarstad and kj13
 *
 */
public class FormStuffSubmit extends FormStuff {
	
	FormStuff formStuff;
	int count;
	int index;

	
	/**
	 * Constructs the submit button
	 * @param formStuff - The formstuff following the submit button
	 * @param count - The index of the button in the fields arrayList
	 * @param index - the index of the associated form in the forms arrayList
	 */
	public FormStuffSubmit(FormStuff formStuff, int count, int index) {
		this.formStuff = formStuff;
		this.count = count;
		this.index = index;
		this.button = new JButton("Submit");
	}
	@Override
	public String getDaughters() {
		return this.formStuff.getDaughters();
	}
	
	@Override
	public void click(Browser b) {
		b.submit(this.index);
	}
	
	
	
	@Override
	public void GUIrender(JPanel display) {
		display.add(this.button);
		this.formStuff.GUIrender(display);
	}

}
