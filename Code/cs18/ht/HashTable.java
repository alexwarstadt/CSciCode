package hw04;


public abstract class HashTable<K,V> implements IHashTable<K,V> {
  
    protected static class KVPair<K,V> {
		protected K key;
		protected V value;
	    
		public KVPair(K key, V value) {
		    this.key = key;
		    this.value = value;
		}
		
		@Override
		public String toString() {
			return "key " + this.key.toString() + ", value " + this.value.toString();
		}
		
		@SuppressWarnings ("unchecked")
		@Override
		public boolean equals(Object o) {
			if (this == o){
				return true;
			}
			if (o instanceof KVPair<?,?>){
			    KVPair<K,V> other = (KVPair<K,V>)o;
			    return this.key.equals(other.key) && this.value.equals(other.value);
			} else {
				return false;
			}
		}
    }
  
    /**
     * Looks for a key in the table
     *
     * @param key - the key to look up
     *
     * @return the key-value pair found, 
     *         or null if the key is not found
     */
    protected abstract KVPair<K,V> lookupKVPair(K key);

    @Override
    public V lookup(K key) {
	KVPair<K,V> pair = lookupKVPair(key);

	if (pair != null) {
	    return pair.value;
	} else {
	    return null;
	}
    }

    @Override
    public V update(K key, V value) {
	KVPair<K,V> pair = lookupKVPair(key);

	if (pair != null) {
	    pair.value = value;
	    return value;
	} else {
	    return null;
	}
    }
    
   

    @Override
    public abstract void insert(K key, V value);

    @Override
    public abstract V delete(K key);

}
