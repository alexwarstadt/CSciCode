package finalexam

class OrderedDoublyLinkedList[T <% Ordered[T]] extends MSet[T] {
  import OrderedDoublyLinkedList.DLLNode

  //beginning of the list
  var start: DLLNode[T] = null
  override def remove(item: T): Boolean = {
    var curr = start
    while (curr != null && curr.item <= item) {
      if (item == curr.item) {
        if (curr.next != null) curr.next.prev = curr.prev
        if (curr.prev != null) curr.prev.next = curr.next
        else start = start.next
        return true
      }
      curr = curr.next
    }
    //at this point, the list has been searched and the node was not found
    return false
  }

  override def insert(item: T) {
    val newNode = new DLLNode[T](item)
    var curr = start
    if (curr == null) {
      start = newNode
      return
    }
    if (curr.item > item){
      newNode.next = start
      start.prev = newNode
      start = newNode
      return
    }

    var prev = curr
    while(curr != null && curr.item < item){
      prev = curr
      curr = curr.next
    }
    //update if the node doesn't already exist
    if (curr == null || curr.item != item){
      prev.next = newNode 
      newNode.prev = prev
      newNode.next = curr
      if (curr != null) curr.prev = newNode
    }
  } 

  override def contains(item: T): Boolean = {
    var curr = start

    while(curr != null){
      if (item < curr.item) return false
      if (item == curr.item) return true
      curr = curr.next
    }

    return false
  }
}

object OrderedDoublyLinkedList {
  case class DLLNode[S](val item: S, var next: DLLNode[S] = null, var prev: DLLNode[S] = null) {}
}

