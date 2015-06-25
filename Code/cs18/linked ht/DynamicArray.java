package hw05;

import java.util.Iterator;
import java.util.NoSuchElementException;

public class DynamicArray<T> implements List<T> {
	
	private int capacity;
	private T[] data;
	private int start = 0;
	private int end;
	private int size = 0;
	
	
	@SuppressWarnings("unchecked")
	public DynamicArray(int capacity) throws IllegalArgumentException {
		if (capacity < 1){
			throw new IllegalArgumentException("capacity must be at least 1");
		} else {
			this.capacity = capacity;
			this.data = (T[]) new Object[this.capacity];
			this.start = 0;
			this.end = capacity -1;
		}
	}



	
	
	@Override
    public Iterator<T> iterator() { 
    
    	Iterator<T> iter = new Iterator<T>() {
    		public T current = data[start];
    		private int index = 0;
    		
    		
    		public boolean hasNext() {
	    		return (this.index < size);   
	    	}
	    	
    		
    		public T next() throws NoSuchElementException {
    			T toReturn = current;
    			if (!this.hasNext()) {
    				throw new NoSuchElementException("Iterator was at the last element");
    			} else {
    				this.index++;
    				if (this.index == size){
    					this.current = null;
    				} else {
    					current = data[(this.index + start) % capacity];
    				}
    			}
    			return toReturn;
    		}
	    	
	    	public void remove() throws UnsupportedOperationException {
	    		throw new UnsupportedOperationException("remove is not supported");
	    	}
    	};
    	return iter;
    }
	
	
	
	
	/**
	 * determines if a dynamic array is empty
	 * @return true if the dynamic array is empty
	 */
	private boolean isEmpty() {
		return this.size == 0;
	}
	
	
	
	/**
	 * determines whether it is appropriate to grow data array
	 * @return ture if array should be grown
	 */
	private boolean isFull() {
		return this.capacity == this.size;
	}
	
	
	
	/**
	 * determines whether it is appropriate to shrink data array
	 * @return true if array should be shrunk
	 */
	private boolean isSparse() {
		if (this.size == 0) {
			return true;
		}
		return (double)this.size / (double)this.capacity <= .25;
	}
	
	
	
	/**
	 * increments an index for this implementation of dynamic arrays
	 * @param i - the index
	 * @return i incremented
	 */
	private int increment(int i){
		return (i + 1 + capacity) % capacity;
	}
	
	
	
	/**
	 * decrements an index for this implementation of dynamic arrays
	 * @param i - the index
	 * @return i decremented
	 */
	private int decrement(int i){
		return (i - 1 + capacity) % capacity;
	}

	
	
	
	@SuppressWarnings("unchecked")
	private void grow() {
		T[] newData = (T[]) new Object[this.capacity * 2];
		Iterator<T> iter = this.iterator();
		int i = 0;
		while (iter.hasNext()) {
			newData[i] = iter.next();
			i++;
		}
		this.capacity *= 2;
		this.data = newData;
		this.start = 0;
		this.end = this.size -1;
	}
	
	
	
	
	@SuppressWarnings("unchecked")
	private void shrink() {
		T[] newData = (T[]) new Object[this.capacity / 2];
		Iterator<T> iter = this.iterator();
		int i = 0;
		while (iter.hasNext()) {
			newData[i] = iter.next();
			i++;
		}
		this.capacity /= 2;
		this.data = newData;
		this.start = 0;
		this.end = this.size -1;
	}
	
	
	
	
	@Override
	public void addFirst(T item) {
		if (this.isFull()){
			this.grow();
		}
		this.start = this.decrement(this.start);
		this.data[this.start] = item;
		this.size++;

	}

	
	
	
	
	

	@Override
	public void addLast(T item) {
		if (this.isFull()){
			this.grow();
		}
		this.end = this.increment(this.end);
		this.data[this.end] = item;
		this.size++;
	}


	
	
	
	@Override
	public T getFirst() throws NoSuchElementException {
		if (this.isEmpty()){
			throw new NoSuchElementException("the dynamic array is empty");
		} else {
		return this.data[start];
		}
	}

	
	
	
	

	@Override
	public T getLast() throws NoSuchElementException {
		if (this.isEmpty()){
			throw new NoSuchElementException("the dynamic array is empty");
		} else {
		return this.data[end];
		}
	}


	
	
	
	@Override
	public T get(int index) throws NoSuchElementException {
		if (index < this.size) {
			return this.data[(this.start + index) % this.capacity];
		} else {
			throw new NoSuchElementException("index out of bounds");
		}
	}


	
	
	
	
