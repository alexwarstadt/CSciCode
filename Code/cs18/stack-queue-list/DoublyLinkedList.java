package hw03;

import java.util.NoSuchElementException;

import java.util.Iterator;

/**
 * a doubly linked list
 * @author awarstad
 *
 * @param <T>
 */
public class DoublyLinkedList<T> implements List<T> {

	/**
	 * a node for a doubly linked list
	 * @author awarstad
	 *
	 * @param <S> a type
	 */
	private static class DLLNode<S> {
	        
	        S item;
	        DLLNode<S> next = null;
	        DLLNode<S> previous = null;

	        /**
	         * Constructs a Node
	         *
	         * @param item - the item stored at this node
	         */    
	        DLLNode(S item) {
	            this.item = item;
	        }
	    }

	    private DLLNode<T> start = null;
	    private DLLNode<T> end = null;
	    
	    /**
	      * @return true if the list is empty, false otherwise
	      */
	    private boolean isEmpty() {
	        return (this.start == null) && (this.end == null);
	    }
	
	
	
	@Override
    public void addFirst(T item) {
    	DLLNode<T> myNode = new DLLNode<T>(item);
    	if (this.isEmpty()){
    		this.end = myNode;
    		myNode.next = null;
    	} else {
    		this.start.previous = myNode;
    		myNode.next = this.start;
    	}
    	this.start = myNode;
    	myNode.previous = null;
    }

    
	@Override
    public void addLast(T item){
    	DLLNode<T> myNode = new DLLNode<T>(item);
    	if (this.isEmpty()){
    		this.start = myNode;
    		myNode.previous = null;
    	} else {
    		this.end.next = myNode;
    		myNode.previous = this.end;
    	}
    	myNode.next = null;
    	this.end = myNode;
    }

    
    @Override
    public T getFirst() throws NoSuchElementException {
    		if (this.isEmpty()) {
    			throw new NoSuchElementException("");
    		} else {
    			return this.start.item;
    		}
    }

    @Override
    public T getLast() throws NoSuchElementException {
        if (isEmpty()) {
            throw new NoSuchElementException("");
        } 
        else{
            return this.end.item;
        }
    }

    @Override
    public T removeFirst() throws NoSuchElementException{
	    if (isEmpty()) {
	    	throw new NoSuchElementException("");
	    } 
	   	T returnFirst = this.start.item;
	   	if (this.start == this.end){
	   		this.end = null;
	   		this.start = null;
	   	} else {
        this.start = this.start.next;
        this.start.previous = null;
	   	}
    	return returnFirst;
   	}

   @Override
    public T removeLast() throws NoSuchElementException{
	    if (isEmpty()) {
	    	throw new NoSuchElementException("");
	    } 
	   	T returnLast = this.end.item;
	   	if (this.start == this.end){
	   		this.start = null;
	   		this.end = null;
	   	} else {
        this.end = this.end.previous;
        this.end.next = null;
	   	}
    	return returnLast;
    }

