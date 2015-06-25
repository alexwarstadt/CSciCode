package guizilla.gui;
import javax.swing.*;
/**
 * The class marking a link inside of a paragraph
 * @author awarstad and kj13
 *
 */
public class ParaStuffLink extends ParaStuff {

	Link link;
	ParaStuff paraStuff;
	/**
	 * constructs a paraStuffLink object
	 * @param link - the link inside of the paragraph
	 * @param paraStuff - the paragraph information following the link.
	 */
	public ParaStuffLink(Link link, ParaStuff paraStuff) {
		this.link = link;
		this.paraStuff = paraStuff;
	}
	
	@Override
	public void GUIrender(JPanel display) {
		this.link.GUIrender(display);
		this.paraStuff.GUIrender(display);
	}
	
}