	@Override
	public T removeFirst() throws NoSuchElementException {
		T toReturn = null;
		if (this.isEmpty()) {
			throw new NoSuchElementException("the dynamic array is empty");
		} else {
			toReturn = this.data[this.start];
			this.data[this.start] = null;
			this.start = this.increment(this.start);
			this.size--;
		}
		if (this.isSparse()) {
			this.shrink();
		}
		return toReturn;
	}


	
	
	
	
	@Override
	public T removeLast() throws NoSuchElementException {
		T toReturn = null;
		if (this.isEmpty()) {
			throw new NoSuchElementException("the dynamic array is empty");
		} else {
			toReturn = this.data[this.end];
			this.data[this.end] = null;
			this.end = this.decrement(this.end);
			this.size--;
		}
		if (this.isSparse()) {
			this.shrink();
		}
		return toReturn;
	}
	
	
	
	
	
	@Override
	public String toString() {
		Iterator<T> iter = this.iterator();
		String toReturn = "";
		if (iter.hasNext()) {
			toReturn = iter.next().toString();			//avoids "," before the first element
		}
		while (iter.hasNext()) {
			toReturn += ", " + iter.next().toString();
		}
		return toReturn;
	}
	
	
	
	
	
	
	
	
	
	@SuppressWarnings ("unchecked")
	@Override
	public boolean equals(Object o) {
		if (this == o){
			return true;
		}
		if (o instanceof DynamicArray<?>){
			DynamicArray<T> that = (DynamicArray<T>)o;
			boolean toReturn = true;
			Iterator<T> thisI = this.iterator();
			Iterator<T> thatI = that.iterator();
			boolean b;
			while (thisI.hasNext() && thatI.hasNext()) {
				b = thisI.next().equals(thatI.next());
				toReturn = b && toReturn;
			}
			if (thisI.hasNext() || thatI.hasNext()) {
				toReturn = false;
			}
			return toReturn;
		} else {
			return false;
		}
	}
	
	
	
	
	/**
	 * displays important information about a dynamic array for testing purposes
	 *
	 */
	private void seeArray() {
		String toReturn = "|";
		for (int i = 0; i < this.capacity; i++) {
			if (data[i] == null) {
				toReturn += "null|";
			} else
				toReturn += data[i].toString() + "|";
		}
		toReturn += " start " + this.start + "; end " + this.end + "; capacity " + this.capacity + "; size " + this.size;
		System.out.println(toReturn);
	}
	
	
	
