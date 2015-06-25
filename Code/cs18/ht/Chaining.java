package hw04;
import java.util.LinkedList;
import java.util.ListIterator;
import java.lang.IllegalArgumentException;

public class Chaining<K,V> extends HashTable<K, V> implements IHashTable<K, V> {

	private int size;
	public LinkedList<KVPair<K,V>>[] data;
	
	@SuppressWarnings("unchecked")
	public Chaining(int size) throws IllegalArgumentException {
		if (size <= 0) {
			throw new IllegalArgumentException();
		}
		this.size = size;
		this.data = (LinkedList<KVPair<K,V>>[]) new LinkedList[size];
	}
	
	/**
	 * the hash function for a chaining hashtable
	 * @param key the key to be hashed
	 * @return the hash value associated with key
	 */
	private int hash(K key) {
		return key.hashCode() % this.size;
	}
	
	@Override
	public KVPair<K,V> lookupKVPair(K key){
		LinkedList<KVPair<K,V>> list = data[this.hash(key)];
		if (list == null){
			return null;
		} else {
			KVPair<K,V> toReturn = null;
			KVPair<K,V> current;
			ListIterator<KVPair<K,V>> it = list.listIterator(0);
			while (it.hasNext() && toReturn == null){
				current = it.next();
				if (current.key.equals(key)){
					toReturn = current;
				}
			}
			return toReturn;
		}
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
		if (this.lookup(key) == null) {
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
			if (this.data[this.hash(key)] == null) {
				LinkedList<KVPair<K,V>> list = new LinkedList<KVPair<K,V>>();
				data[this.hash(key)] = list;
			}
			this.data[this.hash(key)].addFirst(new KVPair<K,V>(key, value));
		} else {
			this.update(key, value);
		}
	}

	@Override 
	public V delete(K key){
		V toReturn = this.lookup(key);
		if (toReturn != null){
			this.data[this.hash(key)].remove(new KVPair<K,V>(key, toReturn));
		}
		return toReturn;
	}
	
	@Override
	public String toString() {
		String toReturn = "";
		for (int i=0; i<size; i++) {
			String s = "";
			if (this.data[i] != null) {
				for (int j=0; j<this.data[i].size(); j++){
					s = s + this.data[i].get(j).toString() + "\t";
				}
			}
			toReturn = toReturn + i + ": " + s + "\n";
		}
		return toReturn;
	}
	
	
	

	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Chaining<Integer, String> c0 = new Chaining<Integer, String>(10);
		Chaining<Integer, String> c1 = new Chaining<Integer, String>(10);
		c1.insert(105, "hello");
		c1.insert(5, "boo");
		c1.insert(59, "no");
		c1.insert(3, "hey");
		c1.insert(25, "good");
		try{
			new Chaining<Integer, String>(0);
		} catch (IllegalArgumentException e){
			System.out.println("true");
		}
		
		//TESTING FOR hash
		System.out.println(c1.hash(35) == 5);
		System.out.println(c0.hash(40) == 0);
		
		
		
		
		//TESTING FOR lookupKVPair
		System.out.println(c1.lookupKVPair(5).equals(new KVPair<Integer,String>(5, "boo"))); //key in HT
		System.out.println(c1.lookupKVPair(90) == null); //key not in HT
		System.out.println(c1.lookupKVPair(105).equals(new KVPair<Integer,String>(105, "hello"))); //key at end of multiple elt linked list
		System.out.println(c0.lookupKVPair(5) == null); //nothing in hashtable
		
		
		//TESTING FOR lookup
		System.out.println(c1.lookup(5).equals("boo")); //key in HT
		System.out.println(c1.lookup(90) == null); //key not in HT
		System.out.println(c1.lookup(105).equals("hello")); //key at end of multiple elt linked list
		System.out.println(c0.lookup(5) == null); //nothing in hashtable
		
		
		
		//TESTING FOR update
		System.out.println(c1.update(5, "Bach").equals("boo")); //key in HT
		System.out.println(c1.update(90, "Handel") == null); //key not in HT
		System.out.println(c1.update(105, "Telemann").equals("hello")); //key at end of multiple elt linked list
		System.out.println(c0.update(5, "Rameau") == null); //nothing in hashtable
		System.out.println(c1.lookup(5).equals("Bach")); //key in HT
		System.out.println(c1.lookup(90) == null); //key not in HT
		System.out.println(c1.lookup(105).equals("Telemann")); //key at end of multiple elt linked list
		System.out.println(c0.lookup(5) == null); //nothing in hashtable
		
		//TESTING FOR insert
		c1.insert(24, "Couperin");   //nothing in that bin
		System.out.println(c1.lookup(24).equals("Couperin"));
		c1.insert(65, "Buxtehude");   //items already in bin
		System.out.println(c1.lookup(65).equals("Buxtehude"));
		c1.insert(24, "Lully");   //that key already in bin, updates
		System.out.println(c1.lookup(24).equals("Lully"));
		c1.insert(105, "Schein");
		System.out.println(c1.lookup(105).equals("Schein"));
		
		//TESTING FOR delete
		c1.delete(100);   //nothing at that key, and bin empty
		System.out.println(c1.lookup(100) == null);
		c1.delete(105);   //items already in bin, last in bin
		System.out.println(c1.lookup(105) == null);
		c1.delete(65);   //items already in in bin, first in bin
		System.out.println(c1.lookup(65) == null);
		c1.delete(85); //items in that bin, nothing at key
		System.out.println(c1.lookup(85) == null);
		System.out.println(c1.lookup(5).equals("Bach")); //rest of bin undisturbed after deletion

	}

}
