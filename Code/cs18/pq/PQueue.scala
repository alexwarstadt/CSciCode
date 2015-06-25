package hw06
/**
 * A Priority Queue representing a min heap
 *
 * @constructor creates a new PQueue with a preset size
 * @param size the size of the PQueue
 */
class PQueue[T,S <% Ordered[S]](size: Int) extends IPriorityQueue[T,S] {
  import IPriorityQueue.Pair
  import Math.min

  private var numItems = 0
  private var heap = new Array[Pair[T,S]](size)

  override def getMinItem = if (isEmpty) None else Some(heap(0).item)
  override def getMinPriority = if (isEmpty) None else Some(heap(0).priority)

  def isEmpty : Boolean = (numItems == 0)
  def getSize : Int = numItems

  override def deleteMin : Option[T] = {
    if (isEmpty) None
    else {
      val toReturn = heap(0)

      // Decrement size
      numItems -= 1

      // Move last pair to the root
      heap(0) = heap(numItems)

      // Restore heap order
      siftDown(0)

      Some(toReturn.item)
    }
  }

  override def insert(item: T, priority: S) {
    // Insert new pair into heap
    heap(numItems) = new Pair[T,S](item, priority)

    // Restore heap order
    siftUp(numItems)

    // Increment numItems
    numItems += 1
  }
  
  
  
  
  
  /** 
   * swaps node at index with its parent if it needs to be swapped
   * @param index - the index of the node to be swapped
   * @returns - true of the node was swapped or is at index 0
   */
  private def swap(index: Int) : Boolean = {
    val pair1 : Pair[T,S] = this.heap(index)
    val pair2 : Pair[T,S] = this.heap((index - 1) / 2)
    if (index == 0){
      return true
    }
    if (pair1.compare(pair2) < 0){
      this.heap(index) = pair2
      this.heap((index - 1) / 2) = pair1
      return true
    }
    return false
  }
  
 
  /**
   * Makes sure that the element located at index doesn't break the heap's invariant
   * and restores heap order if it does.
   * @param index an index in the heap that is possibly out of heap order
   */
  private def siftUp(index: Int) {
    if(this.swap(index) && index > 0){
      siftUp((index - 1) / 2)
    }
  }
  
  
  

  /** 
   * Makes sure that the element located at index doesn't break the heap's invariant
   * and restores heap order if it does.
   * @param index an index in the heap that is possibly out of heap order
   */
  private def siftDown(index: Int) {
    if(this.swap(index)){
      if (index * 2 + 1 < this.numItems){
        val pair1 = this.heap(index * 2 + 1)
        if (index * 2 + 2 < this.numItems){
          val pair2 = this.heap(index * 2 + 2)
          if (pair2.compare(pair1) < 0){
            siftDown(index * 2 + 2)
          } else {
          siftDown(index * 2 + 1)
          } 
        }
      }
    }
  }

  override def toString : String = {
    val builder : StringBuilder = new StringBuilder

    for (i <- 0 until numItems) builder++= ("(" + heap(i).priority + " : " + heap(i).item + ")")

    builder.toString
  }
}

/**
 * testing object
 */
object PQueue {
  
  
   def main(args : Array[String]) {
     val pq : PQueue[String, Int] = new PQueue[String, Int](9)
     
     pq.insert("e", 5)
     println(pq.toString.equals("(5 : e)"))		//first item added, siftup on 1-item heap
     pq.insert("d", 8)
     println(pq.toString.equals("(5 : e)(8 : d)"))		//second item, does not need to swap
     pq.insert("c", 6)
     println(pq.toString.equals("(5 : e)(8 : d)(6 : c)"))			//third item, does not swap
     pq.insert("b", 7)		
     println(pq.toString.equals("(5 : e)(7 : b)(6 : c)(8 : d)"))			//fourth item, first swap
     pq.insert("a", 1)		
     println(pq.toString.equals("(1 : a)(5 : e)(6 : c)(8 : d)(7 : b)"))			// siftup all the way to the top
     pq.insert("m", 8)
     pq.insert("f", 4)
     pq.insert("z", 4)
     pq.insert("y", 4)
     println(pq.toString.equals("(1 : a)(4 : z)(4 : f)(4 : y)(7 : b)(8 : m)(6 : c)(8 : d)(5 : e)")) //doesn't swap identical priorities, and heap is full
     pq.deleteMin
     println(pq.toString.equals("(4 : z)(4 : y)(4 : f)(5 : e)(7 : b)(8 : m)(6 : c)(8 : d)")) //first delete, sift down performs swaps and maintains heap invariant
     pq.deleteMin
     pq.deleteMin
     println(pq.toString.equals("(4 : f)(5 : e)(6 : c)(8 : d)(7 : b)(8 : m)"))
     pq.deleteMin
     pq.deleteMin
     pq.deleteMin
     pq.deleteMin
     println(pq.toString.equals("(8 : m)(8 : d)"))  // sift down on two element heap
     pq.deleteMin
     println(pq.toString.equals("(8 : d)")) //sift down on one element heap
     pq.deleteMin
     println(pq.toString.equals("")) //delete last item, sift down on empty heap
     pq.deleteMin
     println(pq.toString.equals("")) //sift down on empty heap, heap empty before delete
     
     
     pq.heap = Array(new IPriorityQueue.Pair("a", 1), new IPriorityQueue.Pair("e", 5), 
         new IPriorityQueue.Pair("b", 2), new IPriorityQueue.Pair("c", 3))
     pq.numItems = 4
     pq.siftDown(3)
     println(pq.toString.equals("(1 : a)(3 : c)(2 : b)(5 : e)"))
     	//restores heap invariant, when only one daughter of node to sift down, in the middle of the heap
     	//the way I wrote siftDown, the index passed in must be
     	//either zero or the index of the daughter of the node to siftDown
     
     
     pq.heap = Array(new IPriorityQueue.Pair("j", 10), new IPriorityQueue.Pair("e", 5), 
         new IPriorityQueue.Pair("a", 1), new IPriorityQueue.Pair("m", 13))
     pq.numItems = 4
     pq.siftUp(2)
     println(pq.toString.equals("(1 : a)(5 : e)(10 : j)(13 : m)"))	//sift up from the middle of queue
     
     
     val pq1 : PQueue[Int, String] = new PQueue[Int, String](3)
     pq1.insert(1, "n")
     pq1.insert(5, "a")
     println(pq1.toString.equals("(a : 5)(n : 1)"))		//swap method uses compare correctly for strings
     pq1.insert(4, "b")
     println(pq1.toString.equals("(a : 5)(n : 1)(b : 4)"))		//swap method uses compare correctly for strings
     try{
       pq1.insert(5, "c")
     } catch {
       case e: ArrayIndexOutOfBoundsException => println("true")	//trying to insert past initialized capacity throws exception in the source code
     }
     pq1.deleteMin
     println(pq1.toString.equals("(b : 4)(n : 1)"))		//sift down uses compare for strings
     
   }
}

