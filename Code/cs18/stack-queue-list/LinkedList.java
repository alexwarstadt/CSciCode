package hw03;

import java.util.Iterator;
import java.util.NoSuchElementException;
import java.lang.StringBuilder;

public class LinkedList<T> implements List<T> {

    private static class SLLNode<S> {
        
        S item;
        SLLNode<S> next = null;

        /**
         * Constructs a Node
         *
         * @param item - the item stored at this node
         */    
        SLLNode(S item) {
            this.item = item;
        }
    }

    private SLLNode<T> start;
    private SLLNode<T> end;
    
    /**
      * @return true if the list is empty, false otherwise
      */
    private boolean isEmpty() {
        return (this.start == null) && (this.end == null);
    }
    
    @Override
    public T getFirst() {
        if (isEmpty()) {
            throw new NoSuchElementException();
        }
        else{
            return this.start.item;
        }
    }

    @Override
    public T getLast() {
        if (isEmpty()) {
            throw new NoSuchElementException();
        } 
        else{
            return this.end.item;
        }
    }
    
    @Override
    public void addFirst(T item) {
        SLLNode<T> myNode = new SLLNode<T>(item);
        if (isEmpty()) {
            this.end = myNode;
        } else {
            myNode.next = this.start;
        }
        this.start = myNode;
    }
    
    @Override
    public void addLast(T item) {
        SLLNode<T> myNode = new SLLNode<T>(item);
        if (isEmpty()) {
            this.start = myNode;
        } else {
            this.end.next = myNode;
        }
        this.end = myNode;
    }
    
    @Override
    public T removeFirst() {
        if (isEmpty()) {
            throw new NoSuchElementException();
        } 

        T toReturn = this.start.item;
        if (this.start == this.end) {
            this.end = null;
        }
        this.start = this.start.next;
        return toReturn;
    }   
    
    @Override
    public T removeLast() {
        if (isEmpty()) {
            throw new NoSuchElementException();
        }

        T toReturn = this.end.item;
        if (this.start == this.end) {
            this.start = null;
            this.end = null;
        } else {
            SLLNode<T> current = this.start;
            
            while (current.next != this.end) {
                current = current.next;
            }
            
            this.end = current;
            this.end.next = null;
        }

        return toReturn;
    }

    @Override
    public boolean remove(T item) {
        SLLNode<T> current = this.start;
        SLLNode<T> previous = null;

        while (current != null) {
            if (current.item == item) {
                if (current == this.start)  {
                    removeFirst();
                } else if (current == this.end) {
                    removeLast();
                } else {
                    previous.next = current.next;
                }
                return true;
            } else {
                previous = current;
                current = current.next;
            }
        }

        return false;
    }
  
    @Override
    public void reverse() {
        if (this.start != this.end) {
            SLLNode<T> current = this.start;
            SLLNode<T> previous = null;

            this.end = this.start;
            while (current != null) {
                SLLNode<T> temp = current.next;
                current.next = previous;
                previous = current;
                current = temp;
            }
            this.start = previous;
        }
    }

    @Override
    public Iterator<T> iterator() { 
	// not implemented (but must be implemented in your Doubly Linked List)
	return null;
    }
 
    @Override
    public String toString() {        
        StringBuilder string = new StringBuilder();
	
	SLLNode<T> curr = this.start; 
	while (curr != null) { 
	    string.append(" " + curr.item);
	    curr = curr.next;
	}

        return string.toString();
    }

    @SuppressWarnings("unchecked")
    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (!(o instanceof LinkedList<?>)) {
            return false;
        }

	LinkedList<T> that = (LinkedList<T>) o;
        SLLNode<T> thisCurr = this.start; 
        SLLNode<T> thatCurr = that.start; 

        while(thisCurr != null || thatCurr!=null) {
            if (thatCurr == null || thisCurr == null) {
                return false;
            }
            if (!thisCurr.item.equals(thatCurr.item)) {
                return false;
            }
            thisCurr = thisCurr.next;
            thatCurr = thatCurr.next;
        }

        return true;    
    }

} 