   @Override
    public boolean remove(T item){
	    DLLNode<T> current = this.start;
	    DLLNode<T> previous = null;
	    while (current != null) {
		    if (current.item == item) {
		    	if (current == this.start)  {
		    		removeFirst();
		        } else if (current == this.end) {
		        	removeLast();
		        } else {
		         	previous.next = current.next;
		           	current.next.previous = previous;
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
    public void reverse(){
    	 if (this.start != this.end) {
             DLLNode<T> current = this.start;
             DLLNode<T> previous = null;

             this.end = this.start;
             while (current != null) {
                 DLLNode<T> nexttemp = current.next;
                 current.next = previous;
                 current.previous = nexttemp;
                 previous = current;
                 current = nexttemp;
             }
             this.start = previous;
         }
    }
    
    /**
     * constructs an iterator for a doubly linked list
     * contains the methods of an Iterator, hasNext, next, and remove.
     */
    public Iterator<T> iterator() { 
    
    	Iterator<T> iter = new Iterator<T>() {
    		public DLLNode<T> current = start;
    		
	    	public boolean hasNext() {
	    		return (current != null);
	    	}
	    	
	    	public T next() throws NoSuchElementException {
	    		if (!this.hasNext()) {
	    			throw new NoSuchElementException("");
	    		}
	    		T toReturn = current.item;
	    		current = current.next;
	    		return toReturn;
	    	}
	    	
	    	public void remove() throws NoSuchElementException {
	    		if (start == null) {
	    			throw new NoSuchElementException("");
	    		} else {
		    		DLLNode<T> before = current.previous;
		    		DLLNode<T> after = current.next;
		    		if (start != current && end != current) {
		    			current.previous = before;
		    			current.next = after;
		    		} if (start == current) {
		    			start = after;
		    		} if (current == end) {
		    			end = before;
		    		}
	    		}
	    	}
    	};
    	return iter;
    }
    
    @Override
    public String toString() {
    	Iterator<T> myIter = this.iterator();
    	String myString = "";
        while (myIter.hasNext()) {
        	myString = myString + myIter.next().toString() + " ";
        }
        return myString;
    }
   
    
   //@Override
    /*public boolean equals(Object o) {
    	if (this == o) {
            return true;
        }

        if (!(o instanceof DoublyLinkedList<?>)) {
            return false;
        }
        //this is just what the source code for linked list does but for some reason
        //here it gives a warning even though my logic is sound. If it's not not
        //an instanceof DLL then it's a DLL.
        else if (o instanceof DoublyLinkedList<?>) {
	        DoublyLinkedList<T> that = (DoublyLinkedList<T>) o;
	    	Iterator<T> thisIter = this.iterator();
	    	Iterator<T> thatIter = that.iterator();
	    	boolean toReturn = true;
	    	while (toReturn == true && thisIter.hasNext() && thatIter.hasNext()) {
	    		toReturn = toReturn && thisIter.next().equals(thatIter.next());
	    	}
        }
    	return toReturn;
    }*/
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		DoublyLinkedList<Integer> DLL4 = new DoublyLinkedList<Integer>();
		DLL4.addFirst(4);
		DLL4.addFirst(3);
		DLL4.addFirst(2);
		DLL4.addFirst(1);
		
		DoublyLinkedList<Integer> DLL2 = new DoublyLinkedList<Integer>();
		DLL2.addLast(2);
		DLL2.addLast(1);
		
		DoublyLinkedList<Integer> DLL1 = new DoublyLinkedList<Integer>();
		DLL1.addFirst(1);
		
		DoublyLinkedList<Integer> DLL1a = new DoublyLinkedList<Integer>();
		DLL1a.addLast(1);
		
		DoublyLinkedList<Integer> DLL0 = new DoublyLinkedList<Integer>();
		
		//TESTING for isEmpty
		System.out.println(DLL0.isEmpty());
		System.out.println(!DLL4.isEmpty());
		
		
		//TESTING addFirst/addLast using toString
		System.out.println(DLL4.toString().equals("1 2 3 4 "));
		System.out.println(DLL2.toString().equals("2 1 "));
		System.out.println(DLL1.toString().equals("1 "));
		System.out.println(DLL1a.toString().equals("1 "));
		
		
		//TESTING getFirst
		System.out.println(DLL4.getFirst() == 1);
		System.out.println(DLL2.getFirst() == 2);
		System.out.println(DLL1.getFirst() == 1);
		System.out.println(DLL1a.getFirst() == 1);
		try{
		System.out.println(DLL0.getFirst() == 1);
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		//TESTING getLast
		System.out.println(DLL4.getLast() == 4);
		System.out.println(DLL2.getLast() == 1);
		System.out.println(DLL1.getLast() == 1);
		System.out.println(DLL1a.getLast() == 1);
		try{
		System.out.println(DLL0.getLast() == 1);
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		//TESTING for removeFirst
		System.out.println(DLL4.removeFirst() == 1);
		System.out.println(DLL4.getFirst() == 2);
		
		System.out.println(DLL2.removeFirst() == 2);
		System.out.println(DLL2.getFirst() == 1);
		
		System.out.println(DLL1.removeFirst() == 1);
		System.out.println(DLL1.isEmpty());
		
		System.out.println(DLL1a.removeFirst() == 1);
		System.out.println(DLL1a.isEmpty());
		try{
		System.out.println(DLL0.removeFirst() == 1);
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		//TESTING for removeLast
		DLL4.addFirst(1);
		DLL2.addFirst(2);
		DLL1.addFirst(1);
		DLL1a.addLast(1);
		
		System.out.println(DLL4.removeLast() == 4);
		System.out.println(DLL4.getLast() == 3);
		
		System.out.println(DLL2.removeLast() == 1);
		System.out.println(DLL2.getLast() == 2);
		
		System.out.println(DLL1.removeLast() == 1);
		System.out.println(DLL1.isEmpty());
		
		System.out.println(DLL1a.removeLast() == 1);
		System.out.println(DLL1a.isEmpty());
		try{
		System.out.println(DLL0.removeLast() == 1);
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		//TESTING FOR remove
		DLL4.addLast(4);
		DLL2.addLast(1);
		DLL1.addLast(1);
		DLL1a.addLast(1);
		DoublyLinkedList<Integer> DLL4a = new DoublyLinkedList<Integer>();
		DoublyLinkedList<Integer> DLL4b = new DoublyLinkedList<Integer>();
		DoublyLinkedList<Integer> DLL4c = new DoublyLinkedList<Integer>();
		DoublyLinkedList<Integer> DLL4test = new DoublyLinkedList<Integer>();
		
		DLL4a.addFirst(4);
		DLL4a.addFirst(3);
		DLL4a.addFirst(2);
		DLL4a.addFirst(1);
		
		DLL4b.addFirst(4);
		DLL4b.addFirst(3);
		DLL4b.addFirst(2);
		DLL4b.addFirst(1);
		
		DLL4c.addFirst(4);
		DLL4c.addFirst(3);
		DLL4c.addFirst(2);
		DLL4c.addFirst(1);
		
		DLL4test.addFirst(4);
		DLL4test.addFirst(2);
		DLL4test.addFirst(1);
		
		System.out.println(DLL4a.remove(1));
		System.out.println(DLL4a.getFirst() == 2);
		
		System.out.println(DLL4b.remove(3));
		System.out.println(DLL4b.equals(DLL4test));
		
		System.out.println(DLL4c.remove(4));
		System.out.println(DLL4c.getLast() == 3);
		
		System.out.println(DLL4a.remove(4));
		System.out.println(!DLL4a.remove(100));
		System.out.println(DLL4a.getLast() == 3);
		
		System.out.println(DLL2.remove(2));
		System.out.println(DLL2.getFirst() == 1);
		System.out.println(DLL1.remove(1));
		System.out.println(DLL1.isEmpty());
		System.out.println(DLL1a.remove(1));
		System.out.println(DLL1a.isEmpty());
		System.out.println(!DLL0.remove(4));
		
		
		
		
		//TESTING FOR reverse
		DLL2.addFirst(2);
		DLL1.addFirst(1);
		DLL1a.addLast(1);
		

		DLL4.reverse();
		DLL2.reverse();
		DLL1.reverse();
		DLL0.reverse();
		System.out.println(DLL4.toString().equals("4 3 2 1 "));
		System.out.println(DLL2.toString().equals("1 2 "));
		System.out.println(DLL1.toString().equals("1 "));
		System.out.println(DLL0.toString().equals(""));
		
		
		//TESTING FOR hasNext
		DLL4.reverse();
		DLL2.reverse();
		DLL1.reverse();
		DLL0.reverse();
		Iterator<Integer> it4 = DLL4.iterator();
		Iterator<Integer> it2 = DLL2.iterator();
		Iterator<Integer> it1 = DLL1.iterator();
		Iterator<Integer> it1a = DLL1a.iterator();
		Iterator<Integer> it0 = DLL0.iterator();
		
		System.out.println(it4.hasNext());
		System.out.println(it2.hasNext());
		System.out.println(it1.hasNext());
		System.out.println(it1a.hasNext());
		System.out.println(!it0.hasNext());
		
		//TESTING FOR next
		System.out.println(it4.next() == 1);
		System.out.println(it4.next() == 2);
		System.out.println(it4.next() == 3);
		System.out.println(it4.next() == 4);
		System.out.println(!it4.hasNext());
		System.out.println(it2.next() == 2);
		System.out.println(it2.next() == 1);
		System.out.println(!it2.hasNext());
		System.out.println(it1.next() == 1);
		System.out.println(!it1.hasNext());
		try{
			System.out.println(it0.next());
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		
		//TESTING FOR remove
		DLL4 = new DoublyLinkedList<Integer>();
		DLL4.addFirst(4);
		DLL4.addFirst(3);
		DLL4.addFirst(2);
		DLL4.addFirst(1);
		
		DLL2 = new DoublyLinkedList<Integer>();
		DLL2.addLast(2);
		DLL2.addLast(1);
		
		DLL1 = new DoublyLinkedList<Integer>();
		DLL1.addFirst(1);
		
		DLL1a = new DoublyLinkedList<Integer>();
		DLL1a.addLast(1);
		
		DLL0 = new DoublyLinkedList<Integer>();
		
		Iterator<Integer> it4a = DLL4.iterator();
		Iterator<Integer> it2a = DLL2.iterator();
		Iterator<Integer> it1b = DLL1.iterator();
		Iterator<Integer> it1aa = DLL1a.iterator();
		Iterator<Integer> it0a = DLL0.iterator();
		
		it4a.remove();
		it2a.remove();
		it1b.remove();
		it1aa.remove();
		
		try{
		it0a.remove();
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		System.out.println(DLL4.getFirst() == 2);
		System.out.println(DLL2.getFirst() == 1);
		System.out.println(DLL1.isEmpty());
		System.out.println(DLL1a.isEmpty());
		
		//TESTING FOR toString
		DLL4 = new DoublyLinkedList<Integer>();
		DLL4.addFirst(4);
		DLL4.addFirst(3);
		DLL4.addFirst(2);
		DLL4.addFirst(1);
		
		DLL2 = new DoublyLinkedList<Integer>();
		DLL2.addLast(2);
		DLL2.addLast(1);
		
		DLL1 = new DoublyLinkedList<Integer>();
		DLL1.addFirst(1);
		
		DLL1a = new DoublyLinkedList<Integer>();
		DLL1a.addLast(1);
		
		DLL0 = new DoublyLinkedList<Integer>();
		
		System.out.println(DLL4.toString().equals("1 2 3 4 "));
		System.out.println(DLL2.toString().equals("2 1 "));
		System.out.println(DLL1.toString().equals("1 "));
		System.out.println(DLL1a.toString().equals("1 "));
		System.out.println(DLL0.toString().equals(""));
		
		
		
		//TESTING FOR equals
		DoublyLinkedList<Integer> DLL4x = new DoublyLinkedList<Integer>();
		DLL4x.addFirst(4);
		DLL4x.addFirst(3);
		DLL4x.addFirst(2);
		DLL4x.addFirst(1);
		
		DoublyLinkedList<Integer> DLL2x = new DoublyLinkedList<Integer>();
		DLL2x.addLast(2);
		DLL2x.addLast(1);
		
		DoublyLinkedList<Integer> DLL0x = new DoublyLinkedList<Integer>();
		
		System.out.println(DLL4.equals(DLL4));
		System.out.println(DLL4.equals(DLL4x));
		System.out.println(!DLL4.equals(DLL2));
		System.out.println(DLL2.equals(DLL2x));
		System.out.println(DLL1.equals(DLL1a));
		System.out.println(DLL0.equals(DLL0));
		System.out.println(DLL0.equals(DLL0x));
		System.out.println(!DLL4.equals("s"));
	}

}


/* removeLast is more efficient with a doubly linked list. In a singly linked list
 * this method is linear, because even though last can be accessed in constant time
 * the second to last must be accessed in order to set end equal to it and its 
 * next equal to null, and so the entire length of the list, n, minus 1 
 * must be traversed. Thus removeLast in a singly linked list is O(n).
 * 
 * On the other hand, both the last and second to last elements in a doubly linked
 * list can be accessed in constant time because each node has a previous value
 * as well. Therefore, end.previous can be reset as null and end set to end.previous.
 * Thus, removeLast becomes constant.
 */
