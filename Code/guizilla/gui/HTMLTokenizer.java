package guizilla.gui;
import javax.swing.*;
import java.io.*;

/**
 * This class is what you should use for tokenizing, and wraps everything else.
 * This and the HTMLConstants.java are the only files you should need to use
 * directly.
 */
public class HTMLTokenizer {

	private HTMLTokenManager _tm;
	private Token _current;

	// /////////////////////////////////////////////////////////////////////////////////////
	// the public interface

	public HTMLTokenizer(Reader r) {
		_tm = new HTMLTokenManager(new SimpleCharStream(r));
		_current = null;
	}

	// return the current token, without advancing
	public Token current() {
		return _current;
	}

	//advance the current token, losing all knowledge of the previous current token
	public void advance() {
		_current = _tm.getNextToken();
	}

}

