package hw05;

/* Lookup approaches linear time with respect to the size of the array as the hash table fills because
 * collisions become increasingly frequent as the hash table fills, and with open addressing, collisions
 * are resolved by inserting into the first available slot after the initial hash value. This solution
 * means that long sequences of contiguous slots will be filled, and if a new insert tries initially to
 * insert anywhere in such a sequence, it will increment through all the slots until the end of the sequence
 * and insert there, thus growing the sequence. As sequences grow the likelihood that insert will try to insert
 * into the sequence grows (the probability is the length of the sequence / the size of the array given a 
 * uniform hash function), and so the probability that a sequence will grow increases.
 * 
 * The cost of a call to lookup is linear with respect to the length of the sequence that the value that the 
 * first hash function gives is in. This is because lookup incrementally inspects the slots in the sequence in
 * which the target value is stored until it finds the target. As the hastable fills and the sequences grow 
 * and merge, they approach being one long sequence the length of the array, in which case lookups are exactly
 * linear with respect to the length of the array.
 */



public class OpenAddressing<K,V> extends HashTable<K,V> {

    /**
     * Stores a key-value pair for Open Addressing
     *
     * @param <K> The type of the Keys
     * @param <V> 
     */
    private static class OAPair<K,V> extends KVPair<K,V> {
        private boolean isDeleted;

        /**
         * Creates a new OAPair with the given key and value
         * @param key The key
         * @param value The value
         */
        public OAPair(K key, V value) {
            super(key, value);
            this.isDeleted = false;
        }
        
        
        @Override
		public String toString() {
			if (isDeleted) {
				return "deleted";
			} else {
				return "k=" + this.key.toString() + " v=" + this.value.toString();
			}
		}
    }

    private int size;
    private int n = 0;
    private OAPair<K,V>[] data;
    
   
    

    @SuppressWarnings("unchecked")
    /**
     * Creates a new instance of Open Addressing with a given capacity
     * @param size The size of the internal array to store the hash table
     */
    public OpenAddressing(int size) {
        if (size <= 0) {
            throw new IllegalArgumentException();
        }

        this.size = size;
        this.data = new OAPair[size];
    }
    
    
    
    
    
    /**
     * determines if the array is crowded enough to be resized
     * @return true if the array is crowded enough
     */
    private boolean isCrowded() {
    	return (double)this.n/(double)this.size >= .7;
    }
    
    
    
    
    /**
     * determines if the array is crowded enough to be resized
     * @return true if the array is crowded enough
     */
    private boolean isSparse() {
    	return (double)this.n/(double)this.size <= .1;
    }
    
    
    /**
     * copies the elements of the data array into an array one quarter the size of the original data array
     */
    @SuppressWarnings("unchecked")
    private void shrink(){
    	this.size /= 4;
    	OAPair<K,V>[] newData = new OAPair[this.size];
    	for (int i = 0; i < this.data.length; i++){
    		if (this.data[i] != null) {
    			OAPair<K,V> oap = this.data[i];
    			if (!oap.isDeleted){
    				int index = 0;
    				int hash = hashValue(oap.key, index);
    				while (newData[hash] != null){
    					index++;
    					hash = hashValue(oap.key, index);
    				}
    				newData[hash] = oap;
    			}
    		}
    	}
    	this.data = newData;
    }
    
    /**
     * copies the elements of the data array into an array twice the size of the original data array
     */
    @SuppressWarnings("unchecked")
    private void grow(){
    	this.size *= 2;
    	OAPair<K,V>[] newData = new OAPair[this.size];
    	
    	for (int i = 0; i < this.data.length; i++){
    		if (this.data[i] != null) {
    			OAPair<K,V> oap = this.data[i];
    			if (!oap.isDeleted){
    				int index = 0;
    				int hash = hashValue(oap.key, index);
    				while (newData[hash] != null){
    					index++;
    					hash = hashValue(oap.key, index);
    				}
    				newData[hash] = oap;
    			}
    		}
    	}
    	this.data = newData;
    }
    
    
    
    

