package guizilla.gui;
import javax.swing.*;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.io.*;
import java.net.URLEncoder;


/**
 * class marking an input tag and containing rest of the form
 * @author awarstad and kj13
 *
 */
public class FormStuffInput extends FormStuff {
	
	String name;
	FormStuff formStuff;
	int count;
	private JTextField input;
	
	/**
	 * constructs an input field
	 * @param name - the name assigned to this input field from html
	 * @param formStuff - all formstuff following this field
	 * @param count - the index assigned to this field in the fields arrayList held in HTMLparse
	 */
	public FormStuffInput(String name, FormStuff formStuff, int count) {
		this.name = name;
		this.formStuff = formStuff;
		this.count = count;
		this.button = new JButton("");
		this.input = new JTextField("Type your input here..");
		this.input.setSize(50, 20);
	}
	
	
	/**
	 * receives the string input and updates the associated field
	 * @param input - the string input by user.
	 */
	/*public void enterInput(String input) {
		this.input = input;
	}*/
	
	
	
	
	@Override
	public String getDaughters() {
		String toReturn = "";
		try {
			toReturn = URLEncoder.encode(this.name, "UTF-8") + "=" + URLEncoder.encode(this.input.getText(), "UTF-8") + "&";
			System.out.println(this.name + this.input.getText());
		} catch (UnsupportedEncodingException e) {
			System.out.println("URL encoder error.");
		}
		toReturn += this.formStuff.getDaughters();
		return toReturn;
	}

	@Override
	public void click(Browser b) {
		/*System.out.print("Input value for field " + name + ":");
		BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
		try {
			String inputValuenter a urle = r.readLine().trim();
			this.input = inputValue;
			System.out.println("You have just put " + this.input + " in the field " + this.name);
		} catch (IOException e) {
			System.out.println("IOException from input");
		}*/
	}


	@Override
	public void GUIrender(JPanel display) {
		
		JPanel p = new JPanel();
		//p.setPreferredSize(new Dimension(100,20));
		p.setLayout(new BoxLayout(p, BoxLayout.X_AXIS));
		
		JTextArea name = new JTextArea(this.name);
		name.setEditable(false);
		//name.setPreferredSize(new Dimension(100,20));
		//this.input.setPreferredSize(new Dimension(100,20));
		display.add(name);
		display.add(this.input);
		
		display.add(p);
		
		this.formStuff.GUIrender(display);
		
	}

}
