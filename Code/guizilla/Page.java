package guizilla;

import java.util.Hashtable;
/**
 * the abstract class implementation of our page. 
 * includes the use of Cloneable
 * @author awarstad and kj13
 *
 */
public abstract class Page implements Cloneable {
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	public abstract String defaultHandler(Hashtable<String,String> inputs, String id);
}
