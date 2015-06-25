package guizilla.gui;
import javax.swing.*;

import java.util.ArrayList;
import java.io.*;
/**
 * Parse object that is the parse tree and arrays containing active elements and forms
 * @author awarstad and kj13
 *
 */

public class HTMLParse {
	
	HTMLTokenizer htmlT;
	int counter;
	ArrayList<Clickable> fields;
	int index;
	ArrayList<Form> forms;
	HTMLPage htmlPage;
	String host;
	
	/**
	 * Constructs the HTMLParse object
	 * @param html - the string of html to be parsed.
	 */
	public HTMLParse(String html, String host) {
		this.htmlT = new HTMLTokenizer(new BufferedReader(new StringReader(html)));
		this.counter = 0;
		this.fields = new ArrayList<Clickable>();
		this.index = 0;
		this.forms = new ArrayList<Form>();
		this.host = host;
	}
	
	
	

	/**
	 * checks the type of the token is equal to the requested type. also advances to the next token.
	 * @param constant - the value of the expected type of the token.
	 * @return - true if the constant matches the type of the token.
	 */
	public boolean eatToken(int constant) {
		Token t = this.htmlT.current();
		if (t.getKind() == constant) {
			this.htmlT.advance();
			return true;
		} else {
			return false;
		}
	}

	
	
	
	
	/**
	 * parses the HTMLPage and constructs a new HTMLPage
	 * @return - the newly constructed HTMLPage
	 * @throws ParseException
	 */
	public HTMLPage parseHTMLPage() throws ParseException {
		
		HTMLPage toReturn;
		this.htmlT.advance();
		this.htmlT.advance();

		
		if (this.eatToken(HTMLConstants.OPENHTML)) {
			toReturn = new HTMLPage(this.parseBody());
			
			if (!this.eatToken(HTMLConstants.CLOSEHTML)) {
				throw new ParseException("html page must have </html>");
				
			} if (!this.eatToken(HTMLConstants.EOF)) {
				throw new ParseException("html page must have EOF");
			}
			
		} else {
			throw new ParseException("html page must have <html>");
		}
		this.htmlPage = toReturn;
		return toReturn;
	}

	
	
	
	
	/**
	 * Parses the body elements as written within the HTML tags
	 * @return - the newly constructed Body element
	 * @throws ParseException
	 */
	public Body parseBody() throws ParseException {
		Body toReturn;
		if (this.eatToken(HTMLConstants.OPENBODY)) {
			toReturn = new Body(this.parseBodyStuff());
		} else {
			throw new ParseException("body must begin with <body>");
		}
		return toReturn;
	}

	
	
	
	
	
	/**
	 * Parses the BodyStuff within the body tags
	 * @return - the newly constructed bodyStuff
	 * @throws ParseException
	 */
	public BodyStuff parseBodyStuff() throws ParseException {
		
		int tokenKind = this.htmlT.current().getKind();
		BodyStuff toReturn;
		
		if (tokenKind == HTMLConstants.CLOSEBODY) {
			this.htmlT.advance();
			toReturn = new BodyStuffNone();
			
		} else if (tokenKind == HTMLConstants.OPENFORM) {
			toReturn = new BodyStuffForm(this.parseForm(), this.parseBodyStuff());
			
		} else if (tokenKind == HTMLConstants.OPENPARAGRAPH) {
			toReturn = new BodyStuffParagraph(this.parseParagraph(), this.parseBodyStuff());
			
		} else {
			throw new ParseException("body must contain </body>, form, or paragraph");
		}
		
		return toReturn;
	}

	
	
	
	
	
	
