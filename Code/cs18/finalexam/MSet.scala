package finalexam

trait MSet[T] {
  /** remove an item from the set; returns whether it was found
   * @param item the item to be removed from the set 
   * @return true if the item was found and removed from the set, 
   * false if it was not in the set to begin with
   */
  def remove(item: T): Boolean

  /** insert item into the set
   *@param item the item to be added; does nothing if item already exists
   */
  def insert(item: T): Unit

  /** check if an item is in the set
   * @param item the item to look up
   * @return true if the item is in the set, and false otherwise
   */
  def contains(item: T): Boolean
}

