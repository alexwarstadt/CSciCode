package hw07
import java.lang.IllegalArgumentException

/**
 * @constructor for a TravelPlans with a preset array of costs
 * @param costs - the array of hotel costs, must be at least 2 in length and must start and end with 0
 */
class TravelPlans(costs: Array[Double]) {
  
  if (costs.size < 2 || costs(0) != 0 || costs(costs.size-1) != 0){
    throw new IllegalArgumentException
  }
  
  
  
  
  /**
   * determines the path that minimizes the cost of a particular journey
   * @param distance - the maximum distance that can be traveled in a day
   * @returns a list containing the indices stopped at in the optimal path
   */
  def optimalInns(distance: Int): List[Int] = {
    
    var toReturn: List[Int] = List[Int]()
    
    if(distance < 1){
      throw new IllegalArgumentException
    }
    
    val optimalValues: Array[Double] = new Array(costs.length)
    for (i <- 0 to optimalValues.size - 1){
      optimalValues(i) = Double.PositiveInfinity
    }
    
    val optimalPath: Array[Int] = new Array(costs.length)
    
    optimalValues(0) = 0.
    
    for (i <- 1 to costs.length - 1) {
      var j: Int = i - 1
      
      
      
      while (j >= 0 && i - j <= distance){
        if (costs(i) + optimalValues(j) < optimalValues(i)) {
          optimalValues(i) = costs(i) + optimalValues(j)
          optimalPath(i) = j
        }
        j -= 1
      }
    }
    
    
    
    var j: Int = costs.length - 1
      while (j > 0){
        toReturn = j :: toReturn
        j = optimalPath(j)
      }
    toReturn = 0 :: toReturn
    
    
    return toReturn
  }
  
}


/**
 * testing object
 */
object TravelPlans {
    def main(args: Array[String]) {
      val tp = new TravelPlans(Array(0, 6, 7, 4, 3, 2, 9, 8 ,2, 2, 8, 6, 4, 0))
      
      println(tp.optimalInns(4) == List(0, 4, 8, 9, 13))	//there's more than one optimal solution
      println(tp.optimalInns(100) == List(0, 13))		//base case: distance starts out less than size of costs array
      println(tp.optimalInns(1) == List(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)) // pass through every hotel
      
      
      val t1p = new TravelPlans(Array(0, 0))
      println(t1p.optimalInns(10) == List(0, 1))		//smallest possible array of hotels
      
      val tp2 = new TravelPlans(Array(0,3,3,3,3,3,3,3,3,3,3,0))
      println(tp2.optimalInns(2) == List(0, 2, 4, 6, 8, 10, 11))		//many optimal solutions
      
      
      
      try{
      print(tp.optimalInns(0))		//distance is zero
      }catch{
        case _: IllegalArgumentException => println("true")
      }
      
      try{
        val tp1 = new TravelPlans(Array())		//costs is not long enough
      }catch{
        case _: IllegalArgumentException => println("true")
      }
      
      try{
        val tp1 = new TravelPlans(Array(1, 2, 3, 0))		//costs does not start in 0
      }catch{
        case _: IllegalArgumentException => println("true")
      }
      
      try{
        val tp1 = new TravelPlans(Array(0, 1, 2, 3, 3))		//costs does not end in 0
      }catch{
        case _: IllegalArgumentException => println("true")
      }
      
      
     
      
      
    }
  }