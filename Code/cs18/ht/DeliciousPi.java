package hw04;
import java.io.*;

/**
 * contains an open addressing hashtable storing the location in pi of the first appearance of every 
 * 5-digit sequence in the first million digits of pi, and allows user to retrieve position from an inputted sequence
 * @author awarstad
 *
 */
public class DeliciousPi {
	
	OpenAddressing<String, Integer> piTable;
	
	public DeliciousPi(){
		try{
			BufferedReader r = new BufferedReader(new FileReader("pi.txt"));
			String pi = r.readLine();
			r.close();
			String key = null;
			Integer value = 0;
			this.piTable = new OpenAddressing<String, Integer>(100000);
			
			while (value < 999996) {
				key = pi.substring(value, value + 5);
				if (piTable.lookup(key) == null) {
					piTable.insert(key, value);
				}
				value++;
			}
		} catch (IOException e) {
			System.out.println("put in a good file!");
		}
	}
	
	/**
	 * finds the integer location of first appearance of a sequence of 5 digits in pi
	 * @param sequence the five digit sequence to be searched
	 * @return the position in pi of the first appearance of that sequence in the first million digits
	 */
	public Integer find(String sequence){
		return this.piTable.lookup(sequence);
	}
	
	@Override
	public String toString(){
		return piTable.toString();
	}
	
	/**
	 * allows user to interact with find from the command line
	 * @param args an array of strings corresponding to the sequences of digits to be searched
	 */
	public static void main(String[] args) {
		
		DeliciousPi dp = new DeliciousPi();
		for (int i = 0; i < args.length; i++) {
			System.out.println(dp.find(args[i]));
		}
		
		//I've commented out test cases so they don't print in command line
		//System.out.println(dp.find("31415") == 0);
		//System.out.println(dp.find("59265") == 4);
		
	}

}