	/**
	 * parses a form object
	 * @return the form object
	 * @throws ParseException
	 */
	public Form parseForm() throws ParseException {
		Form toReturn;
		String action = this.htmlT.current().getAttr();
		this.htmlT.advance();
		toReturn = new Form(action, this.parseFormStuff(), this.index);
		forms.add(toReturn);
		index++;
		return toReturn;
		
	}


	
	
	
	/**
	 * parses a formstuff object
	 * @return newly constructed formstuff
	 * @throws ParseException
	 */
	public FormStuff parseFormStuff() throws ParseException {
		
		int tokenKind = this.htmlT.current().getKind();
		FormStuff toReturn;
		
		if (tokenKind == HTMLConstants.CLOSEFORM) {
			this.htmlT.advance();
			toReturn = new FormStuffNone();
			
		} else if (tokenKind == HTMLConstants.OPENPARAGRAPH) {
			toReturn = new FormStuffParagraph(this.parseParagraph(), this.parseFormStuff());
			
		} else if (tokenKind == HTMLConstants.INPUT) {
			String attribute = this.htmlT.current().getAttr();
			this.htmlT.advance();
			int tempCount = this.counter;
			this.counter++;
			this.fields.add(null);
			toReturn = new FormStuffInput(attribute, this.parseFormStuff(), tempCount);
			this.fields.remove(tempCount);
			this.fields.add(tempCount, toReturn);
			
		} else if (tokenKind == HTMLConstants.SUBMIT) {
			this.htmlT.advance();
			int tempCount = this.counter;
			this.counter++;
			this.fields.add(null);
			toReturn = new FormStuffSubmit(this.parseFormStuff(), tempCount, this.index);
			this.fields.remove(tempCount);
			this.fields.add(tempCount, toReturn);
			
		} else {
			throw new ParseException("form must contain </form>, input, or paragraph");
		}
		
		return toReturn;
	}

	
	
	
	
	/**
	 * parses paragraph object
	 * @return newly constructed paragraph
	 * @throws ParseException
	 */
	public Paragraph parseParagraph() throws ParseException {
		this.htmlT.advance();
		return new Paragraph(this.parseParaStuff());
	}
	
	
	
	
	
	
	/**
	 * parses parastuff object within paragraph tags
	 * @return the new parastuff object
	 * @throws ParseException
	 */
	public ParaStuff parseParaStuff() throws ParseException {
		
		int tokenKind = this.htmlT.current().getKind();
		ParaStuff toReturn;
		if (tokenKind == HTMLConstants.CLOSEPARAGRAPH) {
			this.htmlT.advance();
			toReturn = new ParaStuffNone();
			
		} else if (tokenKind == HTMLConstants.TEXT) {
			String text = this.htmlT.current().getAttr();
			this.htmlT.advance();
			toReturn = new ParaStuffText(new Text(text), this.parseParaStuff());
			
		} else if (tokenKind == HTMLConstants.OPENLINK) {
			
			toReturn = new ParaStuffLink(this.parseLink(), this.parseParaStuff());
			
		} else {
			throw new ParseException("Paragraph must contain </p>, text, or a link");
		}

		return toReturn;

	}


	
	
	
	
	/**
	 * parses link object
	 * @return new link object
	 * @throws ParseException
	 */
	public Link parseLink() throws ParseException {
		
		String href = this.htmlT.current().getAttr();
		
		Link toReturn;
		this.htmlT.advance();
		
		
		if (this.htmlT.current().kind == HTMLConstants.TEXT) {
			
			String text = this.htmlT.current().getAttr();
		
			this.htmlT.advance();
			
			if (this.htmlT.current().kind == HTMLConstants.CLOSELINK) {
				int tempCount = this.counter;
				this.counter++;
				this.fields.add(null);
				toReturn = new Link(href, new Text(text), tempCount);
				this.fields.remove(tempCount);
				this.fields.add(tempCount, toReturn);
				this.htmlT.advance();
				
				
			} else {
				throw new ParseException("Link must close with </a>");
			}
			
		} else {
			throw new ParseException("no text has been entered for this link");
		}
		
		return toReturn;
	}
	
	
	
	
	public static void main(String[] args) {
		
			//HTMLParse p = new HTMLParse("testhtml.txt");
			
		//	try {
			//	p.parseHTMLPage().render();
				
		//	} catch (ParseException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
			//}
			
		
		
		
		
	}
}
