package hw04;
import java.lang.IllegalArgumentException;

/**
 * implements hash table using linear probing open addressing
 * @author awarstad
 * @param <K> the key
 * @param <V> the value
 */
public class OpenAddressing<K,V> extends HashTable<K,V> implements IHashTable<K,V> {
	
	protected static class OAPair<K,V> extends HashTable.KVPair<K,V>{
		
		protected boolean deleted;
		
		public OAPair(K key, V value){
			super(key, value);
			this.deleted = false;
		}
		
		@Override
		public String toString() {
			if (deleted) {
				return "deleted";
			} else {
				return "key " + this.key.toString() + ", value " + this.value.toString();
			}
		}
	}

	
	private int size;
	public OAPair<K,V>[] data;
	
	@SuppressWarnings("unchecked")
	public OpenAddressing(int size) throws IllegalArgumentException {
		if (size <= 0) {
			throw new IllegalArgumentException();
		}
		this.size = size;
		this.data = (OAPair<K,V>[]) new OAPair[size];
	}
	
	/**
	 * gets the nth hash function for linear probing
	 * @param key the key
	 * @param n the number hash function
	 * @return the hash value for key on h_n
	 */
	private int hashn(K key, int n) {
		/*I implement linear probing here, but I use my hashn() method throughout
		rather than storing hashCode(key) in some variable and incrementing that
		so that all methods but this are general for all open addressing and only the 
		hashn() method needs to change in order to implement another kind of hashing */
		
		return (key.hashCode() + n) % this.size;
	}
	
	
	@Override
	public KVPair<K,V> lookupKVPair(K key){
		int n = 0;
		int i = this.hashn(key, n);
		OAPair<K,V> toReturn = null;
		while (n < this.size){
			if (data[i]!= null) {
				if (data[i].deleted || !data[i].key.equals(key)) {
					n++;
					i = this.hashn(key, n);
				} else {
					toReturn = data[i];
					break;
				}
			} else {
				toReturn = null;
				break;
			}
		}
		return toReturn;
	}
	
	@Override
	public V lookup(K key){
		if (this.lookupKVPair(key) == null) {
			return null;
		} else {
			return this.lookupKVPair(key).value;
		}
	}

	@Override 
	public V update(K key, V value){
		if (this.lookupKVPair(key) == null) {
			return null;
		} else {
			V toReturn = this.lookup(key);
			this.lookupKVPair(key).value = value;
			return toReturn;
		}
	}

	@Override
	public void insert(K key, V value){
		if (this.lookupKVPair(key) == null){
			int n = 0;
			int i = hashn(key, n);
			while (n < this.size) {
				if (this.data[i] == null) {
					this.data[i] = new OAPair<K,V>(key, value);
					break;
				} else if (this.data[i].deleted) {
					this.data[i] = new OAPair<K,V>(key, value);
					break;
				} else {
					n++;
					i = hashn(key, n);
				}
			}
		} else {
			this.update(key, value);
		}
	}

	@Override 
	public V delete(K key){
		V toReturn = this.lookup(key);
		if (toReturn != null){
			int n = 0;
			int i = hashn(key, n);
			while (n < this.size) {
				if (this.data[i].key.equals(key)){
					this.data[i].deleted = true;
					break;
				}
				n++;
				i = hashn(key, n);
			}
		}
		return toReturn;
	}
	
	@Override
	public String toString() {
		String toReturn = "";
		for (int i=0; i < this.size; i++) {
			String s = "";
			if (this.data[i] != null){
				s = this.data[i].toString();
			}
			toReturn = toReturn + i + ": " + s + "\n";
		}
		return toReturn;
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		OpenAddressing<Integer, String> c0 = new OpenAddressing<Integer, String>(10);
		OpenAddressing<Integer, String> c1 = new OpenAddressing<Integer, String>(10);
		c1.insert(105, "hello");
		c1.insert(5, "boo");
		c1.insert(59, "no");
		c1.insert(3, "hey");
		c1.insert(25, "good");
		
		try{
			new OpenAddressing<Integer, String>(0);
		} catch (IllegalArgumentException e){
			System.out.println("true");
		}
		
		System.out.println(c1.toString());
		
		//TESTING FOR hash
		System.out.println(c1.hashn(35, 0) == 5);
		System.out.println(c0.hashn(40, 8) == 8);
		System.out.println(c0.hashn(49, 8) == 7);	//hash function wraps around to beginning of table
		
		
		//TESTING FOR lookupKVPair
		System.out.println(c1.lookupKVPair(5).equals(new OAPair<Integer,String>(5, "boo"))); //key in HT, not at first hash value
		System.out.println(c1.lookupKVPair(90) == null); //key not in HT
		System.out.println(c1.lookupKVPair(105).equals(new OAPair<Integer,String>(105, "hello"))); //key at first hash value
		System.out.println(c0.lookupKVPair(5) == null); //nothing in hashtable
		
		
		
		//TESTING FOR lookup
		System.out.println(c1.lookup(5).equals("boo")); //key in HT, not at first hash value
		System.out.println(c1.lookup(90) == null); //key not in HT
		System.out.println(c1.lookup(105).equals("hello")); //key in HT, at first hash value
		System.out.println(c0.lookup(5) == null); //nothing in hashtable
		
		
		
		//TESTING FOR update
		System.out.println(c1.update(5, "Bach").equals("boo")); //key in HT
		System.out.println(c1.update(90, "Handel") == null); //key not in HT
		System.out.println(c1.update(105, "Telemann").equals("hello")); //key in HT,t at first hash value
		System.out.println(c0.update(5, "Rameau") == null); //nothing in hashtable
		System.out.println(c1.lookup(5).equals("Bach")); //key in HT
		System.out.println(c1.lookup(90) == null); //key not in HT
		System.out.println(c1.lookup(105).equals("Telemann")); //key in HT, not at first hash value
		System.out.println(c0.lookup(5) == null); //nothing in hashtable
		
		//TESTING FOR insert
		c1.insert(24, "Couperin");   //nothing in that bin
		System.out.println(c1.lookup(24).equals("Couperin"));
		c1.insert(65, "Buxtehude");   //doesn't go to first hash value
		System.out.println(c1.lookup(65).equals("Buxtehude"));
		c1.insert(24, "Lully");   //that key already in bin, updates
		System.out.println(c1.lookup(24).equals("Lully"));
		c1.insert(105, "Schein");
		System.out.println(c1.lookup(105).equals("Schein"));
		
		System.out.println(c1.toString());
		
		//TESTING FOR delete
		c1.delete(100);   //nothing at that key, and bin empty
		System.out.println(c1.lookup(100) == null);
		c1.delete(105);   //key in hashtable, at first hash value
		System.out.println(c1.lookup(105) == null);
		c1.delete(65);   //key in hashtable, not at first hash value and has to search past a deleted bin
		System.out.println(c1.lookup(65) == null);
		System.out.println(c1.toString());
		c1.insert(88, "Strozzi"); //insert into a deleted slot at first hash value
		System.out.println(c1.lookup(88).equals("Strozzi"));
		c1.insert(85, "Lotti"); //insert into a deleted slot not at first hash value
		System.out.println(c1.lookup(85).equals("Lotti"));
		
		
		
	}

}
