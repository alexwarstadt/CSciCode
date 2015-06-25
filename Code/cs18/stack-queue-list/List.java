package hw03;

interface List<T> extends Iterable<T> {
	
    /**
     * Adds an item to the start of the list
     *
     * @param item - the item to be added
     */
    void addFirst(T item);

    /**
     * Adds an item to the end of the list
     *
     * @param item - the item to be added
     */
    void addLast(T item);

    /**
     * Returns the first item in the list
     *
     * @return the first item in the list
     * @throws NoSuchElementException if the list is empty
     */
    T getFirst();

    /**
     * Returns the last item in the list
     *
     * @return the last item in the list
     * @throws NoSuchElementException if the list is empty
     */
    T getLast();

    /**
     * Removes and returns the first item in the list
     *
     * @return the first item in the list
     * @throws NoSuchElementException if the list is empty
     */
    T removeFirst();

    /**
     * Removes and returns the last item in the list
     *
     * @return the last item in the list
     * @throws NoSuchElementException if the list is empty
     */
    T removeLast();

    /**
     * Removes an item from the list and returns whether or not the removal was successful.
     * If the item is not in the list, the list is unchanged.
     *
     * @param item - the item to remove
     *
     * @return whether or not the item was successfully removed from the list
     */
    boolean remove(T item);

    /**
     * reverses the list
     */
    void reverse();

}