	public static void main(String[] args) {
		
		//testing grow and addFirst
		DynamicArray<String> da1 = new DynamicArray<String>(1);
		da1.addFirst("a");
    	System.out.println(da1.capacity == 1 && da1.size == 1);
    	da1.addFirst("b");
    	System.out.println(da1.capacity == 2 && da1.size == 2);
    	da1.addFirst("c");
    	System.out.println(da1.capacity == 4 && da1.size == 3);
    	da1.addFirst("d");
    	da1.addFirst("e");
    	System.out.println(da1.get(0).equals("e"));			//also test get
    	System.out.println(da1.get(4).equals("a"));			//test get
    	System.out.println(da1.get(2).equals("c"));			//test get
    	da1.addFirst("f");
    	da1.addFirst("g");
    	System.out.println(da1.capacity == 8 && da1.size == 7);
    	da1.addFirst("h");
    	System.out.println(da1.capacity == 8 && da1.size == 8);
    	da1.addFirst("i");
    	System.out.println(da1.capacity == 16 && da1.size == 9);
    	
    	
    	
    	
    	
    	//testing grow and addLast
    	da1 = new DynamicArray<String>(1);
    	da1.addLast("a");
    	System.out.println(da1.capacity == 1 && da1.size == 1);
    	da1.addLast("b");
    	System.out.println(da1.capacity == 2 && da1.size == 2);
    	da1.addLast("c");
    	System.out.println(da1.capacity == 4 && da1.size == 3);
    	da1.addLast("d");
    	da1.addLast("e");
    	System.out.println(da1.get(4).equals("e"));
    	System.out.println(da1.get(0).equals("a"));
    	System.out.println(da1.get(2).equals("c"));
    	da1.addLast("f");
    	da1.addLast("g");
    	System.out.println(da1.capacity == 8 && da1.size == 7);
    	da1.addLast("h");
    	System.out.println(da1.capacity == 8 && da1.size == 8);
    	da1.addLast("i");
    	System.out.println(da1.capacity == 16 && da1.size == 9);



    	//testing shrink

    	DynamicArray<Integer> da2 = new DynamicArray<Integer>(1);
    	da2.addFirst(1);
    	da2.addFirst(2);
    	da2.addFirst(3);
    	da2.addFirst(4);
		da2.addFirst(5);
		da2.addFirst(6);
		da2.addFirst(7);
		da2.addFirst(8);
		da2.addFirst(9);
		System.out.println(da2.capacity == 16 && da2.size == 9);
		da2.removeFirst();
		System.out.println(da2.capacity == 16 && da2.size == 8);
		da2.removeFirst();
		da2.removeFirst();
		da2.removeFirst();
		System.out.println(da2.capacity == 16 && da2.size == 5);
		da2.removeFirst();
		System.out.println(da2.capacity == 8 && da2.size == 4);
		da2.removeFirst();
		System.out.println(da2.capacity == 8 && da2.size == 3);
		da2.removeFirst();
		System.out.println(da2.capacity == 4 && da2.size == 2);
		da2.removeFirst();
		System.out.println(da2.capacity == 2 && da2.size == 1);
		da2.removeFirst();
		System.out.println(da2.capacity == 1 && da2.size == 0);
		try {
		da2.removeFirst();
		} catch (NoSuchElementException e) {
			System.out.println("true");
		}

		
		//testing removeLast and shrink
		da2 = new DynamicArray<Integer>(1);
		da2.addFirst(1);
		da2.addFirst(2);
		da2.addFirst(3);
		da2.addFirst(4);
		da2.addFirst(5);
		da2.addFirst(6);
		da2.addFirst(7);
		da2.addLast(8);
		da2.addLast(9);
		System.out.println(da2.capacity == 16 && da2.size == 9);
		da2.removeLast();
		da2.removeFirst();
		da2.removeLast();
		da2.removeFirst();
		System.out.println(da2.capacity == 16 && da2.size == 5);
		da2.removeLast();
		System.out.println(da2.capacity == 8 && da2.size == 4);
		da2.removeLast();
		System.out.println(da2.capacity == 8 && da2.size == 3);
		da2.removeLast();
		System.out.println(da2.capacity == 4 && da2.size == 2);
		da2.removeLast();
		System.out.println(da2.capacity == 2 && da2.size == 1);
		da2.removeLast();
		System.out.println(da2.capacity == 1 && da2.size == 0);
		try{
			da2.removeLast();
		}catch (NoSuchElementException e) {
			System.out.println("true");
		}
		
		
		//testing getfirst/getlast
		System.out.println(da1.getFirst().equals("a"));
		System.out.println(da1.getLast().equals("i"));

		try{
		da2.getFirst();
		}catch (NoSuchElementException e){
			System.out.println("true");				//empty
		}
		
		try{
			da2.getLast();
		}catch (NoSuchElementException e){
			System.out.println("true");				//empty
		}
		da2.addFirst(1);
		System.out.println(da2.getFirst().equals(1));


		
		//testing equals
		da2 = new DynamicArray<Integer>(1);
		da2.addFirst(1);
		da2.addFirst(2);
		da2.addFirst(3);
		da2.addFirst(4);
		DynamicArray<Integer> da3 = new DynamicArray<Integer>(100);
		da3.addFirst(1);
		da3.addFirst(2);
		da3.addFirst(3);
		da3.addFirst(4);
		System.out.println(da2.equals(da3));		//different capacity, still equal
		
		da3 = new DynamicArray<Integer>(1);
		da3.addLast(4);
		da3.addLast(3);
		da3.addLast(2);
		da3.addLast(1);
		System.out.println(da2.equals(da3));		//different starting places, still equal
		da3.addFirst(5);
		System.out.println(!da2.equals(da3));		//different number of elements
		
		System.out.println(!da2.equals(da1));		//different types
		
		da3 = new DynamicArray<Integer>(1);
		da1 = new DynamicArray<String>(1);
		da2 = new DynamicArray<Integer>(1);
		System.out.println(da2.equals(da3));		//both empty, same type
		System.out.println(da1.equals(da3));		//both empty, different type



		System.out.println(da2.toString());

	}
	
}