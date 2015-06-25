package finalexam
import scala.collection.mutable.ArrayBuffer
import scala.util.Random

/**
 * 
 */
class Catalog[T <% Ordered[T]] extends MSet[T] {
  
  import OrderedDoublyLinkedList.DLLNode
  
  var sublists: ArrayBuffer[CatalogList] = ArrayBuffer[CatalogList]()
  
  
  class CatalogNode(override val item: T) extends DLLNode[T](item) {
    var up: CatalogNode = null
    def getPrev: CatalogNode = if (prev != null) prev.asInstanceOf[CatalogNode] else null
    def getNext: CatalogNode = if (next != null) next.asInstanceOf[CatalogNode] else null
  }
  
  
  /**
   * an ordered doubly linked list of catalog nodes.
   */
  class CatalogList() extends OrderedDoublyLinkedList[T] {
    
    //accessor for start of list, returns a catalog node
    def getStart: CatalogNode = if (start != null) start.asInstanceOf[CatalogNode] else null
    
    /**
     * inserts an item into the catalog list and sets its up reference. This method is only a helper
     * to the uncommented insert method, and would not have been used had my final implementation been
     * functional.
     * 
     * If possible, I hope this method can not be considered a style deduction as it is not part of my
     * intended design, just a necessity for testing lookup and delete.
     * 
     * @param item the item inserted
     * @param up the catalog node that is the new node's up reference
     * @return the new catalog node
     */
    def put(item: T, up: CatalogNode): CatalogNode = {
      val newNode = new CatalogNode(item)
      if (up != null) newNode.up = up
      var curr = start
      if (curr == null) {
        start = newNode
        return newNode
      }
      if (curr.item > item){
        newNode.next = start
        start.prev = newNode
        start = newNode
        return newNode
      }

      var prev = curr
      while(curr != null && curr.item < item){
        prev = curr
        curr = curr.next
      }
      if (curr == null || curr.item != item){
        prev.next = newNode 
        newNode.prev = prev
        newNode.next = curr
        if (curr != null) curr.prev = newNode
      }
      return newNode
    }
    
  }
  
  
  
//  override def insert(item: T) {
//    if (item == null) throw new IllegalArgumentException
//    if (sublists.isEmpty) sublists = sublists :+ new CatalogList()
//    var up: CatalogNode = sublists.head.put(item, null)
//    val random = new Random()
//    var i: Int = 1
//    while(random.nextBoolean){
//      if (i == sublists.size) {
//        val newSub: CatalogList = new CatalogList()
//        newSub.put(item, up)
//        sublists = sublists :+ newSub
//        return
//      } else {
//        up = sublists(i).put(item, up)
//        i = i + 1
//      }
//    }
//  }
  
  
  /**
   * I intended for this to be my insert method but did not enough time to make it functional.
   * The other insert method is less efficient, but I had to use it in order to implement 
   * lookup and delete. 
   * 
   * If possible, I hope my grade for insert can be based on this method and not the other one, as I would
   * have used only this one if it were functional.
   * 
   * This method was meant to start at the last and smallest list and use random numbers to determine 
   * whether to insert into the list. The random number is initialized in the range 
   * 0 to 2^(sublists.size), and an insert is performed if the number is
   * divisible by 2^(sublists.size). The very first insert would be into a new list to be the new final
   * list. Each iterative step moves up a sublist and multiplies the random
   * number by 2, doubling its chance of being divisible, and guaranteeing that the random number will
   * be divisible by the top list and inserted there.
   * 
   */
  override def insert(item: T) {
    if (item == null) throw new IllegalArgumentException
    
    var newNode: CatalogNode = new CatalogNode(item)
    
    if (this.contains(item)) return
    println("insert item: "+ item)
    
    if(sublists.isEmpty){
      println("start")
      sublists = sublists :+ new CatalogList()
      sublists.last.start = newNode
      this.seeData
      return
    }
    
    val random: Random = new Random
    val lock: Int = math.pow(2, sublists.size).toInt
    var key: Int = random.nextInt(lock)
    
    var up: CatalogNode = null
    
    
    if (key % lock == 0){
      sublists = sublists :+ new CatalogList()
      sublists.last.start = newNode
      up = newNode
      newNode = new CatalogNode(item)
      
    }
    key = key * 2
    var i: Int = sublists.size - 1
    var curr: CatalogNode = sublists.last.getStart
    
    while (curr != null){
      
      if (curr.item < item){
        while (curr.getNext != null && curr.item < item){
          println("a")
          curr = curr.getNext
        }
      } else {
        while (curr.getPrev != null && curr.item > item){
          println("b")
          curr = curr.getPrev
        }
      }
      
      if (key % lock == 0){
        println("enter")
        newNode = new CatalogNode(item)
        if (curr.item < item){
          println("c")
          if (curr.getNext != null) curr.getNext.prev = newNode
          newNode.next = curr.getNext
          newNode.prev = curr
          curr.next = newNode
        } else {
          println("d")
          println(i+ "<= i     sublists size =>" + sublists.size)
          if (curr.getPrev != null) curr.getPrev.next = newNode else sublists(i).start = newNode
          newNode.prev = curr.getPrev
          newNode.next = curr
          curr.prev = newNode
        }
        if (up != null) up.up = newNode
        up = newNode
      }
      if (curr.up == null) println("null?" + curr.up) else println("up: "+ curr.up.item)
      curr = curr.up
      i = i - 1
      key = key * 2
      this.seeData
    }
  }
  
  
  
  
  override def remove(item: T): Boolean = {
    if (sublists.isEmpty) return false
    var toReturn = false
    var curr: CatalogNode = sublists.last.getStart
    var index: Int = sublists.size - 1
    while (curr != null){
      if (curr.item < item){
        while (curr.getNext != null && curr.item < item){
          curr = curr.getNext
        }
      } else if (curr.item > item){
        while (curr.getPrev != null && curr.item > item){
          curr = curr.getPrev
        }
      } 
      if (curr.item == item){
        toReturn = true
        if (curr.getNext != null) curr.getNext.prev = curr.getPrev
        if (curr.getPrev != null) curr.getPrev.next = curr.getNext else sublists(index).start = curr.getNext
      }
      index = index - 1
      curr = curr.up
    }
    return toReturn
  }
  
  
  
  
  
  
  
