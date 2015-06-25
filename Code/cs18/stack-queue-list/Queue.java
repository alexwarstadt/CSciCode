package hw03;

public interface Queue<T> {

    // checks if the queue is empty
    public boolean isEmpty();
    
    // pushes an element onto the back of the queue
    public void enqueue(T item);
    
    // returns and removes the first element of the queue
    public T dequeue();
    
    // returns the first element of the queue
    public T front();

}

