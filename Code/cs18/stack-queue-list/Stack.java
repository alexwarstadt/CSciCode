package hw03;

public interface Stack<T> {

    /**
     * Returns whether or not the stack is empty
     *
     * @@return true if the stack is empty, false otherwise
     */
    public boolean isEmpty();
    
    /**
     * Pushes an item onto the top of the stack
     */
    public void push(T item);
    
    /**
     * Pops an item off the top of the stack
     */
    public void pop();
    
    /**
     * Returns the item on the top of the stack
     *
     * @@return the item on top of the stack
     */
    public T top();

}