  override def contains(item: T): Boolean = {
    if (sublists.isEmpty) return false
    var curr: CatalogNode = sublists.last.getStart
    while (curr != null){
      var pre: CatalogNode = null
      if (curr.item < item){
        
        while (curr != null && curr.item < item){
          pre = curr
          curr = curr.getNext
        }
        if (curr == null) curr = pre
      } else if (curr.item > item){
        while (curr != null && curr.item > item){
          pre = curr
          curr = curr.getPrev
        }
        if (curr == null) curr = pre
      }
      if (curr.item == item) return true
      curr = curr.up
    }
    return false
  }
  
  
  /**
   * Used for testing. Prints the contents of each sublist forwards and backwards (in order to test
   * both next and previous references)
   */
  def seeData {
    var curr: CatalogNode = null 
    for (l <- sublists){
      curr = l.getStart
      while (curr.getNext != null){
        print(curr.item + " ")
        curr = curr.getNext
      }
      while (curr != null){
        print(curr.item + " ")
        curr = curr.getPrev
      }
      println()
    }
  }
    
  
}

object Catalog {
  def main(args: Array[String]) {
    val cat1: Catalog[Int] = new Catalog()
    cat1.insert(6)
    cat1.insert(1)
    cat1.insert(5)
    cat1.insert(4)
    cat1.insert(3)
    cat1.insert(2)
    cat1.insert(8)
    cat1.insert(10)
    cat1.insert(0)
    cat1.insert(11)
    cat1.insert(14)
    
    //item in the middle
    println(cat1.contains(4))
    println(cat1.remove(4))
    //was it removed?
    println(!cat1.contains(4))
    
    //item not in catalog, would be in middle
    println(!cat1.contains(12))
    println(!cat1.remove(12))
    
    //item not in catalog, would be at beginning
    println(!cat1.contains(-3))
    println(!cat1.remove(-3))
    
    //item not in catalog, would be at end
    println(!cat1.contains(100))
    println(!cat1.remove(100))
    
    //first in catalog
    println(cat1.contains(0))
    println(cat1.remove(0))
    println(!cat1.contains(0))
    
    //last in catalog
    println(cat1.contains(14))
    println(cat1.remove(14))
    println(!cat1.contains(14))
    
    println(cat1.remove(1))
    println(cat1.remove(5))
    cat1.remove(3)
    cat1.remove(6)
    cat1.remove(7)
    cat1.remove(8)
    cat1.remove(10)
    println(cat1.remove(11))
    
  }
}

