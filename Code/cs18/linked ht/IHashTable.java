package hw05;

public interface IHashTable<K,V> {

    /**
     * Looks up a key in the table
     *
     * @param key - the key to lookup
     *
     * @return the value associated with the key,
     *         or null if the key is not found
     */
    public V lookup(K key);

    /**
     * Updates an old key with a new value
     *
     * @param key - the key to update in the table
     * @param value - the new value to associate with the key
     *
     * @return the old value associated with the key,
     *         or null if the key is not found
     */
    public V update(K key, V value);

    /**
     * Binds a key (new or old) to a value
     *
     * @param key - the key to insert into the table
     * @param value - the value to associate with the key
     */
    public void insert(K key, V value);

    /**
     * Deletes the KVPair associated with a key from the table
     *
     * @param key - the key to remove from the hashtable
     *
     * @return the value associated with the key,
     *         or null if the key is not found
     */
    public V delete(K key);

}
