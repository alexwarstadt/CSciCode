package hw06

import scala.language.implicitConversions

trait IPriorityQueue[T,S] {
  // implicitly coerce S to be Ordered
  implicit def coerce(s: S) : Ordered[S] = s

  /**
   * @return optionally, the item in the heap of lowest priority
   */
  def getMinItem : Option[T]

  /**
   * @return optionally, the priority of the item in the heap of lowest priority
   */
  def getMinPriority : Option[S]

  /**
   * Adds item to the bottom of the heap and sifts up
   *
   * @param item - an item to add to heap
   */
  def insert(item: T, priority: S) : Unit

  /**
   * Deletes the lowest-valued item from the heap
   *
   * @return optionally, the lowest-valued item in the heap
   */
  def deleteMin : Option[T] 
}

object IPriorityQueue {
  /** An ordered pair
   * 
   * @constructor creates a new pair with an item and a priority
   * @param item the key in this pair
   * @param priority the priority of item
   */
  class Pair[U,V <% Ordered[V]](val item: U, val priority: V) extends Ordered[Pair[U,V]] {
    override def compare(that: Pair[U,V]) : Int = this.priority.compare(that.priority)

    override def equals (that: Any) : Boolean =
      that match {
        case Pair(u,v) => (this.item == u) && (this.priority == v)
        case _ => false
    }

    override def toString : String = "Item: " + item + ", Priority: " + priority
  }

  object Pair {
    /**
     * Decomposes this pair into an option
     *
     * @param pair the pair to decompose into parts
     * @return an option representing pair
     */
    def unapply[U,V](pair: Pair[U,V]) : Option[(U,V)] =
      if (pair == null) None
      else Some(pair.item, pair.priority)
  }
}

