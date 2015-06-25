package finalexam

/**
 * a vertex is defined by its name, by the set of all the vertices it is connected to, 
 * and by its timeSlot, either 1 or 0
 */
class Vertex(val name: String) {
  
  var connections: Set[Vertex] = Set()
  private var timeSlot: Int = 0
  
  /**
   * sets the timeslot equal to slot one
   */
  def setSlotOne() {
    this.timeSlot = 1
  }
  
  /**
   * sets the timeslot equal to slot two
   */
  def setSlotTwo() {
    this.timeSlot = 2
  }
  
  /**
   * returns the timeslot, either 0, 1, or 2
   */
  def getSlot: Int = timeSlot
  
  

}