    @Override
    protected OAPair<K,V> lookupKVPair(K key) { 
        for (int i = 0; i < this.data.length; i++) {
            OAPair<K,V> currPair = this.data[hashValue(key, i)];

            if (currPair == null) { 
                return null;
            } else if (currPair.key.equals(key)) {
                if(currPair.isDeleted) {
                    return null;
                }
                else {
                    return currPair;
                }
            }
        }

        return null;
    }

    @Override
    public void insert(K key, V value) {
        if (update(key, value) == null) {

            for (int i = 0; i < data.length; i++) {
                int currHash = hashValue(key, i);

                if (this.data[currHash] == null || this.data[currHash].isDeleted) {
                    this.data[currHash] = new OAPair<K,V>(key, value);
                    this.n++;
                    if (this.isCrowded()) {
                    	this.grow();
                    }
                    return; 
                }
            } 

            System.out.println("The hash table is full. Sorry!");
        }
    }

    @Override
    public V delete(K key) {
        OAPair<K,V> toDelete = lookupKVPair(key);
        if (toDelete == null) {
            return null;
        }

        toDelete.isDeleted = true;
        this.n--;
        if (this.isSparse()) {
        	this.shrink();
        }
        return toDelete.value;
    }

    /**
     * Calculates the ith hash value for a key K.
     * @param key The key to hash
     * @param i The offset of the spot to check
     * @return The index of the array to hash the key to.
     */
    private int hashValue(K key, int i) {
        return Math.abs((key.hashCode() + i) % this.size);
    }
    
    
    
    private void seeArray() {
		String toReturn = "|";
		for (int i = 0; i < this.data.length; i++) {
			if (data[i] == null) {
				toReturn += "null|";
			} else
				toReturn += data[i].toString() + "|";
		}
		toReturn += " n=" + this.n + "; size=" + this.size + "; l=" + this.data.length;
		System.out.println(toReturn);
	}
	
    
    public static void main (String[] args){
    	
    	//testing grow
    	OpenAddressing<Integer, String> oa1 = new OpenAddressing<Integer, String>(1);
    	oa1.insert(2, "a");
    	System.out.println(oa1.size == 2 && oa1.n == 1);
    	oa1.insert(3, "b");
    	System.out.println(oa1.size == 4 && oa1.n == 2);
    	oa1.insert(4, "c");
    	System.out.println(oa1.size == 8 && oa1.n == 3);
    	oa1.insert(5, "d");
    	oa1.insert(6, "e");
    	System.out.println(oa1.size == 8 && oa1.n == 5);
    	oa1.insert(7, "f");
    	System.out.println(oa1.size == 16 && oa1.n == 6);
    	oa1.insert(8, "g");
    	oa1.insert(9, "h");
    	oa1.insert(100, "i");
    	oa1.insert(12, "j");
    	oa1.insert(18, "k");
    	oa1.insert(2, "l");
    	System.out.println(oa1.size == 16 && oa1.n == 11);
    	oa1.insert(34, "l");
    	System.out.println(oa1.size == 32 && oa1.n == 12);
    	oa1.insert(103, "l");
    	oa1.seeArray();
    	
    	
    	
    	//testing shrink
    	System.out.println(oa1.delete(103).equals("l"));
    	System.out.println(oa1.size == 32 && oa1.n == 12);
    	System.out.println(oa1.delete(100).equals("i"));
    	System.out.println(oa1.size == 32 && oa1.n == 11);
    	oa1.delete(5);
    	oa1.delete(7);
    	oa1.delete(8);
    	System.out.println(oa1.delete(10) == null);
    	oa1.delete(3);
    	System.out.println(oa1.delete(12).equals("j"));
    	System.out.println(oa1.size == 32 && oa1.n == 6);
    	oa1.delete(2);
    	System.out.println(oa1.delete(4).equals("c"));
    	System.out.println(oa1.size == 32 && oa1.n == 4);
    	oa1.delete(18);
    	System.out.println(oa1.size == 8 && oa1.n == 3);
    	oa1.delete(9);
    	System.out.println(oa1.size == 8 && oa1.n == 2);
    	oa1.delete(6);
    	System.out.println(oa1.size == 8 && oa1.n == 1);
    	System.out.println(oa1.delete(34).equals("l"));
    	System.out.println(oa1.size == 2 && oa1.n == 0);



    	
    	
    }

}