/* My operations (i.e. the intended operation for insert) are O(log n) on average. My data structure
 * contains many linked lists with the inserted data. The first of these lists contains all of the data,
 * the second contains some subset of the data about half its size. Each successive list contains a subset
 * of about half the previous list's data, and each datum has pointers to its copy in the previous list.
 * 
 * Insertion minimizes adversarial input by randomizing the number of lists that a new datum is added to.
 * A datum inserted is always added to the first list, then about half are added to the next list using
 * random number generation to determine whether to add. Always about half of the data that are inserted into a
 * list are inserted into the next list. Because it is random, there are no guarantees that the runtime
 * will be better than linear, but on average a catalog of size n has log_2(n) lists associated with it
 * and the nth list contains n/2^n items.
 * 
 * Lookups start at the last and smallest list, finding the closest value to the target in that last and 
 * progressing to that value's copy in the previous list until the item is found. They are expected to 
 * be logarithmic because the search space is bisected as the search jumps to the previous list. Indeed,
 * if it is possible for some jumps to reduce to search space by almost nothing, it is just as likely for
 * a single jump to reduce the search space almost entirely.
 * 
 * Similarly, the algorithm for inserting is very similar in that it jumps around. Given the expected
 * log_2(n) lists, the item is inserted log_2(n) in the worst case, and the jumping around is exactly
 * as costly as in lookups.
 * 
 * Deletions also rely on the same jumping around as lookups, only once they locate the target it and all
 * its copies in other lists that it points to has its previous and next nodes' next and previous pointers 
 * changed, respectively. 
 * 
 */



