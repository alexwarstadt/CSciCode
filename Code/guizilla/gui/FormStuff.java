package guizilla.gui;

/**
 * parent class for all the stuff within a form
 * @author awarstad and kj13
 *
 */
public abstract class FormStuff extends Clickable implements Render{
	
	/**
	 * collects all the inputted data from entire form
	 * @return a string containing all that data packaged with &s and encoded
	 */
	public abstract String getDaughters();

}
