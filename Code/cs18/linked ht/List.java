package hw05;

interface List<T> extends Iterable<T> {
	
    /**
     * Adds an item to the start of the list
     *
     * @param item - the item to be added
     */
    public void addFirst(T item);

    /**
     * Adds an item to the end of the list
     *
     * @param item - the item to be added
     */
    public void addLast(T item);

    /**
     * Returns the first item in the list
     *
     * @return the first item in the list
     * @throws NoSuchElementException if the list is empty
     */
    public T getFirst();

    /**
     * Returns the last item in the list
     *
     * @return the last item in the list
     * @throws NoSuchElementException if the list is empty
     */
    public T getLast();

    /**
     * Returns an item in the list
     *
     * @param index - an index
     *
     * @return the index-th item in the list
     * @throws NoSuchElementException if the list is empty
     * @throws ArrayOutOfBoundsException if the index is out of bounds
     */
    public T get(int index);
	
    /**
     * Removes and returns the first item in the list
     *
     * @return the first item in the list
     * @throws NoSuchElementException if the list is empty
     */
    public T removeFirst();

    /**
     * Removes and returns the last item in the list
     *
     * @return the last item in the list
     * @throws NoSuchElementException if the list is empty
     */
    public T removeLast();

}