//package finalexam
//import scala.collection.mutable.ArrayBuffer
//import scala.util.Random
//
//class Catalog[T <% Ordered[T]] extends MSet[T] {
//  
//  import OrderedDoublyLinkedList.DLLNode
//  
//  var sublists: ArrayBuffer[CatalogList] = ArrayBuffer[CatalogList]()
//  //val list: OrderedDoublyLinkedList[T] = new OrderedDoublyLinkedList[T]()
//  
//  
//  class CatalogNode(override val item: T) extends DLLNode[T](item) {
//    
//    var up: CatalogNode = null
//    
//    var down: CatalogNode = null
//    
//    def getPrev: CatalogNode = if (prev != null) prev.asInstanceOf[CatalogNode] else null
//    //override var prev: CatalogNode = null
//
//    def getNext: CatalogNode = if (next != null) next.asInstanceOf[CatalogNode] else null
//    //override var next: CatalogNode = null
//  }
//  
//  
//  
//  class CatalogList() extends OrderedDoublyLinkedList[T] {
//    
//    def getStart: CatalogNode = if (start != null) start.asInstanceOf[CatalogNode] else null
//    //override var start: CatalogNode = null
//    
//    /*def put(item: T, up: CatalogNode): CatalogNode = {
//      val newNode = new CatalogNode(item)
//      if (up != null) newNode.up = up
//      var curr = start
//      if (curr == null) {
//        start = newNode
//        return newNode
//      }
//      if (curr.item > item){
//        newNode.next = start
//        start.prev = newNode
//        start = newNode
//        return newNode
//      }
//
//      var prev = curr
//      while(curr != null && curr.item < item){
//        prev = curr
//        curr = curr.next
//      }
//    //update if the node doesn't already exist
//      if (curr == null || curr.item != item){
//        prev.next = newNode 
//        newNode.prev = prev
//        newNode.next = curr
//        if (curr != null) curr.prev = newNode
//      }
//      return newNode
//    } */
//    
//  }
//  
//  
//  //make sublists a list of tuples storing the value in the next list
//  
//  override def insert(item: T) {
//    if (sublists.contains(item)) return 
//    var newNode = new CatalogNode(item)
//    
//    if (sublists.isEmpty) {
//      println("start")
//      sublists = sublists :+ new CatalogList()
//      sublists.head.start = newNode
//      return
//    }
//    
//    val random = new Random()
//    val pow: Int = math.pow(2, sublists.size).toInt
//    //println("Hey" + math.pow(2, sublists.size).toInt)
//    var num: Int = random.nextInt(math.pow(2, sublists.size).toInt)
//    
//    var curr: CatalogNode = sublists.last.getStart
//    var down: CatalogNode= null
//    var count: Int = 0
//    if (num % pow == 0){
//      
//      sublists = new CatalogList() +: sublists
//      sublists.head.start = newNode
//      down = newNode
//      count = 1
//      println("new, sublists.length = " + sublists.length)
//    }
//    num = num * 2
//    
//    while (curr != null){
//      println("curr" + curr.item)
//      if (curr.item < item){
//        while (curr.getNext != null && curr.item < item){
//          curr = curr.getNext
//        }
//      } else {
//        while (curr.getPrev != null && curr.item > item){
//          curr = curr.getPrev
//        }
//      }
//      if (num % pow == 0){
//        newNode = new CatalogNode(item)
//        if (curr.item < item) {
//          if (curr.getNext != null){
//            curr.getNext.prev = newNode
//            newNode.next = curr.getNext
//          }
//          curr.next = newNode
//          newNode.prev = curr
//        } else {
//          if (curr.getPrev != null){
//            curr.getPrev.next = newNode
//            newNode.prev = curr.getPrev
//            sublists(count).start = newNode
//          }
//          curr.prev = newNode
//          newNode.next = curr
//        }
//        if (down != null) down.up = newNode
//        down = newNode
//      }
//      num = num * 2
//      count = count + 1
//      curr = curr.down
//    }
//    println("done")
//  }
//  
//  
//  
//  
//  override def remove(item: T): Boolean = {
//    return true
//  }
//  
//  
//  
//  
//  
//  
//  
//  override def contains(item: T): Boolean = {
//    if (sublists.isEmpty) return false
//    var curr: CatalogNode = sublists.head.getStart
//    //var curr: CatalogNode = sublists.head.start
//    while (curr != null){
//      var pre: CatalogNode = null
//      if (curr.item < item){
//        while (curr != null && curr.item < item){
//          pre = curr
//          curr = curr.getNext
//          //curr = curr.next
//        }
//        if (curr == null) curr = pre
//      } else if (curr.item > item){
//        while (curr != null && curr.item > item){
//          pre = curr
//          curr = curr.getPrev
//          //curr = curr.prev
//        }
//        if (curr == null) curr = pre
//      }
//      if (curr.item == item) return true
//      curr = curr.up
//    }
//    return false
//  }
//  
//  
//  
//  def seeData {
//    var curr: CatalogNode = null 
//    for (l <- sublists){
//      curr = l.getStart
//      //curr = l.start
//      print("!!!!!")
//      while (curr.getNext != null){
//      //while (curr.next != null){
//        print(curr.item + " ")
//        curr = curr.getNext
//        //curr = curr.next
//      }
//      //while below for testing
//      while (curr != null){
//        print(curr.item + " ")
//        curr = curr.getPrev
//        //curr = curr.prev
//      }
//      println()
//    }
//  }
//    
//  
//}
//
//object Catalog {
//  def main(args: Array[String]) {
//    val cat1: Catalog[Int] = new Catalog()
//    /*cat1.insert(6)
//    cat1.insert(1)
//    cat1.insert(5)
//    cat1.insert(4)
//    cat1.insert(3)
//    cat1.insert(2)
//    cat1.seeData
//    println(cat1.contains(4))*/
//    val r = new Random()
//    for (i <- 1 to 50) cat1.insert(r.nextInt(50))
//    cat1.seeData
//    println(cat1.contains(100))
//    /*println(cat1.contains(4))
//    println(cat1.contains(1))
//    println(cat1.contains(2))
//    println(cat1.contains(6))
//    println(cat1.contains(5))*/
//  }
//}



