package guizilla.gui;
import javax.swing.*;

/**
 * all the html within form tags
 * @author awarstad and kj13
 *
 */
public class Form implements Render{
	
	String action;
	FormStuff formStuff;
	int index;
	
	/**
	 * constructs a from
	 * @param action - the link assigned to the form for submitting
	 * @param formStuff - all the stuff after the open tag
	 * @param index - the index of the form in forms arrayList held in HTMLParse
	 */
	public Form(String action, FormStuff formStuff, int index) {
		this.action = action;
		this.formStuff = formStuff;
		this.index = index;
	}


	@Override
	public void GUIrender(JPanel display) {
		this.formStuff.GUIrender(display);
	}
	
	

}
