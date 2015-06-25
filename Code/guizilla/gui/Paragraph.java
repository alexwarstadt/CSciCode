package guizilla.gui;
import javax.swing.*;
/**
 * The information between the paragrpah tags
 * @author awarstad and kj13
 *
 */
public class Paragraph implements Render{

	ParaStuff paraStuff;
	/**
	 * Constructs a new paragraph
	 * @param paraStuff - the information inside the paragraph tags
	 */
	public Paragraph(ParaStuff paraStuff) {
		this.paraStuff = paraStuff;
	}


	
	@Override
	public void GUIrender(JPanel display) {
		this.paraStuff.GUIrender(display);
	}
}