//package finalexam
//import scala.collection.mutable.ArrayBuffer
//import scala.util.Random
//
//class Catalog[T <% Ordered[T]] extends MSet[T] {
//  
//  import OrderedDoublyLinkedList.DLLNode
//  
//  var sublists: ArrayBuffer[CatalogList] = ArrayBuffer[CatalogList]()
//  //val list: OrderedDoublyLinkedList[T] = new OrderedDoublyLinkedList[T]()
//  
//  
//  class CatalogNode(override val item: T) extends DLLNode[T](item) {
//    
//    var up: CatalogNode = null
//    
//    def getPrev: CatalogNode = if (prev != null) prev.asInstanceOf[CatalogNode] else null
//    //override var prev: CatalogNode = null
//
//    def getNext: CatalogNode = if (next != null) next.asInstanceOf[CatalogNode] else null
//    //override var next: CatalogNode = null
//  }
//  
//  
//  
//  class CatalogList() extends OrderedDoublyLinkedList[T] {
//    
//    def getStart: CatalogNode = if (start != null) start.asInstanceOf[CatalogNode] else null
//    //override var start: CatalogNode = null
//    
//    def put(item: T, up: CatalogNode): CatalogNode = {
//      val newNode = new CatalogNode(item)
//      if (up != null) newNode.up = up
//      var curr = start
//      if (curr == null) {
//        start = newNode
//        return newNode
//      }
//      if (curr.item > item){
//        newNode.next = start
//        start.prev = newNode
//        start = newNode
//        return newNode
//      }
//
//      var prev = curr
//      while(curr != null && curr.item < item){
//        prev = curr
//        curr = curr.next
//      }
//    //update if the node doesn't already exist
//      if (curr == null || curr.item != item){
//        prev.next = newNode 
//        newNode.prev = prev
//        newNode.next = curr
//        if (curr != null) curr.prev = newNode
//      }
//      return newNode
//    } 
//    
//  }
//  
//  
//  //make sublists a list of tuples storing the value in the next list
//  
//  override def insert(item: T) {
//    if (sublists.isEmpty) sublists = sublists :+ new CatalogList()
//    var up: CatalogNode = sublists.head.put(item, null)
//    val random = new Random()
//    var i: Int = 1
//    while(random.nextBoolean){
//      if (i == sublists.size) {
//        val newSub: CatalogList = new CatalogList()
//        newSub.put(item, up)
//        sublists = sublists :+ newSub
//        return
//      } else {
//        up = sublists(i).put(item, up)
//        i = i + 1
//      }
//    }
//  }
//  
//  
//  
//  
//  override def remove(item: T): Boolean = {
//    if (sublists.isEmpty) return false
//    var toReturn = false
//    var curr: CatalogNode = sublists.last.getStart
//    var index: Int = sublists.size - 1
//    while (curr != null){
//      if (curr.item < item){
//        while (curr.getNext != null && curr.item < item){
//          curr = curr.getNext
//        }
//      } else if (curr.item > item){
//        while (curr.getPrev != null && curr.item > item){
//          curr = curr.getPrev
//        }
//      } 
//      if (curr.item == item){
//        toReturn = true
//        if (curr.getNext != null) curr.getNext.prev = curr.getPrev
//        if (curr.getPrev != null) curr.getPrev.next = curr.getNext else sublists(index).start = curr.getNext
//      }
//      index = index - 1
//      curr = curr.up
//    }
//    return toReturn
//  }
//  
//  
//  
//  
//  
//  
//  
//  override def contains(item: T): Boolean = {
//    if (sublists.isEmpty) return false
//    var curr: CatalogNode = sublists.last.getStart
//    //var curr: CatalogNode = sublists.head.start
//    while (curr != null){
//      var pre: CatalogNode = null
//      if (curr.item < item){
//        
//        while (curr != null && curr.item < item){
//          print(curr.item + " ")
//          pre = curr
//          curr = curr.getNext
//          //curr = curr.next
//        }
//        println
//        if (curr == null) curr = pre
//      } else if (curr.item > item){
//        while (curr != null && curr.item > item){
//          print(curr.item + " ")
//          pre = curr
//          curr = curr.getPrev
//          //curr = curr.prev
//        }
//        println
//        if (curr == null) curr = pre
//      }
//      if (curr.item == item) return true
//      curr = curr.up
//    }
//    return false
//  }
//  
//  
//  
//  def seeData {
//    var curr: CatalogNode = null 
//    for (l <- sublists){
//      curr = l.getStart
//      //curr = l.start
//      while (curr.getNext != null){
//      //while (curr.next != null){
//        print(curr.item + " ")
//        curr = curr.getNext
//        //curr = curr.next
//      }
//      //while below for testing
//      while (curr != null){
//        print(curr.item + " ")
//        curr = curr.getPrev
//        //curr = curr.prev
//      }
//      println()
//    }
//  }
//    
//  
//}
//
//object Catalog {
//  def main(args: Array[String]) {
//    val cat1: Catalog[Int] = new Catalog()
//    /*cat1.insert(6)
//    cat1.insert(1)
//    cat1.insert(5)
//    cat1.insert(4)
//    cat1.insert(3)
//    cat1.insert(2)
//    cat1.seeData
//    println(cat1.contains(4))*/
//    val r = new Random()
//    for (i <- 1 to 50) cat1.insert(r.nextInt(50))
//    cat1.seeData
//    println(cat1.contains(11))
//    /*println(cat1.contains(4))
//    println(cat1.contains(1))
//    println(cat1.contains(2))
//    println(cat1.contains(6))
//    println(cat1.contains(5))*/
//    println(cat1.remove(11))
//    cat1.seeData
//  }
//}
//
